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

/// チーム全体に届くデータの追加・更新・削除通知を管理するクラス。
/// チームドキュメントのサブコレクション「logs」から、自身が未読のログをクエリ取得して通知表示する。
class NotificationViewModel: ObservableObject {

    init() { print("<<<<<<<<<  NotificationViewModel_init  >>>>>>>>>") }

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var listener: ListenerRegistration?
    var uid: String? { Auth.auth().currentUser?.uid }

    /// 現在表示されている通知を保持するプロパティ。
    @Published var currentNotification: Log?
    /// ローカルに残っている通知。このプロパティ内の通知が空になるまで
    /// currentNotificationへの格納 -> 破棄 -> 格納 が続く。
    @Published var notifications: [Log] = []

    func listener(id currentTeamID: String?) {

        let myLogsRef = db?
            .collection("teams")
            .document(currentTeamID ?? "")
            .collection("members")
            .document(uid ?? "")
            .collection("logs")

        let unreadLogQuery = myLogsRef?
            .whereField("read", in: [false])

        /// 未読を表す「unread」フィールドに自身のuidが存在するドキュメントを取得する
        listener = unreadLogQuery?.addSnapshotListener { (snapshot, _) in
            do {
                guard let documents = snapshot?.documents else { return }

                self.notifications = documents.compactMap { (snap) -> Log? in
                    return try? snap.data(as: Log.self, with: .estimate)
                }
                // 現在表示されている通知が無く、かつ未読の通知が残っていれば新たに通知を格納する
                if self.currentNotification == nil {
                    guard let nextElement = self.notifications.first else { return }
                    self.currentNotification = nextElement
                }
            }
            catch {
                print("ERROR: 通知の取得に失敗")
            }
        }
    }

    /// ユーザーが既に表示した通知に既読を付けるメソッド。
    func setRead(team: Team?, element: Log) {
        guard let team, let uid else { return }

        do {
            var updatedElement = element
            updatedElement.read = true
            print("既読処理実行")

            try db?.collection("teams")
                .document(team.id)
                .collection("members")
                .document(uid)
                .collection("logs")
                .document(element.id)
                .setData(from: updatedElement, merge: true)

            print("通知を既読にしました")
        } catch {
            print("ERROR: 既読処理に失敗")
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
    func getMembersId(team: Team) -> [String] {
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
