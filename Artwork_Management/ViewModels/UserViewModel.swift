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

enum CustomError: Error {
    case uidEmpty, getItemID, getRef, fetch, setData, updateData, getDocument,getUserDocument, photoUrlEmpty, userEmpty, teamEmpty, getDetectUser, inputTextEmpty, memberDuplication, addTeamIDToJoinedUser, createAnonymous, existUserDocument, existAccountEmail, deleteAccount
}

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

    /// 新規加入チームのjoinTeamデータを保持するプロパティ。
    /// リスナーが受け取ったjoinTeamのapprovedがfalseだと、
    /// このプロパティにデータが格納される。
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
    @Published var showAlert = false
    @Published var userErrorMessage = ""

    /// 自身のユーザードキュメントを取得するメソッド。
    @MainActor
    func fetchUser() async throws {
        guard let uid else { throw CustomError.uidEmpty }
        let userRef = db?
            .collection("users")
            .document(uid)

        do {
            let document = try await userRef?.getDocument(source: .default)
            let user = try await document?.data(as: User.self)
            self.user = user
        } catch {
            throw UserRelatedError.failedFetchAddedNewUser
        }
    }

    func getUserData(id userId: String) async -> User? {

        do {
            return try await User.fetch(path: .users, docId: userId)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
            return nil
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
            return nil
        }
    }

    /// 自身の所属するチームデータ「joins」を取得するメソッド。
    @MainActor
    func fetchJoinTeams() async throws {
        guard let uid else { throw CustomError.uidEmpty }

        do {
            let snapshot = try await db?
                .collection("users")
                .document(uid)
                .collection("joins")
                .getDocuments(source: .default)

            guard let documents = snapshot?.documents else {
                throw UserRelatedError.missingSnapshot
            }

            for document in documents {
                let joinTeam = try document.data(as: JoinTeam.self)

                self.joins.append(joinTeam)
            }
        } catch {
            print("ERROR: JoinTeam取得失敗")
            return
        }
    }

//    /// ユーザーのアカウントステートを返すメソッド。
//    func isAnonymousCheck() {
//        
//        if let user = Auth.auth().currentUser, user.isAnonymous {
//            self.isAnonymous = true
//        } else {
//            self.isAnonymous = false
//        }
//    }

    /// ユーザーデータの更新をリスニングするスナップショットリスナー。
    func userListener() async throws {
        guard let uid else { throw UserRelatedError.uidEmpty }

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

                    withAnimation {
                            self.user = userData
//                        DispatchQueue.main.async {
//                            self.isAnonymousCheck()
//                        }
                    }
                } catch {
                    print("ERROR: ユーザーデータのリスナー失敗")
                    return
                }
            }
    }

    /// 参加チームデータ群「joins」の更新をリスニングするスナップショットリスナー。
    func joinsListener() async throws {
        guard let uid else { throw UserRelatedError.uidEmpty }

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
    
    func updateLastLogInTeam(teamId: String?) async throws {
        guard var user, let teamId else { throw UserRelatedError.missingData }

        user.lastLogIn = teamId

        do {
            try db?
                .collection("users")
                .document(user.id)
                .setData(from: user)
        } catch {
            throw UserRelatedError.failedUpdateLastLogIn
        }
    }

    /// 参加チーム群の配列から現在操作しているチームのインデックスを取得するメソッド
    func getCurrentJoinsIndex() -> Int? {
        guard let user else { return nil }
        var getIndex: Int?

        getIndex = self.joins.firstIndex(where: { $0.id == user.lastLogIn })
        return getIndex
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
    func updateHomeEdits(data EditedData: HomeEditData) async throws {
        guard let uid else { return }

        let currentIndex = getCurrentJoinsIndex()
        guard let currentIndex else { return }
        var myJoinTeam = self.joins[currentIndex]

        // Homeエディットデータを更新
        myJoinTeam.homeEdits = EditedData

        do {
            try db?
                .collection("users")
                .document(uid)
                .collection("joins")
                .document(myJoinTeam.id)
                .setData(from: myJoinTeam)
        } catch {
            throw UserRelatedError.failedHomeEdits
        }
    }

    func updateJoinTeamBackground(data newBackground: Background) async throws {
        guard let uid, var currentJoinTeam else {
            throw UserRelatedError.missingData
        }
        // 背景のアップデート
        currentJoinTeam.currentBackground = newBackground

        do {
            try db?
                .collection("users")
                .document(uid)
                .collection("joins")
                .document(currentJoinTeam.id)
                .setData(from: currentJoinTeam)
        } catch {
            throw UserRelatedError.failedUpdateBackground
            print("ERROR: チーム背景のアップデートに失敗しました")
        }
    }
    /// ユーザーのお気に入りアイテム追加or削除を管理するメソッド。
    /// お気に入りアイテムのIDをFirestoreのuserドキュメントに保管する。
    func updateFavorite(_ itemID: String?) {
        guard var userData = user else { return }
        guard let itemID else { return }

        let index = userData.favorites.firstIndex(where: { $0 == itemID })
        if let index {
            userData.favorites.remove(at: index)
        } else {
            userData.favorites.append(itemID)
        }

        do {
            try? db?
                .collection("users")
                .document(userData.id)
                .setData(from: userData)
            hapticActionNotification()
        }
    }

    /// 新規チーム作成時に使用するメソッド。作成者のメンバーデータを新規チームのサブコレクションに保存する。
    func addNewJoinTeam(data newJoinTeam: JoinTeam) async throws {
        guard let uid else { throw CustomError.uidEmpty }
        let joinTeamRef = db?
            .collection("users")
            .document(uid)
            .collection("joins")
            .document(newJoinTeam.id)

        do {
            _ = try joinTeamRef?.setData(from: newJoinTeam)
        }
        catch {
            throw UserRelatedError.failedCreateJoinTeam
        }
    }

    /// ユーザーデータの更新をFirestoreに保存するメソッド。
    func updateUser(from updatedUserData: User) async throws {
        guard let user else { throw CustomError.userEmpty }

        do {
            try db?
                .collection("users")
                .document(user.id)
                .setData(from: updatedUserData)
        } catch {
            // 保存予定だったアイコンデータをfirestorageから削除
            await deleteUserImageData(path: updatedUserData.iconPath)
            print("ERROR: updateUser")
        }
    }
    
    func updateUserEmailAddress(email updateEmail: String) async {
        guard var user else { return }
        
        do {
            user.address = updateEmail
            try db?
                .collection("users")
                .document(user.id)
                .setData(from: user)
        } catch {
            print("新しいメールアドレスのFirebaseへの保存に失敗しました")
            return
        }
    }

    /// ユーザーのテーマカラーを更新するメソッド
    func updateUserThemeColor(selected selectedColor: ThemeColor) {
        guard var user else { return }
        // テーマカラーを更新
        user.userColor = selectedColor

        do {
            try db?
                .collection("users")
                .document(user.id)
                .setData(from: user)
        } catch {
            print("ユーザーテーマカラーの保存失敗")
            return
        }
    }
    /// 更新されたJoinTeamデータを、チーム所属メンバーそれぞれが持つ所属チーム情報joinsに反映させる。
    func updateJoinTeamToMembers(data updatedJoinTeam: JoinTeam, ids membersId: [String]) async throws {
        // メンバー全員のアップデート対象JoinTeamサブコレクションリファレンスを取得
        membersId.map { memberId in
            do {
                try db?
                    .collection("users")
                    .document(memberId)
                    .collection("joins")
                    .document(updatedJoinTeam.id)
                    .setData(from: updatedJoinTeam)
            } catch {
                print("ERROR: \(memberId)のjoinTeam更新失敗")
            }
        }
    }
    /// チーム参加を許可したユーザーに対して、チーム情報（joinTeam）を渡すメソッド。
    /// Firestoreのusersコレクションの中から、相手ユーザードキュメントのサブコレクション（joins）にデータをセットする。
    func passJoinTeamToNewMember(for newMember: User) async {
        guard let joinTeamData = self.currentJoinTeam else {
            assertionFailure("joinTeamデータが存在しません")
            return
        }

        // 自身のjoinTeamデータを相手に渡すデータとしてコピー
        var passJoinTeam = joinTeamData
        // approvedをfalseとして渡すことで、相手に届いた時に参加通知が発火する
        passJoinTeam.approved = false

        do {
            try await User.setJoinTeam(userId: newMember.id, data: passJoinTeam)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// joinTeamデータのプロパティ「approved」をtrueにするメソッド。
    /// 他チームからの承諾によって新規チームが追加された時、ユーザーに追加を知らせるのに
    /// approvedの値を用いる。
    func setApprovedJoinTeam(to newJoinTeam: JoinTeam?) async throws {
        guard let uid, var newJoinTeam else { throw UserRelatedError.uidEmpty }
        // 加入の既読を付ける
        newJoinTeam.approved = true

        do {
            try db?
                .collection("users")
                .document(uid)
                .collection("joins")
                .document(newJoinTeam.id)
                .setData(from: newJoinTeam)
        } catch {
            print("ERROR: 新規加入チームの既読失敗")
            throw UserRelatedError.failedUpdateJoinTeamApproved
        }
    }

    /// ユーザーが現在のチーム内で選択した背景画像をFireStorageに保存する。
    func uploadMyNewBackground(_ image: UIImage?) async -> (url: URL?, filePath: String?) {

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }
        guard let user else { return (url: nil, filePath: nil) }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "users/\(user.id)/myBackgrounds/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        } catch {
            print("背景データの保存失敗")
            return (url: nil, filePath: nil)
        }
    }

    /// ユーザーが写真フォルダから選択したオリジナル背景をFirestoreに保存するメソッド。
    /// 画像はユーザーのドキュメントデータ「myBackgrounds」に保管される。
    func setMyNewBackground(url imageURL: URL?, path imagePath: String?) async {
        guard var user else { return }
        /// 受け取った画像データを元に、保存用の背景データ作成
        user.myBackgrounds.append(
            Background(category: "original",
                       imageName: "",
                       imageURL: imageURL,
                       imagePath: imagePath))

        do {
            try db?
                .collection("users")
                .document(user.id)
                .setData(from: user)

        } catch {
            print("ERROR: チーム背景の保存に失敗しました。")
        }
    }

    func deleteMyBackground(_ background: Background) {
        guard var user = user else { return }

        /// 対象背景データを削除
        user.myBackgrounds.removeAll(where: { $0 == background })

        do {
            try db?
                .collection("users")
                .document(user.id)
                .setData(from: user, merge: true)

        } catch {
            print("ERROR: チーム背景の保存に失敗しました。")
        }
    }

    /// ユーザーアイコンをFirestorageに保存するメソッド。
    /// filePathは「users/\(Date()).jpeg」
    func uploadUserImage(_ image: UIImage?) async -> (url: URL?, filePath: String?) {
        guard let user,
              let imageData = image?.jpegData(compressionQuality: 0.8) else {
            print("ユーザーアイコンのアップロード失敗")
            return (url: nil, filePath: nil)
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "users/\(user.id)\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath) // 成功
        } catch {
            return (url: nil, filePath: nil)
        }
    }

    func resizeUIImage(image: UIImage?, width: CGFloat) -> UIImage? {

        if let originalImage = image {
            // オリジナル画像のサイズからアスペクト比を計算
            let aspectScale = originalImage.size.height / originalImage.size.width

            // widthからアスペクト比を元にリサイズ後のサイズを取得
            let resizedSize = CGSize(width: width * 3, height: width * Double(aspectScale) * 3)

            // リサイズ後のUIImageを生成して返却
            UIGraphicsBeginImageContext(resizedSize)
            originalImage.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return resizedImage
        } else {
            return nil
        }
    }

    /// 対象チーム内の自身のメンバーデータ「JoinMember」を削除するメソッド。
    /// チーム脱退操作が実行された時に使われる。
    func deleteJoinTeamFromMyData(for selectedTeam: JoinTeam) async throws {
        guard let uid else { throw TeamRelatedError.uidEmpty }

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

struct TestUser {
    let testUser: User = User(id: "sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424", iconURL: nil, iconPath: nil, userColor: .red, joinsId: [])
}
