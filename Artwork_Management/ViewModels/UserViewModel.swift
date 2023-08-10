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
        isAnonymousCheck()
    }

    var userListener: ListenerRegistration?
    var joinsListener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { return Auth.auth().currentUser?.uid }

    @Published var user: User?
    @Published var joins: [JoinTeam] = []
    @Published var joinsCount: Int = 0

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

    @Published var isAnonymous: Bool = false
    @Published var showAlert = false
    @Published var userErrorMessage = ""

    /// 相手チームからチーム加入の承認を受けた場合にtrueとなるプロパティ。
    @Published var isApproved: Bool?

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

    
    func isAnonymousCheck() {
        
        if let user = Auth.auth().currentUser, user.isAnonymous {
            self.isAnonymous = true
        } else {
            self.isAnonymous = false
        }
    }
    /// ユーザーデータの更新をリスニングするスナップショットリスナー。
    func userDataListener() async throws {
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
                        DispatchQueue.main.async {
                            self.isAnonymousCheck()
                        }
                    }
                } catch {
                    print("ERROR: ユーザーデータのリスナー失敗")
                    return
                }
            }
    }

    /// 参加チームデータ群「joins」の更新をリスニングするスナップショットリスナー。
    func joinsDataListener(teamId: String) async throws {
        guard let uid else { throw UserRelatedError.uidEmpty }

        let joinsRef = db?
            .collection("users")
            .document(uid)
            .collection("joins")

        joinsListener = joinsRef?.addSnapshotListener { snap, error in
            if let error = error?.localizedDescription {
                print("ERROR: \(error)")
                return
            }
            guard let documents = snap?.documents else {
                print("ERROR: snap_nil")
                return
            }

            do {
                DispatchQueue.main.async {
                    self.joins = documents.compactMap { (document) -> JoinTeam? in
                        return try? document.data(as: JoinTeam.self)
                    }
                    // 所属チームの数を保存
                    self.joinsCount = self.joins.count
                    print("所属チームの数: \(self.joinsCount)")
                }
            }
        }
    }
    
    func updateLastLogInTeam(teamId: String?) async throws {
        guard var user, let teamId else { throw UserRelatedError.missingData }
        let userRef = db?
            .collection("users")
            .document(user.id)
        do {
            user.lastLogIn = teamId
            _ = try userRef?.setData(from: user)
        } catch {
            print("最新ログインチーム状態のFirestoreへの保存に失敗しました")
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
        let myBackgrounds = self.joins[currentJoinsIndex ?? 0].myBackgrounds
        return myBackgrounds
    }

    /// Homeのパーツ編集設定をFirestoreのドキュメントに保存するメソッド
    /// 現在操作しているチームのJoinTeamデータモデルに保存される
    func updateHomeEdits(data EditedData: HomeEditData) async throws {
        guard let uid else { return }

        let currentIndex = getCurrentJoinsIndex()
        guard let currentIndex else { return }
        var updateJoinTeam = self.joins[currentIndex]

        updateJoinTeam.homeEdits = EditedData

        let joinTeamRef = db?
            .collection("users")
            .document(uid)
            .collection("joins")
            .document(updateJoinTeam.id)

        do {
            try joinTeamRef?.setData(from: updateJoinTeam)
        } catch {
            throw UserRelatedError.failedHomeEdits
        }
    }

    func updateJoinTeamBackground(data newBackground: Background) async throws {
        guard let uid, var currentJoinTeam else {
            throw UserRelatedError.missingData
        }

        let joinTeamRef = db?
            .collection("users")
            .document(uid)
            .collection("joins")
            .document(currentJoinTeam.id)

        // 背景のアップデート
        currentJoinTeam.currentBackground = newBackground

        do {
            try joinTeamRef?.setData(from: currentJoinTeam)
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
        guard let userRef = db?.collection("users").document(userData.id) else { return }

        let index = userData.favorites.firstIndex(where: { $0 == itemID })
        if let index {
            userData.favorites.remove(at: index)
        } else {
            userData.favorites.append(itemID)
        }

        do {
            _ = try? userRef.setData(from: userData)
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

    /// ユーザーが所属しているチーム全てに保存されている自身のメンバーデータを更新する。
    /// ユーザーデータの変更を行った時に、各チームのユーザーステートを揃えるために使う。
    func updateJoinTeamsMyData(from updatedData: User) async throws {
        // 自身が参加している各チームのid文字列データを配列に格納

        let updatedMyMemberData = JoinMember(id: updatedData.id,
                                       name: updatedData.name,
                                       iconURL: updatedData.iconURL)

        self.joins.compactMap { team in
            do {
                try db?
                    .collection("teams")
                    .document(team.id) // 所属チームの一つ
                    .collection("members")
                    .document(updatedMyMemberData.id)
                    .setData(from: updatedMyMemberData)
            } catch {
                UserRelatedError.failedUpdateJoinsMyMemberData
            }
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
                       imagePath: imagePath)
        )

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

    /// 選択されたチーム内の自身のメンバーデータを削除するメソッド。
    /// チーム脱退操作が実行された時に使う。
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
    func deleteAllMyBackgrounds() {
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

    // アカウント削除対象ユーザーのユーザードキュメントを削除する
    func deleteAccountRelatedUserData() async throws {

        // ユーザが所属している各チームのid配列を使ってクエリを叩く
        guard let userID = user?.id else { throw CustomError.uidEmpty }
        guard let userRef = db?.collection("users").document(userID) else { throw CustomError.getRef }

        do {
            _ = try await userRef.getDocument().reference.delete()
            deleteAllMyBackgrounds()
        } catch {
            throw CustomError.deleteAccount
        }
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
    case failedUpdateLastLogIn
    case failedUpdateJoinsMyMemberData
    case failedEscapeTeam
}

struct TestUser {
    let testUser: User = User(id: "sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424", iconURL: nil, iconPath: nil, userColor: .red, joinsId: [])
}
