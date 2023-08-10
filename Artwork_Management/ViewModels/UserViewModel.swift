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

    var memberColor: ThemeColor {
        return user?.userColor ?? ThemeColor.blue
    }
    var currentJoinsTeamIndex: Int? {
        let index = self.joins.firstIndex(where: { $0.id == user?.lastLogIn })
        return index
    }
    /// ユーザーが現在操作しているチームの背景データ
    var currentTeamBackground: Background? {
        guard let index = currentJoinsTeamIndex else { return nil }
        let container = self.joins[index].currentBackground
        return container
    }
    var currentJoinTeam: JoinTeam? {
        guard let index = currentJoinsTeamIndex else { return nil }
        return self.joins[index]
    }

    @Published var isAnonymous: Bool = false
    @Published var showAlert = false
    @Published var userErrorMessage = ""
    @Published var updatedUser: Bool = false

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

    func fetchJoinTeams() async throws {
        guard let uid else { throw CustomError.uidEmpty }
        let joinsRef = db?
            .collection("users")
            .document(uid)
            .collection("joins")

        do {
            let snapshot = try await joinsRef?.getDocuments(source: .default)
            guard let documents = snapshot?.documents else { return }

            for document in documents {
                let joinTeam = try document.data(as: JoinTeam.self)
                DispatchQueue.main.async {
                    self.joins.append(joinTeam)
                }
            }
        } catch {
            print("ERROR_FetchJoinTeam: データ取得失敗")
            return
        }
    }

    
    func isAnonymousCheck() {
        
        if let user = Auth.auth().currentUser, user.isAnonymous {
            print("アカウント: 匿名")
            self.isAnonymous = true
        } else {
            print("アカウント: 登録済み")
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
                            self.updatedUser.toggle()
                        }
                    }
                } catch {
                    print("ERROR: リスナーによるユーザーデータの更新失敗")
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
        let myBackgrounds = self.joins[currentJoinsTeamIndex ?? 0].myBackgrounds
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
    func addNewJoinTeamToFirestore(data newJoinTeam: JoinTeam) async throws {
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

    func addNewJoinTeam(newJoinTeam: JoinTeam) async throws {

        guard let uid, var user else { throw CustomError.uidEmpty }
        guard let userRef = db?.collection("users").document(uid) else { throw CustomError.getRef }

        user.joins.append(newJoinTeam)
        user.lastLogIn = newJoinTeam.id

        do {
            try userRef.setData(from: user)
        } catch {
            throw CustomError.updateData
        }
    }
    /// ユーザーアイコンをFirestorageに保存するメソッド。
    /// filePathは「users/\(Date()).jpeg」
    func uploadUserImage(_ image: UIImage?) async -> (url: URL?, filePath: String?) {

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            print("ユーザーアイコンのアップロードに失敗しました")
            return (url: nil, filePath: nil)
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "users/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        } catch {
            return (url: nil, filePath: nil)
        }
    }

    func updateUserToFirestore(data updatedUserData: User) async throws {
        guard let user else { throw CustomError.userEmpty }
        guard let userRef = db?.collection("users")
            .document(user.id) else { throw CustomError.getDocument }
        // 更新前の元々のアイコンパスを保持しておく。更新成功後のデフォルトデータ削除に使う
        let defaultIconPath = user.iconPath

        do {
            _ = try userRef.setData(from: updatedUserData)
        } catch {
            // アイコンデータ更新失敗時の処理
            // 保存予定だったアイコンデータをfirestorageから削除
            await deleteUserImageData(path: updatedUserData.iconPath)
            print("ERROR: updateUser")
        }
    }
    
    func updateUserEmailAddress(email updateEmail: String) async {
        guard var user else { return }
        guard let userRef = db?.collection("users").document(user.id) else { return }
        
        do {
            user.address = updateEmail
            _ = try userRef.setData(from: user)
        } catch {
            print("新しいメールアドレスのFirebaseへの保存に失敗しました")
            return
        }
    }

    /// ユーザーのテーマカラーを更新するメソッド
    func updateUserThemeColor(selected selectedColor: ThemeColor) {
        guard var user else { return }
        guard let userRef = db?.collection("users").document(user.id) else { return }

        do {
            user.userColor = selectedColor
            _ = try userRef.setData(from: user)
        } catch {
            print("ユーザーテーマカラーのFirebaseへの保存に失敗しました")
            return
        }
    }
    
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
    func uploadMyBackgroundToFirestorage(_ image: UIImage?) async -> (url: URL?, filePath: String?) {

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }
        guard let user else { return (url: nil, filePath: nil) }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "users/myBackgrounds/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        } catch {
            return (url: nil, filePath: nil)
        }
    }

    /// ユーザーが写真フォルダから選択したオリジナル背景をFirestoreに保存するメソッド。
    /// 画像はユーザーのドキュメントデータ「myBackgrounds」に保管される。
    func addMyBackgroundToFirestore(url imageURL: URL?, path imagePath: String?) async {
        guard var user = user else { return }
        guard let userRef = db?.collection("users").document(user.id) else { return }

        user.myBackgrounds.append(
            Background(category: "original",
                       imageName: "",
                       imageURL: imageURL,
                       imagePath: imagePath)
        )

        do {
            try userRef.setData(from: user)

        } catch {
            print("ERROR: チーム背景の保存に失敗しました。")
        }
    }

    func deleteMyBackgroundToFirestore(_ background: Background) {
        guard var user = user else { return }
        guard let userRef = db?.collection("users").document(user.id) else { return }

        user.myBackgrounds.removeAll(where: { $0 == background })

        do {
            try userRef.setData(from: user)

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
    
    func deleteMembersJoinTeam(for selectedTeam: JoinTeam, ids membersId: [String]) async throws {

        let joinMemberRefs = db?
            .collection("users")
            .whereField("id", in: membersId)

        do {
            let snapshot = try await joinMemberRefs?.getDocuments()
            guard let documents = snapshot?.documents else { throw CustomError.getDocument }
            
            for memberDocument in documents {
                
                var memberData = try memberDocument.data(as: User.self)
                let resultJoins = memberData.joins.drop(while: { $0.id == selectedTeam.id })
                memberData.joins = Array(resultJoins)
                
                let userRef = db?
                    .collection("users")
                    .document(memberData.id)

                _ = try userRef?.setData(from: memberData)
                
            } // for
        } // do
    }

    /// Firestorageに保存されているユーザーのオリジナル背景データを全て削除するメソッド。
    func deleteAllMyBackgrounds() {
        guard let user else { return }
        let storage = Storage.storage()
        let reference = storage.reference()

        Task {
            for joinTeam in user.joins {
                for background in joinTeam.myBackgrounds {
                    guard let path = background.imagePath else { continue }
                    let imageRef = reference.child(path)
                    imageRef.delete { error in
                        if let error = error {
                            print(error)
                        } else {
                            print("オリジナル背景データを削除しました")
                        }
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
}

struct TestUser {
    let testUser: User = User(id: "sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424", iconURL: nil, iconPath: nil, userColor: .red, joins: [])
}
