//
//  UserViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserViewModel: ObservableObject {

    init() {
        print("<<<<<<<<<  UserViewModel_init  >>>>>>>>>")
//        isAnonymousCheck()
    }

    var userListener: ListenerRegistration?
    var joinsListener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { return Auth.auth().currentUser?.uid }

    @Published var user: User?
    @Published var joins: [JoinTeam] = []

    @Published var showAlert = false
    @Published var userErrorMessage = ""

    /// 新規加入チームのjoinTeamデータを保持するプロパティ。
    /// リスナーが受け取ったjoinTeamのapprovedがfalseだと、このプロパティにデータが格納される。
    /// 加入通知をユーザーが確認した時点で、approvedはtrueとなる。
    @Published var newJoinedTeam: JoinTeam?
    @Published var showJoinedTeamInformation: Bool = false

    var memberColor: ThemeColor {
        return user?.userColor ?? ThemeColor.blue
    }
    var currentJoinsIndex: Int? {
        let index = self.joins.firstIndex(where: { $0.id == user?.lastLogIn })
        return index
    }
    /// ユーザーが現在操作しているチームの背景データ
    var currentTeamBackground: Background? {
        guard let index = currentJoinsIndex else { return nil }
        let container = self.joins[index].currentBackground
        return container
    }
    var currentJoinTeam: JoinTeam? {
        guard let index = currentJoinsIndex else { return nil }
        return self.joins[index]
    }
    /// 自身が所属している全てのチームのチームIDを格納するプロパティ。
    var joinsId: [String] {
        return self.joins.compactMap { $0.id }
    }

    var isAnonymous: Bool {
        if let user = Auth.auth().currentUser, user.isAnonymous {
            return true
        } else {
            return false
        }
    }

    /// FirestoreのUserデータの更新をリスニングするスナップショットリスナー。
    func userListener() async {
        guard let uid else { assertionFailure("uidが存在しません"); return }

        userListener = db?
            .collection("users")
            .document(uid)
            .addSnapshotListener { snap, error in
                if let error {
                    print("ERROR: \(error.localizedDescription)")
                    return
                }

                do {
                    let userData = try snap?.data(as: User.self)
                    self.user = userData

                } catch {
                    print("ERROR: ユーザーデータのリスナー失敗")
                    return
                }
            }
    }

    /// 参加チームデータ群「joins」の更新をリスニングするスナップショットリスナー。
    func joinsListener() async {
        guard let uid else { assertionFailure("uidが存在しません"); return }

        joinsListener = db?
            .collection("users")
            .document(uid)
            .collection("joins")
            .addSnapshotListener { snap, error in
            if let error {
                print("ERROR: \(error.localizedDescription)")
                return
            }
            guard let documents = snap?.documents else {
                print("ERROR: snap_nil")
                return
            }

            do {
                DispatchQueue.main.async {
                    self.joins = documents.compactMap {

                        let getJoinTeam = try? $0.data(as: JoinTeam.self)

                        // 取得したデータのapprovedがfalseなら、相手から承認を受けた新規加入チーム
                        if let approved = getJoinTeam?.approved, !approved {
                            self.newJoinedTeam = getJoinTeam
                        }

                        return getJoinTeam
                    }
                }
            }
        }
    }

    /// 自身のユーザードキュメントを取得し、userプロパティにセットするメソッド。
    @MainActor
    func fetchUser() async {
        guard let uid else { assertionFailure("uidが存在しません"); return }

        do {
            let data: User = try await User.fetch(.users, docId: uid)
            self.user = data

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// 自身が所属するチーム群のデータを「joins」サブコレクションから取得し、joinsプロパティにセットするメソッド。
    @MainActor
    func getJoinTeams() async {
        guard let uid else { assertionFailure("uid: nil"); return }

        do {
            let datas: [JoinTeam] = try await JoinTeam.fetchDatas(.joins(userId: uid))
            self.joins = datas

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// FirestoreからUserデータを取得するメソッド。返り値あり。
    func getUserData(id userId: String) async -> User? {

        do {
            return try await User.fetch(.users, docId: userId)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
            return nil
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
            return nil
        }
    }

    func addOrUpdateUser(userData: User) async throws {
        guard let user else { assertionFailure("user: nil"); return }

        do {
            try await User.setData(.users, docId: user.id, data: userData)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// joinTeamデータの追加/更新を行うメソッド。
    /// 作成者のユーザードキュメントのサブコレクション「joins」に新規チームの情報を保存する。
    func addOrUpdateJoinTeam(data joinTeamData: JoinTeam) async {
        guard let uid else { assertionFailure("uid: nil"); return }

        do {
            try await JoinTeam.setData(.joins(userId: uid),
                                       docId: joinTeamData.id,
                                       data: joinTeamData)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// ユーザーがチーム移動操作時に実行する。自身の操作チーム対象を保持するUserフィールドを更新するメソッド。
    func updateLastLogInTeam(teamId: String?) async throws {
        guard var user else { assertionFailure("user: nil"); return }
        guard let teamId else { assertionFailure("teamId: nil"); return }

        user.lastLogIn = teamId // 操作対象チームを更新

        do {
            try await User.setData(.users, docId: user.id, data: user)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// 参加チーム群の配列から現在操作しているチームのインデックスを取得するメソッド
    func getCurrentJoinsIndex() -> Int? {
        guard let user else { assertionFailure("user: nil"); return nil }

        return self.joins.firstIndex(where: { $0.id == user.lastLogIn })
    }

    func getCurrentTeamMyBackgrounds() -> [Background] {
        if let index = currentJoinsIndex {
            return self.joins[index].myBackgrounds
        } else {
            return []
        }
    }

    /// Homeのパーツ編集設定をFirestoreのドキュメントに保存するメソッド
    /// 現在操作しているチームのJoinTeamデータモデルに保存される
    func updateHomeEdits(data editedData: HomeEditData) async {
        guard let uid else { assertionFailure("uid: nil"); return }
        guard var currentJoinTeam else { assertionFailure("currentJoinTeam: nil"); return }

        // 現在操作チームのHomeパーツエディット情報を更新
        currentJoinTeam.homeEdits = editedData

        do {
            try await JoinTeam.setData(.joins(userId: uid),
                                       docId: currentJoinTeam.id,
                                       data: currentJoinTeam)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    func updateJoinTeamBackground(data newBackground: Background) async {
        guard let uid else { assertionFailure("uid: nil"); return }
        guard var currentJoinTeam else { assertionFailure("currentJoinTeam: nil"); return }

        // 現在操作チームの背景更新
        currentJoinTeam.currentBackground = newBackground

        do {
            try await JoinTeam.setData(.joins(userId: uid),
                                       docId: currentJoinTeam.id,
                                       data: currentJoinTeam)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }
    /// ユーザーのお気に入りアイテム追加or削除を管理するメソッド。
    /// お気に入りアイテムのIDをFirestoreのuserドキュメントに保管する。
    func updateFavorite(_ itemId: String) async {
        guard let user else { assertionFailure("user: nil"); return }

        let updatedUser = toggleUserFavoriteItemStatus(user: user, for: itemId)

        do {
            try await User.setData(.users, docId: user.id, data: updatedUser)
            hapticActionNotification()

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// ユーザーのパラメータ「favorites」をチェックし、対象アイテムに関するお気に入りステータスを更新するメソッド。
    private func toggleUserFavoriteItemStatus(user: User, for itemId: String) -> User {
        // 対象アイテムのお気に入りステータスをチェック（idが存在すればお気に入り済みの状態）
        let index = user.favorites.firstIndex(where: { $0 == itemId })
        var user = user

        if let index {
            user.favorites.remove(at: index)
            return user
        } else {
            user.favorites.append(itemId)
            return user
        }
    }
    
    func updateUserEmailAddress(email updateEmail: String) async {
        guard var user else { assertionFailure("user: nil"); return }

        user.address = updateEmail // 情報を更新

        do {
            try await User.setData(.users, docId: user.id, data: user)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// ユーザーのテーマカラーを更新するメソッド
    func updateUserThemeColor(selected selectedColor: ThemeColor) async {
        guard var user else { assertionFailure("user: nil"); return }
        // テーマカラーを更新
        user.userColor = selectedColor

        do {
            try await User.setData(.users, docId: user.id, data: user)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// チーム情報の更新を、メンバーそれぞれが持つ所属チーム情報joinsに反映させる。
    func updateJoinTeamToMembers(data updatedJoinTeam: JoinTeam, ids membersId: [String]) async {
        // メンバー全員のアップデート対象JoinTeamサブコレクションリファレンスを取得
        for memberId in membersId {
            do {
                try await JoinTeam.setData(.joins(userId: memberId),
                                           docId: updatedJoinTeam.id,
                                           data: updatedJoinTeam)

            } catch let error as FirestoreError {
                print(error.localizedDescription)
            } catch {
                print("未知のエラー: \(error.localizedDescription)")
            }
        }
    }
    /// チームに新規加入するユーザーに対して、チーム情報（joinTeam）を渡すメソッド。
    /// 相手ユーザードキュメントのサブコレクション（joins）にデータをセットする。
    func passJoinTeamToNewMember(for newMember: User) async {
        guard let currentJoinTeam else { assertionFailure("joinTeam: nil"); return }

        // 自身のjoinTeamデータを相手に渡すデータとしてコピー
        var passJoinTeam = currentJoinTeam
        // approvedをfalseとして渡すことで、相手に届いた時に参加通知が発火する
        passJoinTeam.approved = false

        do {
            try await User.setData(.joins(userId: newMember.id),
                                   docId: passJoinTeam.id,
                                   data: passJoinTeam)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// joinTeamデータのパラメータ「approved」をtrueにするメソッド。
    /// 相手チームからのメンバー招待通知の既読を表現する。
    func setApprovedJoinTeam(to newJoinTeam: JoinTeam?) async throws {
        guard let uid else { assertionFailure("uid: nil"); return }
        guard var newJoinTeam else { assertionFailure("newJoinTeam: nil"); return }

        newJoinTeam.approved = true // 加入通知の既読

        do {
            try await JoinTeam.setData(.joins(userId: uid),
                                       docId: newJoinTeam.id,
                                       data: newJoinTeam)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// ユーザーが現在のチーム内で選択した背景画像をFirebaseStorageに保存する。
    func uploadMyNewBackground(_ image: UIImage?) async -> (url: URL?, filePath: String?) {
        guard let uid else { assertionFailure("uid: nil"); return (url: nil, filePath: nil) }

        do {
            return try await FirebaseStorageManager.uploadImage(image, .myBackground(userId: uid))

        } catch let error as FirebaseStorageError {
            print(error.localizedDescription)
            return (url: nil, filePath: nil)

        } catch {
            print("未知のエラー: \(error.localizedDescription)")
            return (url: nil, filePath: nil)
        }
    }

    /// ユーザーが写真フォルダから選択したオリジナル背景をFirestoreに保存するメソッド。
    /// 画像はユーザーのドキュメントデータ「myBackgrounds」に保管される。
    func setMyNewBackground(url imageURL: URL?, path imagePath: String?) async {
        guard var user else { assertionFailure("user: nil"); return }

        /// 受け取った画像データを元に、保存用の背景データ作成
        user.myBackgrounds.append(
            Background(category: "original",
                       imageName: "",
                       imageURL: imageURL,
                       imagePath: imagePath)
        )

        do {
            try await User.setData(.users, docId: user.id, data: user)

        } catch let error as FirestoreError {
            print(error.localizedDescription)

        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    func deleteMyBackground(_ background: Background) async {
        guard var user else { assertionFailure("user: nil"); return }

        /// 対象背景データを削除
        user.myBackgrounds.removeAll(where: { $0 == background })

        do {
            try await User.setData(.users, docId: user.id, data: user)

        } catch let error as FirestoreError {
            print(error.localizedDescription)

        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// ユーザーアイコンをFirestorageに保存するメソッド。
    /// filePathは「users/\(Date()).jpeg」
    func uploadUserImage(_ image: UIImage?) async -> (url: URL?, filePath: String?) {
        guard let uid else { assertionFailure("uid: nil"); return (url: nil, filePath: nil) }

        do {
            return try await FirebaseStorageManager.uploadImage(image, .user(userId: uid))

        } catch let error as FirebaseStorageError {
            print(error.localizedDescription)
            return (url: nil, filePath: nil)

        } catch {
            print("未知のエラー: \(error.localizedDescription)")
            return (url: nil, filePath: nil)
        }
    }

    /// 対象チーム内の自身のメンバーデータ「JoinMember」を削除するメソッド。
    /// チーム脱退操作が実行された時に使われる。
    func deleteJoinTeamFromMyData(for selectedTeam: JoinTeam) async throws {
        guard let uid else { assertionFailure("uid: nil"); return }

        do {
            try await db?
                .collection("users")
                .document(uid)
                .collection("joins")
                .document(selectedTeam.id)
                .delete() // 削除

        } catch {
            print("ERROR: JoinTeamの削除失敗")
            throw UserRelatedError.failedEscapeTeam
        }
    }

    func deleteUserImageData(path: String?) async {

        guard let path = path else { return }

        let storage = Storage.storage()
        let reference = storage.reference()
        let imageRef = reference.child(path)

        imageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                print("imageRef.delete succsess!")
            }
        }
    }

    /// Firestorageに保存されているユーザーのオリジナル背景データを全て削除するメソッド。
    func deleteAllUserMyBackgrounds() {
        guard let user else { return }
        let storage = Storage.storage()
        let reference = storage.reference()

        Task {
            for background in user.myBackgrounds {
                guard let path = background.imagePath else { continue }
                let imageRef = reference.child(path)
                imageRef.delete { error in
                    if let error {
                        print("ERROR: \(error.localizedDescription)")
                    } else {
                        print("オリジナル背景データを削除")
                    }
                }
            }
        }
    }

    /// ユーザードキュメントがサブコレクションとして持っている「joins」データをFirestoreから削除するメソッド。
    func deleteUserJoinsDocuments() async throws {
        guard let uid else { throw CustomError.uidEmpty }

        let joinsRef = try await db?
            .collection("users")
            .document(uid)
            .collection("joins")
            .getDocuments()

        joinsRef?.documents.compactMap {
            $0.reference.delete()
        }
    }
    /// 「users」コレクション内に保存されている自身のユーザードキュメントを削除するメソッド。
    func deleteUserDocument() async throws {
        guard let uid else { throw CustomError.uidEmpty }

        try await db?
            .collection("users")
            .document(uid)
            .getDocument()
            .reference.delete()
    }

    /// Firestore内に保存されているユーザードキュメントを全て削除するメソッド群。
    /// ユーザーがアカウントを削除したときに実行される。
    func deleteAllUserDocumentsController() async throws {
        guard let uid else { throw CustomError.uidEmpty }

        do {
            // ユーザーのオリジナル背景データを削除
            deleteAllUserMyBackgrounds()
            // userドキュメントが持つ所属チームのサブコレクション「joins」を削除
            try await deleteUserJoinsDocuments()
            // userドキュメントを削除
            try await deleteUserDocument()

        } catch {
            print("ERROR: ユーザードキュメント削除失敗")
            throw UserRelatedError.failedDeleteAllUserDocuments
        }
    }

    func removeListener() {
        userListener?.remove()
        joinsListener?.remove()
    }

    deinit {
        userListener?.remove()
        joinsListener?.remove()
    }
}

enum UserRelatedError:Error {
    case uidEmpty
    case joinsEmpty
    case referenceEmpty
    case missingData
    case missingSnapshot
    case failedCreateJoinTeam
    case failedFetchUser
    case failedFetchAddedNewUser
    case failedHomeEdits
    case failedUserListen
    case failedUpdateBackground
    case failedUpdateJoinTeamApproved
    case failedUpdateLastLogIn
    case failedUpdateJoinsMyMemberData
    case failedEscapeTeam
    case failedDeleteAllUserDocuments
}

enum CustomError: Error {
    case uidEmpty, getItemID, getRef, fetch, setData, updateData, getDocument,getUserDocument, photoUrlEmpty, userEmpty, teamEmpty, getDetectUser, inputTextEmpty, memberDuplication, addTeamIDToJoinedUser, createAnonymous, existUserDocument, existAccountEmail, deleteAccount
}
