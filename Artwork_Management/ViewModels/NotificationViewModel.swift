//
//  TeamNotificationViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/04.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

/// チーム全体に届く通知ボードの保存・表示・削除を管理するクラス。
/// チームメンバーによるデータの編集履歴「Log」構造体を元に、通知を生成する。
class NotificationViewModel: ObservableObject {

    init() { print("<<<<<<<<<  TeamNotificationViewModel_init  >>>>>>>>>") }

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var listener: ListenerRegistration?
    var uid: String? { Auth.auth().currentUser?.uid }

    /// 現在表示されている通知を保持するプロパティ。
    @Published var currentNotification: Log?
    /// ローカルに残っている通知。このプロパティ内の通知データが無くなるまで
    /// currentNotificationへの格納 -> 破棄 -> 格納 が続く。
    @Published var remainNotifications: [Log] = []

    /// メンバーデータのステートを監視するリスナーメソッド。
    /// 初期実行時にリスニング対象ドキュメントのデータが全取得される。(フラグはadded)
    func listener(id currentTeamID: String?) {
        print("notificationListener実行")
        guard let uid, let currentTeamID else { return }
        guard let teamRef = db?.collection("teams")
            .document(currentTeamID) else { return }

        listener = teamRef.addSnapshotListener { snap, error in
            if let error {
                print("ERROR: \(error.localizedDescription)")
            } else {
                guard let snap else { print("ERROR: snap nil"); return }

                do {
                    let teamData = try snap.data(as: Team.self)
                    guard let myData = teamData.members
                        .first(where: { $0.memberUID == uid }) else {
                        return
                    }
                    
                    self.remainNotifications = myData.notifications
                    //                        .compactMap({ $0 })
                } catch {
                    print("ERROR: try snap?.data(as: Team.self)")
                }
            }
        }
    }

    /// アイテムや新規通知をチーム内の各メンバーに渡すメソッド。
    func setNotification(team: Team?, type logType: LogType) {
        guard var team else { return }
        guard let myMemberData = getCurrentTeamMyMemberData(team: team) else { return }
        guard let teamRef = db?.collection("teams").document(team.id) else { return }

        let element = Log(createTime: Date(), editBy: myMemberData, type: logType)
        switch logType.setRule {

        case .local:
            for index in team.members.indices where team.members[index].memberUID == uid {
                team.members[index].notifications.append(element)
            }
        case .global:
            for index in team.members.indices {
                team.members[index].notifications.append(element)
            }
        }

        do {
            _ = try teamRef.setData(from: team, merge: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            }
        } catch {
            print("Error: setNotification")
        }
    }
    /// Firestore内の通知データを削除するメソッド。
    /// 通知のエレメントが持つ削除タイプを参照して、ローカル削除とグローバル削除を分岐する。
    func removeNotification(team: Team?, element: Log) {
        guard var team else { return }
        guard let teamRef = db?.collection("teams").document(team.id) else { return }

//        switch element.type.removeRule {

//        case .local:
            guard let index = team.members.firstIndex(where: { $0.memberUID == uid }) else { return }
            team.members[index].notifications.removeAll(where: { $0.id == element.id })

//        case .global:
//            for index in team.members.indices {
//                team.members[index].notifications.removeAll(where: { $0.id == element.id })
//            }
//        }

        do {
            _ = try teamRef.setData(from: team, merge: true)
        } catch {
            print("Error: removeNotification")
        }
    }

    /// 更新されたデータの内容をリセットするメソッド。
//    func resetToItem(element: NotifyElement) {
//
//        switch element.type.setRule {
//
//        case .local:
//            <#code#>
//        case .global:
//            <#code#>
//        }
//    }

    /// 通知から受け取ったアイテムデータの更新内容を取り消すメソッド。
    /// 更新以前の値を受け取り、Firestoreに上書き保存する。
    func cancelUpdateItemToFirestore(data beforeItem: Item, team: Team?) async throws {
        guard let team else { return }
        guard let itemID = beforeItem.id else { return }
        guard let itemRef = db?.collection("teams")
            .document(team.id)
            .collection("items")
            .document(itemID) else { return }

        do {
            try itemRef.setData(from: beforeItem, merge: true) // 保存
        } catch {
            print("Item: \(beforeItem.name)の更新取り消し失敗")
            throw CustomError.setData
        }
    }
    /// 通知から受け取ったユーザーの更新内容を取り消すメソッド。
    /// 更新以前の値を受け取り、Firestoreに上書き保存する。
    func cancelUpdateUserToFirestore(data beforeUser: User?) async throws {
        guard let beforeUser else { return }
        guard let userRef = db?.collection("users")
            .document(beforeUser.id) else { throw CustomError.getRef }

        do {
            try userRef.setData(from: beforeUser, merge: true) // 保存
        } catch {
            throw CustomError.setData
        }
    }
    /// 通知から受け取ったチームの更新内容を取り消すメソッド。
    /// 更新以前の値を受け取り、Firestoreに上書き保存する。
    func cancelUpdateTeam(to beforeTeam: Team?) {
        guard let beforeTeam else { return }

    }

    /// 現在の操作チームのメンバーidを取得するメソッド。。
    func getCurrentTeamMembersUid(team: Team) -> [String] {
        let membersID: [String] = team.members.map({ $0.memberUID })
        return membersID
    }
    /// 現在の操作チームのメンバーidを取得するメソッド。。
    func getCurrentTeamMyMemberData(team: Team) -> JoinMember? {
        let getGyMemberData = team.members.first(where: { $0.memberUID == uid })
        return getGyMemberData
    }

    deinit {
        listener?.remove()
    }
}
