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
            .limit(to: 10)

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
    /// ユーザーが通知ビュー内の更新キャンセルボタンをタップした場合に発火するデータ変更リセットメソッド。
    ///
    func resetController(to team: Team?, element: Log) async throws {

        switch element.type {

        case .addItem(let item):
            try await
            self.resetAddedItem(item, to: team, element: element)

        case .updateItem(let item):
            try await
            self.resetUpdatedItem(item, to: team, element: element)

        case .deleteItem(let item):
            try await
            self.resetDeletedItem(item, to: team, element: element)

        case .commerce(let items):
            break

        case .join:
            break

        case .updateUser(let user):
            break

        case .updateTeam(let team):
            break
        }
    }

    //MEMO:  単純にbeforeデータを上書きするだけだと、通知が発行された以降にもしデータの更新があった場合に、
    // 以降の更新も一緒に上書きしてしまう。よって、beforeとafterの差分を先に求め、その値をデータに反映させる。
    /// 更新されたアイテムデータの内容をリセットするメソッド。
    /// 現在のアイテムデータをフェッチし、更新の差分値を反映させて保存し直す。
    func resetUpdatedItem(_ item: CompareItem, to team: Team?, element: Log) async throws {

        print("更新を取り消すアイテムのid: \(item.id)")

        // CompareItemを使って差分を先に出す

        let itemRef = db?
            .collection("teams")
            .document(team?.id ?? "")
            .collection("items")
            .document(item.id)

        do {

        } catch {
            throw NotificationError.resetUpdateItem
        }
    }
    /// アイテムデータの追加をキャンセルし削除するメソッド。
    func resetAddedItem(_ addedItem: Item, to team: Team?, element: Log) async throws {
        let itemRef = db?
            .collection("teams")
            .document(team?.id ?? "")
            .collection("items")
            .document(addedItem.id ?? "")

        do {
            try await itemRef?.delete()
        }
        catch {
            throw NotificationError.resetAddItem
        }
    }

    /// アイテムデータの追加をキャンセルし削除するメソッド。
    func resetDeletedItem(_ deletedItem: Item, to team: Team?, element: Log) async throws {
        let itemRef = db?
            .collection("teams")
            .document(team?.id ?? "")
            .collection("items")
            .document(deletedItem.id ?? "")

        do {
            try await itemRef?.setData(from: deletedItem)
        }
        catch {
            throw NotificationError.resetAddItem
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

    deinit {
        listener?.remove()
    }
}

/// 通知関連のエラーを管理するクラス。
enum NotificationError: Error {
    case resetUpdateItem
    case resetAddItem
}
