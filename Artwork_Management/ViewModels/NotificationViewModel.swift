//
//  TeamNotificationViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/04.
//

import SwiftUI
import Firebase
//import FirebaseStorage
import FirebaseFirestore

/// チーム全体に届くデータの追加・更新・削除通知を管理するクラス。
/// チームドキュメントのサブコレクション「logs」から、自身が未読のログをクエリ取得して通知表示する。
class NotificationViewModel: ObservableObject, FirebaseErrorHandling {

    init() { print("<<<<<<<<<  NotificationViewModel_init  >>>>>>>>>") }

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var listener: ListenerRegistration?
    var uid: String? { Auth.auth().currentUser?.uid }

    /// ユーザーがまだ確認していない未読のチーム通知。このプロパティ内の通知が空になるまで
    /// currentNotificationへの格納 -> 破棄 -> 格納 が続く。
    @Published var unreadLogs: [Log] = []

    /// 現在表示されている通知を保持するプロパティ。
    @Published var currentNotification: Log?

    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    func listener(id currentTeamId: String?) {

        guard let uid, let currentTeamId else {
            assertionFailure("uid, teamId: nil")
            return
        }

        // 現在操作しているチームのLogデータの中から、未読のログを検索取得する
        // read == falseの場合、未読ログであることを表す
        listener = Firestore.firestore()
            .collection("teams")
            .document(currentTeamId)
            .collection("members")
            .document(uid)
            .collection("logs")
            .whereField("read", in: [false]) // 未読のログを検索
            .limit(to: 10)
            .addSnapshotListener { (snapshot, error) in

                if let error { self.handleErrors([error]); return }

                self.unreadLogs = snapshot!.documents.compactMap { (snap) -> Log? in
                    do {
                        return try snap.data(as: Log.self, with: .estimate)
                    } catch {
                        self.handleErrors([error])
                        return nil
                    }
                }

                self.createTimeSort()

                // 現在表示されている通知が無く、かつ未読の通知が残っていれば新たに通知を格納する
                if self.currentNotification == nil {
                    guard let nextNotification = self.unreadLogs.first else { return }
                    self.currentNotification = nextNotification
                }

                // 現在表示されているログ通知で取り消し処理が実行された時、ログのステータス更新を反映させる
                if let updatedLog = self.unreadLogs.first(where: { $0.id == self.currentNotification?.id }) {
                    self.currentNotification = updatedLog
                }
            }
    }

    /// ユーザーが既に表示した通知に既読を付けるメソッド。
    /// 対象のログが持っているIdを用いて、ログの既読を管理する「read」プロパティをtrueにする。
    func setReadLog(team: Team?, element: Log) async {
        guard let team, let uid else { assertionFailure("team, uid: nil"); return }

        do {
            var logToUpdate = element
            logToUpdate.read = true // 既読

            try await Log.setData(.logs(teamId: team.id, memberId: uid), docId: element.id, data: logToUpdate)

        } catch {
            handleErrors([error])
        }
    }

    /// ユーザーが通知ビューに記載している更新内容をキャンセルした場合に発火する、更新内容のリセットメソッドコントローラ。
    /// ログのタイプをメソッド内で参照し、タイプごとで実行メソッドを分岐ハンドリングする。
    /// - Parameters:
    ///   - team: リセット処理を行う対象のチーム。現在操作しているCurrentTeamが格納される。
    ///   - element: 現在操作を行っているログ通知の要素データ。ログの要素とタイプが格納されている。
    ///   - selectedIndex: 通知ログのタイプが複数のデータを扱うタイプの場合(カート処理など)に、
    ///   リセット対象のアイテムをハンドリングするための配列インデックス。
    func resetLogController(to team: Team?, element: Log, index selectedIndex: Int? = nil) async {

        switch element.logType {

        case .addItem(let item):
            await resetItemToAdd(item, to: team, element: element)

        case .updateItem(let item):
            await resetItemToUpdate(item, to: team, element: element)

        case .deleteItem(let item):
            await resetItemToDelete(item, to: team, element: element)

        case .commerce(let items):
            guard let index = selectedIndex else { return }
            await resetItemsToCommerce(items[index], to: team, element: element)

        case .join: break

        case .updateUser(let user):
            await resetUserUpdate(user.before, to: team, element: element)

        case .updateTeam(let team):
            await resetTeamUpdate(to: team.before, element: element)
        }
    }

    /// アイテムデータの追加をキャンセルし削除するメソッド。
    /// アイテムのidはFirestoreに保存される時に生成されるため、
    /// 一度アイテムをフェッチし、ドキュメントIDを取得する工程が必要である。
    private func resetItemToAdd(_ addedItem: Item, to team: Team?, element: Log) async {
        guard let team else { assertionFailure("team: nil"); return }

        do {
            try await Item.deleteDocument(.items(teamId: team.id), docId: addedItem.id)
            try await setLogReseted(to: team, id: addedItem.id, element: element)

        } catch {
            handleErrors([error])
        }
    }

    /// アイテムのデータ更新を取り消すメソッド。
    private func resetItemToUpdate(_ item: CompareItem, to team: Team?, element: Log) async {
        guard let team else { assertionFailure("team: nil"); return }

        do {
            try await Item.setData(.items(teamId: team.id), docId: item.before.id, data: item.before)
            try await setLogReseted(to: team, id: item.before.id, element: element)

        } catch {
            handleErrors([error])
        }
    }

    /// アイテムデータの削除をキャンセルし、元に戻すメソッド。
    private func resetItemToDelete(_ deletedItem: Item, to team: Team?, element: Log) async {
        guard let team else { assertionFailure("team: nil"); return }

        do {
            // 削除アイテムを復元
            try await Item.setData(.items(teamId: team.id), docId: deletedItem.id, data: deletedItem)
            try await setLogReseted(to: team, id: deletedItem.id, element: element)

        } catch {
            handleErrors([error])
        }
    }

    /// カート精算されたアイテムの処理をキャンセルし、データを元に戻すメソッド。
    func resetItemsToCommerce(_ item: CompareItem, to team: Team?, element: Log) async {
        guard let team else { assertionFailure("team: nil"); return }

        do {
            // 現在のアイテムデータを取得
            let currentItem: Item = try await Item.fetch(.items(teamId: team.id), docId: item.before.id)
            // 在庫処理時のパラメータ変動を計算し、現在のアイテムデータに取り消し反映
            let resetedItem = resetCommerceDiffCalculate(compare: item, currentItem: currentItem)

            try await Item.setData(.items(teamId: team.id), docId: resetedItem.id, data: resetedItem)
            try await setLogReseted(to: team, id: resetedItem.id, element: element)

        } catch {
            handleErrors([error])
        }
    }

    /// 在庫処理が取り消しされた時に使用するメソッド。
    /// 在庫処理された当時のbeforeとafterの差分を計算し、現在のアイテムステータスに対して差分を反映させたデータを返す。
    private func resetCommerceDiffCalculate(compare: CompareItem, currentItem: Item) -> Item {

        // 在庫処理前と後の差分を算出
        let salesDiff = compare.after.sales - compare.before.sales
        let inventoryDiff = compare.before.inventory - compare.after.inventory
        let amountDiff = compare.after.totalAmount - compare.before.totalAmount

        var itemToUpdate = currentItem
        itemToUpdate.sales -= salesDiff // 現在のデータから売り上げを引く
        itemToUpdate.inventory += inventoryDiff // 現在のデータから在庫を足す
        itemToUpdate.totalAmount -= amountDiff // 現在のデータから売個数を引く

        return itemToUpdate
    }

    /// ユーザーデータの更新をキャンセルし元に戻すメソッド。
    private func resetUserUpdate(_ beforeUser: User?, to team: Team?, element: Log) async {

        guard let beforeUser, let team else { assertionFailure("beforeUser, team: nil"); return }

        do {
            // 自身のuserデータをリセット
            try await User.setData(.users, docId: beforeUser.id, data: beforeUser)

            // 自身のjoinMemberデータを用意し、各ステータスをリセット
            var myMemberToReset: JoinMember = try await JoinMember.fetch(.members(teamId: team.id), docId: beforeUser.id)
            myMemberToReset.name = beforeUser.name
            myMemberToReset.iconURL = beforeUser.iconURL

            // 所属チーム全てのリファレンスを取得し、用意したリセットデータを保存
            let myJoinTeamRefs = try await JoinTeam.getDocuments(.joins(userId: beforeUser.id))

            for teamRef in myJoinTeamRefs.documents {
                let teamId = teamRef.documentID
                try await JoinTeam.setData(.members(teamId: teamId), docId: beforeUser.id, data: myMemberToReset)
            }

            // ログにリセット処理済みであることを保存
            try await setLogReseted(to: team, id: beforeUser.id, element: element)

        } catch {
            handleErrors([error])
        }
    }

    /// チームデータの更新をキャンセルし元に戻すメソッド。
    private func resetTeamUpdate(to beforeTeam: Team?, element: Log) async {

        guard let beforeTeam, let uid else { assertionFailure("beforeTeam, uid: nil"); return }

        do {
            // 対象のteamデータをリセット
            try await Team.setData(.teams, docId: beforeTeam.id, data: beforeTeam)

            // 対象チームのjoinTeamデータを用意し、各ステータスをリセット
            var joinTeamToReset: JoinTeam = try await JoinTeam.fetch(.joins(userId: uid), docId: beforeTeam.id)
            joinTeamToReset.name = beforeTeam.name
            joinTeamToReset.iconURL = beforeTeam.iconURL

            // 所属チーム全てのリファレンスを取得し、用意したリセットデータを保存
            let teamMemberRefs = try await JoinMember.getDocuments(.members(teamId: beforeTeam.id))

            for memberRef in teamMemberRefs.documents {
                let memberId = memberRef.documentID
                try await JoinMember.setData(.joins(userId: memberId), docId: beforeTeam.id, data: joinTeamToReset)
            }

            // ログにリセット処理済みであることを保存
            try await setLogReseted(to: beforeTeam, id: beforeTeam.id, element: element)

        } catch {
            handleErrors([error])
        }
    }

    /// チームの各メンバーのログデータに、変更内容のキャンセル実行を反映させるメソッド。
    /// キャンセル処理の重複を避けるために必要である。
    /// ログデータの「canceledIds」にデータのcreateTimeを格納する。
    private func setLogReseted(to team: Team?, id canceledDataId: String, element: Log) async throws {
        guard let team, let uid else { assertionFailure("team, uid: nil"); return }

        do {
            try await Log.setLogReseted(userId: uid, teamId: team.id, log: element, canceledDataId: canceledDataId)
        }
    }

    /// ログ通知が画面から破棄された時に実行される画像データ削除コントローラ。
    /// メソッド内部でログ通知のタイプを判定し、処理を分岐する。
    func deleteUnusedImageController(element: Log) async {

        switch element.logType {

        case .addItem(let item):
            // アイテム追加が取り消しされていた場合、画像を削除
            if checkReseted(log: element, to: item.id) {
                await deleteImage(path: item.photoPath)
            }

        case .deleteItem(let item):
            // アイテム削除が取り消しされていない場合、画像を削除
            if !checkReseted(log: element, to: item.id) {
                await deleteImage(path: item.photoPath)
            }

        case .updateItem(let item):
            // beforeとafterで画像が同じの場合、処理終了
            if item.before.photoPath == item.after.photoPath { return }

            if checkReseted(log: element, to: item.before.id) {
                await deleteImage(path: item.after.photoPath)
            } else {
                await deleteImage(path: item.before.photoPath)
            }

        case .updateUser(let user):
            // beforeとafterで画像が同じの場合、処理終了
            if user.before.iconPath == user.after.iconPath { return }

            if checkReseted(log: element, to: user.before.id) {
                await deleteImage(path: user.after.iconPath)
            } else {
                await deleteImage(path: user.before.iconPath)
            }

        case .updateTeam(let team):

            // beforeとafterで画像が同じの場合、処理終了
            if team.before.iconPath == team.after.iconPath { return }

            if checkReseted(log: element, to: team.before.id) {
                await deleteImage(path: team.after.iconPath)
            } else {
                await deleteImage(path: team.before.iconPath)
            }

        case .commerce, .join:
            break
        }
    }

    /// 対象ログをメンバー全員が既読済みかどうかを検索判定するメソッド。
    func isLogReadByAllMembers(log: Log, teamId: String?, members: [JoinMember]) async -> Bool {

        guard let teamId else { assertionFailure("teamId: nil"); return false }

        do {
            return try await Log.isLogReadByAllMembers(log: log, teamId: teamId, members: members)

        } catch {
            handleErrors([error])
            return false
        }
    }

    /// 対象データの 追加/更新/削除/在庫処理 の操作が取り消しされているかを判定するメソッド。
    private func checkReseted(log: Log, to dataId: String) -> Bool {
        return log.canceledIds.contains(where:{ $0 == dataId })
    }

    /// データ内の画像が変更されている or データが削除された状態で、変更をキャンセルせずに通知を破棄した時、
    /// beforeデータの画像を削除するメソッド。
    private func deleteImage(path imagePath: String?) async {
        guard let imagePath else { return }

        do {
            try await FirebaseStorageManager.deleteImage(path: imagePath)
        } catch {
            handleErrors([error])
        }
    }

    func createTimeSort() {
        unreadLogs.sort { before, after in
            before.createTime > after.createTime ? true : false
        }
    }

    func removeListener() {
        listener?.remove()
    }

    deinit {
        removeListener()
    }
}
