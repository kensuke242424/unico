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
class TeamNotificationViewModel: ObservableObject {

    init() { print("<<<<<<<<<  TeamNotificationViewModel_init  >>>>>>>>>") }

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var listener: ListenerRegistration?
    var uid: String? { Auth.auth().currentUser?.uid }

    /// 通知の表示開始を管理するプロパティ。
    /// このプロパティがトグルされると、TeamNotificationViewが初期化され、
    /// ビュー側で通知データの取得が始まる。
    @Published var show: Bool = false
    /// 現在表示されている通知を保持するプロパティ。
    /// ユーザーが保持している通知の数が無くなるまで、ビュー側で更新が続く。
    @Published var currentNotification: TeamNotifyFrame?
    @Published var myNotifications: [TeamNotifyFrame] = []

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
                    self.myNotifications = myData.notifications
//                        .compactMap({ $0 })
                } catch {
                    print("ERROR: try snap?.data(as: Team.self)")
                }
            }
        }
    }

    /// アイテムや新規通知をチーム内の各メンバーに渡すメソッド。
    func setNotification(team: Team?, type: TeamNotificationType) {
        guard var team else { return }
        guard let teamRef = db?.collection("teams").document(team.id) else { return }
        let notification = TeamNotifyFrame(type: type,
                                    message: type.message,
                                    imageURL: type.imageURL,
                                    exitTime: type.waitTime)
        for index in team.members.indices {
            team.members[index].notifications.append(notification)
        }

        do {
            _ = try teamRef.setData(from: team)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            }
        } catch {
            print("Error: setNotification")
        }
    }
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
    /// 自身のみの通知データを消去するメソッド。他メンバーの通知データはそれぞれがログインした時に表示される。
    func removeLocalNotificationToFirestore(team: Team?, data: TeamNotifyFrame) {
        guard var team else { return }
        guard let teamRef = db?.collection("teams").document(team.id) else { return }

        guard let index = team.members.firstIndex(where: { $0.memberUID == uid }) else { return }
        team.members[index].notifications.removeAll(where: { $0.id == data.id })

        do {
            _ = try teamRef.setData(from: team)
        } catch {
            print("Error: setNotification")
        }
    }
    /// 全メンバーの対象通知データを消去。他のメンバーがログインするまで残しておく必要がない通知データに使う。
    func removeTeamNotificationToFirestore(team: Team?, data: TeamNotifyFrame) {
        guard var team else { return }
        guard let teamRef = db?.collection("teams").document(team.id) else { return }

        for index in team.members.indices {
            team.members[index].notifications.removeAll(where: { $0.id == data.id })
        }

        do {
            _ = try teamRef.setData(from: team)
            print("全メンバーの対象通知データを消去")
        } catch {
            print("Error: setNotification")
        }
    }
    /// 現在の操作チームのメンバーidを取得するメソッド。。
    func getCurrentTeamMembers(team: Team) -> [String] {
        let membersID: [String] = team.members.map({ $0.memberUID })
        return membersID
    }

    deinit {
        listener?.remove()
    }
}
