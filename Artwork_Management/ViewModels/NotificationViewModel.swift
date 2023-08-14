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
        guard let uid, let currentTeamID else {
            print("ERROR: 通知のリスニング失敗")
            return
        }

        let myLogsRef = db?
            .collection("teams")
            .document(currentTeamID)
            .collection("members")
            .document(uid)
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
                if let updatedLog = self.notifications.first(where: {
                    $0.id == self.currentNotification?.id
                }) {
                    self.currentNotification = updatedLog
                }
            }
            catch {
                print("ERROR: 通知のリスニング失敗")
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
    /// ユーザーが通知ビューに記載している更新内容をキャンセルした場合に発火する、更新内容のリセットメソッドコントローラ。
    /// ログのタイプをメソッド内で参照し、タイプごとで実行メソッドを分岐ハンドリングする。
    /// - Parameters:
    ///   - team: リセット処理を行う対象のチーム。現在操作しているCurrentTeamが格納される。
    ///   - element: 現在操作を行っているログ通知の要素データ。ログの要素とタイプが格納されている。
    ///   - selectedIndex: 通知ログのタイプが複数のデータを扱うタイプの場合(カート処理など)に、
    ///   リセット対象のアイテムをハンドリングするための配列インデックス。
    func resetController(to team: Team?, element: Log, index selectedIndex: Int? = nil) async throws {

        switch element.type {

        case .addItem(let item):
            try await self.resetAddedItem(item, to: team, element: element)

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
            try await
            self.resetUpdateUser(user.before, to: team, element: element)

        case .updateTeam(let team):
            break
        }
    }

    //MEMO:  単純にbeforeデータを上書きするだけだと、通知が発行された以降にもしデータの更新があった場合に、
    // 以降の更新も一緒に上書きしてしまう。よって、beforeとafterの差分を先に求め、その値をデータに反映させる。
    /// 更新されたアイテムデータの内容をリセットするメソッド。
    /// 現在のアイテムデータをフェッチし、更新の差分値を反映させて保存し直す。
    func resetUpdatedItem(_ item: CompareItem, to team: Team?, element: Log) async throws {
        guard let team else { throw NotificationError.missingData }

        let itemRef = db?
            .collection("teams")
            .document(team.id)
            .collection("items")
            .document(item.id)

        do {
            /// 削除済みであることを各メンバーのログデータに書き込む
//            try await setCanceled(to: team, date: addedItem.createTime, element: element)
        } catch {
            throw NotificationError.resetUpdatedItem
        }
    }
    /// アイテムデータの追加をキャンセルし削除するメソッド。
    /// アイテムのidはFirestoreに保存される時に生成されるため、
    /// 一度アイテムをフェッチし、ドキュメントIDを取得する工程が必要である。
    func resetAddedItem(_ addedItem: Item, to team: Team?, element: Log) async throws {
        guard let team, let itemId = addedItem.id else {
            throw NotificationError.missingData
        }
        let itemsRef = db?
            .collection("teams")
            .document(team.id)
            .collection("items")

        /// 削除対象アイテムのcreateTimeでクエリを作成
        let addedItemQuery = itemsRef?
            .whereField("name", in: [addedItem.name])

        do {
            let snapshot = try await addedItemQuery?.getDocuments()
            guard let documents = snapshot?.documents else {
                throw NotificationError.noSnapShotExist
            }
            guard let document = documents.first else {
                throw NotificationError.noDocumentExist
            }
            /// DocIDが取得できたら、アイテム削除を実行
            let itemId = document.documentID
            let addedItemRef = itemsRef?.document(itemId)
            try await addedItemRef?.delete()
            /// リセット済みであることを各メンバーのログデータに書き込む
            try await setCanceled(to: team, date: addedItem.createTime, element: element)
        }
        catch {
            throw NotificationError.resetAddedItem
        }
    }

    /// アイテムデータの削除をキャンセルし、元に戻すメソッド。
    func resetDeletedItem(_ deletedItem: Item, to team: Team?, element: Log) async throws {
        guard let team, let itemId = deletedItem.id else {
            throw NotificationError.missingData
        }

        let itemRef = db?
            .collection("teams")
            .document(team.id)
            .collection("items")
            .document(itemId)

        do {
            try await itemRef?.setData(from: deletedItem)
            try await setCanceled(to: team, date: deletedItem.createTime, element: element)
        }
        catch {
            throw NotificationError.resetDeletedItem
        }
    }

    /// ユーザーデータの更新をキャンセルし元に戻すメソッド。
    func resetUpdateUser(_ beforeUser: User?, to team: Team?, element: Log) async throws {
        guard let beforeUser, let team else {
            throw NotificationError.missingData
        }
        // 👦 ------- 自身のユーザードキュメント処理 ---------👦
        let userRef = db?
            .collection("users")
            .document(beforeUser.id)

        do {
            try await userRef?.setData(from: beforeUser)
            try await setCanceled(to: team, date: beforeUser.createTime, element: element)
        }
        catch {
            throw NotificationError.resetAddedItem
        }

        // 👦👩 ------- 自身の所属するチームのメンバーデータ処理 ---------👩👦

        /// ユーザーが所属している全てのチームのmembersサブコレクションから、
        /// 自身のドキュメントリファレンスを取り出す。
        //TODO: ユーザーのjoins[JoinMember] -> joinsId[String]に変更する必要あり
        let joinTeamsMembersRef = beforeUser.joinsId.compactMap { teamId in
            let teamMembersRef = db?
                .collection("teams")
                .document(teamId)
                .collection("members")
                .document(beforeUser.id)
            return teamMembersRef
        }

        let resetMemberData = JoinMember(id: beforeUser.id,
                                         name: beforeUser.name,
                                         iconURL: beforeUser.iconURL)

        for MyMemberRef in joinTeamsMembersRef {
            do {
                try await MyMemberRef.setData(from: resetMemberData)
            }
            catch {
                throw NotificationError.resetAddedItem
            }
        }
    }
    /// チームデータの更新をキャンセルし元に戻すメソッド。
    func resetUpdateTeam(_ beforeUser: User?, to team: Team?, element: Log) async throws {
        return
    }

    /// チームの各メンバーのログデータに、変更内容のキャンセル実行を反映させるメソッド。
    /// キャンセル処理の重複を避けるために必要である。
    /// ログデータの「canceledDatas」にデータのcreateTimeを格納する。
    func setCanceled(to team: Team?, date canceledDataDate: Date, element: Log) async throws {
        guard let team else { throw NotificationError.missingData }

        /// ログデータに削除済みデータのcreateTimeを格納
        var updatedElement = element
        updatedElement.canceledDatas.append(canceledDataDate)
        /// チームのサブコレクションmembersリファレンス
        let membersRef = db?
            .collection("teams")
            .document(team.id)
            .collection("members")

        let snap = try await membersRef?.getDocuments()
        guard let documents = snap?.documents else {
            throw NotificationError.noDocumentExist
        }

        for document in documents {

            let memberId = document.documentID
            let logRef = membersRef?
                .document(memberId)
                .collection("logs")
                .document(element.id)
            /// メンバーのログデータにキャンセル済であることを反映
            try await logRef?.setData(from: updatedElement)
        }
    }

    /// 通知の破棄によって発火されるbeforeデータ画像削除メソッドコントローラ。
    /// メソッド内部でログ通知のタイプを判定し、処理を分岐する。
    /// アイテム追加時を除き、対象アイテムがすでに取り消し実行済みだった場合、処理を行わない。
    func deleteBeforeUIImageController(element: Log) {
        switch element.type {
        case .addItem(let item):
            deleteBeforeUIImage(path: item.photoPath)
        case .deleteItem(let item):
            if element.canceledDatas.contains(where:{ $0 == item.createTime}) { return }
            deleteBeforeUIImage(path: item.photoPath)
        case .updateItem(let item):
            if element.canceledDatas.contains(where:{ $0 == item.before.createTime}) { return }
            deleteBeforeUIImage(path: item.before.photoPath)
        case .updateUser(let user):
            if element.canceledDatas.contains(where:{ $0 == user.before.createTime}) { return }
            deleteBeforeUIImage(path: user.before.iconPath)
        case .updateTeam(let team):
            if element.canceledDatas.contains(where:{ $0 == team.before.createTime}) { return }
            deleteBeforeUIImage(path: team.before.iconPath)
        case .commerce, .join:
            break
        }
    }
    /// データ内の画像が変更されている or データが削除された状態で、変更をキャンセルせずに通知を破棄した時、
    /// beforeデータの画像を削除するメソッド。
    func deleteBeforeUIImage(path imagePath: String?) {
        guard let imagePath else { return }

        let storage = Storage.storage()
        let reference = storage.reference()
        let imageRef = reference.child(imagePath)

        imageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                print("beforeデータの画像削除成功!")
            }
        }
    }

    func removeListener() {
        listener?.remove()
    }

    deinit {
        listener?.remove()
    }
}

/// 通知関連のエラーを管理するクラス。
enum NotificationError: Error {
    case missingData
    case resetUpdatedItem
    case resetAddedItem
    case resetDeletedItem
    case resetUpdatedUser
    case noSnapShotExist
    case noDocumentExist
}
