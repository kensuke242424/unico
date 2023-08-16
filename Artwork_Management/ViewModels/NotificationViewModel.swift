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
                // 
                self.createTimeSort()

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
    /// 対象のログが持っているIdを用いて、ログの既読を管理する「read」プロパティをtrueにする。
    func setRead(team: Team?, element: Log) {
        guard let team, let uid else { return }

        do {
            var updatedElement = element
            updatedElement.read = true

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

        switch element.logType {

        case .addItem(let item):
            try await resetAddedItem(item, to: team, element: element)

        case .updateItem(let item):
            try await resetUpdatedItem(item, to: team, element: element)

        case .deleteItem(let item):
            try await resetDeletedItem(item, to: team, element: element)

        case .commerce(let items):
            guard let index = selectedIndex else {
                print("カート精算アイテムのインデックス取得失敗")
                throw NotificationError.missingCommerceIndex
            }
            try await resetCommerceItem(items[index], to: team, element: element)

        case .join:
            break

        case .updateUser(let user):
            try await resetUpdateUser(user.before, to: team, element: element)

        case .updateTeam(let team):
            try await resetUpdateTeam(to: team.before, element: element)
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
            try await setReseted(to: team, id: itemId, element: element)
        }
        catch {
            throw NotificationError.resetAddedItem
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

    /// アイテムデータの削除をキャンセルし、元に戻すメソッド。
    func resetDeletedItem(_ deletedItem: Item, to team: Team?, element: Log) async throws {
        guard let team, let itemId = deletedItem.id else {
            throw NotificationError.missingData
        }

        do {
            try await db?
                .collection("teams")
                .document(team.id)
                .collection("items")
                .document(itemId)
                .setData(from: deletedItem)

            try await setReseted(to: team, id: itemId, element: element)
        }
        catch {
            throw NotificationError.resetDeletedItem
        }
    }

    /// カート精算されたアイテムの処理をキャンセルし、データを元に戻すメソッド。
    func resetCommerceItem(_ item: CompareItem, to team: Team?, element: Log) async throws {
        guard let team, let itemId = item.before.id else {
            throw NotificationError.missingData
        }

        // 売り上げの取り消し値
        let salesDiff = item.after.sales - item.before.sales
        // 在庫の取り消し値
        let inventoryDiff = item.before.inventory - item.after.inventory

        let amountDiff = item.after.totalAmount - item.before.totalAmount

        let itemRef = db?
            .collection("teams")
            .document(team.id)
            .collection("items")
            .document(itemId)

        do {
            // 現在のアイテムデータを取得
            let document = try await itemRef?.getDocument()
            var itemData = try await document?.data(as: Item.self)

            guard var itemData else { throw NotificationError.missingItem }

            itemData.sales -= salesDiff // 現在のデータから売り上げを引く
            itemData.inventory += inventoryDiff // 現在のデータから在庫を足す
            itemData.totalAmount -= amountDiff // 現在のデータから売個数を引く

            // 取り消し反映後のアイテムデータを再保存
            try await itemRef?.setData(from: itemData)
            // リセット済みであることを各メンバーのログに反映
            try await setReseted(to: team, id: itemId, element: element)
        } catch {
            print("ERROR: カート精算アイテムのリセット失敗")
            throw NotificationError.resetCommerceItem
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
            try await setReseted(to: team, id: beforeUser.id, element: element)
        }
        catch {
            throw NotificationError.resetUpdatedUser
        }

        // 👦👩 ------- 自身の所属するチームのメンバーデータ処理 ---------👩👦

        /// ユーザーが所属している全てのチームのidを取り出す。
        let joinTeamIds = try await getJoinsId()
        // 各所属チームの「members」サブコレクション内にある自身のメンバーデータリファレンスを生成
        let joinTeamsMyMemberRefs = joinTeamIds?.compactMap { teamId in
            let teamMembersRef = db?
                .collection("teams")
                .document(teamId)
                .collection("members")
                .document(beforeUser.id)
            return teamMembersRef
        }

        guard let joinTeamsMyMemberRefs else { throw NotificationError.missingData }

        // 各所属チームごとに自身のメンバーデータを更新していく
        for TeamMyMemberRef in joinTeamsMyMemberRefs {
            do {
                // チームが持つ自身のメンバーデータを取得
                let document = try await TeamMyMemberRef.getDocument()
                var myMemberData = try await document.data(as: JoinMember.self)
                // 取り消し内容を反映
                myMemberData.name = beforeUser.name
                myMemberData.iconURL = beforeUser.iconURL

                try await TeamMyMemberRef.setData(from: myMemberData)
            }
            catch {
                throw NotificationError.resetUpdatedUser
            }
        }
    }

    /// チームデータの更新をキャンセルし元に戻すメソッド。
    func resetUpdateTeam(to beforeTeam: Team?, element: Log) async throws {
        guard let beforeTeam else {
            throw NotificationError.missingData
        }
        // 👦 ------- チームドキュメント処理 ---------👦
        let teamRef = db?
            .collection("teams")
            .document(beforeTeam.id)

        do {
            try await teamRef?.setData(from: beforeTeam)
            try await setReseted(to: beforeTeam, id: beforeTeam.id, element: element)
        }
        catch {
            throw NotificationError.resetUpdatedTeam
        }

        // 👦👩 ------- チームに所属するメンバーのjoinTeamデータ処理 ---------👩👦

        // チームに所属しているメンバーのIdを取得
        let membersId = try await getMembersId(teamId: beforeTeam.id)
        // 各メンバーが持つjoinsサブコレクション内の、編集対象チームリファレンスを作成
        let membersJoinTeamRefs = membersId?.compactMap { memberId in
            let memberJoinTeamRef = db?
                .collection("users")
                .document(memberId)
                .collection("joins")
                .document(beforeTeam.id)
            return memberJoinTeamRef
        }

        guard let membersJoinTeamRefs else { throw NotificationError.missingData }

        for memberJoinTeamRef in membersJoinTeamRefs {
            do {
                // メンバーが持つJoinTeamデータを取得
                let document = try await memberJoinTeamRef.getDocument()
                var joinTeamData = try await document.data(as: JoinTeam.self)
                // 取り消し内容を反映
                joinTeamData.name = beforeTeam.name
                joinTeamData.iconURL = beforeTeam.iconURL
                // 再保存
                try await memberJoinTeamRef.setData(from: joinTeamData)
            }
            catch {
                throw NotificationError.resetUpdatedTeam
            }
        }
    }

    /// チームの各メンバーのログデータに、変更内容のキャンセル実行を反映させるメソッド。
    /// キャンセル処理の重複を避けるために必要である。
    /// ログデータの「canceledIds」にデータのcreateTimeを格納する。
    func setReseted(to team: Team?, id canceledDataId: String, element: Log) async throws {
        guard let team, let uid else { throw NotificationError.missingData }

        /// ログデータに削除済みデータのcreateTimeを格納
        var updatedElement = element
        updatedElement.canceledIds.append(canceledDataId)

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
            // ログのセットタイプが.localの場合、ユーザー自身のログのみ更新する
            if element.logType.setRule == .global || memberId == uid {
                try await logRef?.updateData(["canceledIds": FieldValue.arrayUnion([canceledDataId])])
            }
        }
    }

    /// 通知の破棄によって発火されるbeforeデータ画像削除メソッドコントローラ。
    /// メソッド内部でログ通知のタイプを判定し、処理を分岐する。
    /// アイテム追加時を除き、対象アイテムがすでに取り消し実行済みだった場合、処理を行わない。
    func deleteBeforeUIImageController(element: Log) {
        switch element.logType {
        case .addItem(let item):
            deleteBeforeUIImage(path: item.photoPath)
        case .deleteItem(let item):
            if element.canceledIds.contains(where:{ $0 == item.id}) { return }
            deleteBeforeUIImage(path: item.photoPath)
        case .updateItem(let item):
            if element.canceledIds.contains(where:{ $0 == item.before.id}) { return }
            deleteBeforeUIImage(path: item.before.photoPath)
        case .updateUser(let user):
            if element.canceledIds.contains(where:{ $0 == user.before.id}) { return }
            deleteBeforeUIImage(path: user.before.iconPath)
        case .updateTeam(let team):
            if element.canceledIds.contains(where:{ $0 == team.before.id}) { return }
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

    func createTimeSort() {
        notifications.sort { before, after in
            before.createTime > after.createTime ? true : false
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
    case missingItem
    case resetUpdatedItem
    case resetAddedItem
    case resetDeletedItem
    case resetCommerceItem
    case resetUpdatedUser
    case resetUpdatedTeam
    case noSnapShotExist
    case noDocumentExist
    case missingCommerceIndex
}
