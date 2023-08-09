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

    var listener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { return Auth.auth().currentUser?.uid }
    var memberColor: ThemeColor {
        return user?.userColor ?? ThemeColor.blue
    }
    var currentJoinsTeamIndex: Int? {
        let index = user?.joins.firstIndex(where: { $0.teamID == user?.lastLogIn })
        return index
    }
    /// ユーザーが現在操作しているチームの背景データ
    var currentTeamBackground: Background? {
        guard let index = currentJoinsTeamIndex else { return nil }
        let container = user?.joins[index].currentBackground
        return container
    }

    @Published var user: User?
    @Published var isAnonymous: Bool = false
    @Published var showAlert = false
    @Published var userErrorMessage = ""
    @Published var updatedUser: Bool = false

    @MainActor
    func fetchUser() async throws {
        guard let uid = uid else { throw CustomError.uidEmpty }
        guard let userRef = db?.collection("users").document(uid) else { throw CustomError.getRef }

        do {
            let document = try await userRef.getDocument(source: .default)
            let user = try document.data(as: User.self)
            self.user = user
        } catch {
            throw CustomError.getUserDocument
        }
    }
    
    func isAnonymousCheck() {
        
        if let user = Auth.auth().currentUser, user.isAnonymous {
            print("アカウント: Anonymous")
            self.isAnonymous = true
        } else {
            print("アカウント: Not Anonymous")
            self.isAnonymous = false
        }
    }

    func listener() async throws {
        guard let uid = uid else { throw CustomError.uidEmpty }
        guard let userRef = db?.collection("users").document(uid) else { throw CustomError.getRef }
        listener = userRef.addSnapshotListener { snap, error in
            if let error {
                print("userRealtimeListener失敗: \(error.localizedDescription)")
            } else {
                guard let snap else {
                    print("userRealtimeListener_Error: snapがnilです")
                    return
                }

                withAnimation {
                    do {
                        let userData = try snap.data(as: User.self)
                        self.user = userData
                        DispatchQueue.main.async {
                            self.isAnonymousCheck()
                            self.updatedUser.toggle()
                        }
                    } catch {
                        print("userRealtimeListener_Error: try snap?.data(as: User.self)")
                    }
                }
            }
        }
    }
    
    func updateLastLogInTeam(selected selectedTeam: JoinTeam?) async {
        guard var user else { return }
        guard let selectedTeam else { return }
        guard let userRef = db?.collection("users").document(user.id) else { return }
        do {
            user.lastLogIn = selectedTeam.teamID
            _ = try userRef.setData(from: user)
        } catch {
            print("最新ログインチームのFirestoreへの保存に失敗しました")
            return
        }
    }

    /// 参加チーム群の配列から現在操作しているチームのインデックスを取得するメソッド
    func getCurrentTeamIndex() -> Int? {
        guard let user else { return nil }
        var getIndex: Int?

        getIndex = user.joins.firstIndex(where: { $0.teamID == user.lastLogIn })
        return getIndex
    }

    func getCurrentTeamMyBackgrounds() -> [Background] {
        guard let user else { return [] }
        let myBackgrounds = user.joins[currentJoinsTeamIndex ?? 0].myBackgrounds
        return myBackgrounds
    }

    /// Homeのパーツ編集設定をFirestoreのドキュメントに保存するメソッド
    /// 現在操作しているチームのJoinTeamデータモデルに保存される
    func updateCurrentTeamHomeEdits(data EditsData: HomePartsEditData) {
        guard var user = user else { return }
        guard let userRef = db?.collection("users").document(user.id) else { return }

        do {
            let currentTeamIndex = getCurrentTeamIndex()
            guard let currentTeamIndex else { return }
            user.joins[currentTeamIndex].homeEdits = EditsData
            try userRef.setData(from: user)
        } catch {
            print("ERROR: Homeパーツ設定の保存に失敗しました。")
        }
    }

    func updateCurrentTeamBackground(data backgroundData: Background) async throws {
        guard var user else { throw CustomError.userEmpty }
        guard let userRef = db?.collection("users").document(user.id) else { throw CustomError.getDocument }

        do {
            user.joins[currentJoinsTeamIndex ?? 0].currentBackground = backgroundData
            try userRef.setData(from: user)
        } catch {
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

    func addNewJoinTeam(newJoinTeam: JoinTeam) async throws {

        guard let uid = uid, var user = user else { throw CustomError.uidEmpty }
        guard let userRef = db?.collection("users").document(uid) else { throw CustomError.getRef }

        user.joins.append(newJoinTeam)
        user.lastLogIn = newJoinTeam.teamID

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
    
    func updateJoinTeamToMembers(data updatedJoinTeam: JoinTeam, members joinMembers: [JoinMember]) async throws {

        // チームに所属している各メンバーのid文字列データを配列に格納(whereFieldクエリで使う)
        var joinMembersID: [String] = joinMembers.map { $0.memberUID }

        // 所属メンバーのid配列を使ってクエリを叩く
        let joinMemberRefs = db?
            .collection("users")
            .whereField("id", in: joinMembersID)

        do {
            let snapshot = try await joinMemberRefs?.getDocuments()
            guard let documents = snapshot?.documents else { throw CustomError.getDocument }
            for memberDocument in documents {
                var memberData = try memberDocument.data(as: User.self)

                // ユーザのjoins配列からアップデート対象のチームを検出する
                for (index, joinTeam) in memberData.joins.enumerated() where joinTeam.teamID == updatedJoinTeam.teamID {
                    // 対象JoinTeamデータの名前とアイコンを更新
                    memberData.joins[index].name = updatedJoinTeam.name
                    memberData.joins[index].iconURL = updatedJoinTeam.iconURL
                    // 更新後のユーザデータを再保存するためのリファレンスを取得
                    guard let teamRef = db?.collection("users").document(memberData.id) else { throw CustomError.getRef }
                    // リファレンスをもとにsetDataを実行
                    try teamRef.setData(from: memberData)
                }
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
            let filePath = "users/\(Date()).jpeg"
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
    
    func deleteMembersJoinTeam(selected selectedTeam: JoinTeam, members joinMembers: [JoinMember]) async throws {
        var joinMembersID: [String] = []
        // チームに所属している各メンバーのid文字列データを配列に格納(whereFieldクエリで使う)
        for member in joinMembers {
            joinMembersID.append(member.memberUID)
        }

        // 所属メンバーのid配列を使ってクエリを叩く
        guard let joinMemberRefs = db?.collection("users")
            .whereField("id", in: joinMembersID) else { throw CustomError.getRef }

        do {
            let snapshot = try await joinMemberRefs.getDocuments()
            
            for memberDocument in snapshot.documents {
                
                var rowMemberData = try memberDocument.data(as: User.self)
                let resultJoins = rowMemberData.joins.drop(while: { $0.teamID == selectedTeam.teamID })
                rowMemberData.joins = Array(resultJoins)
                
                guard let userRef = db?.collection("users").document(rowMemberData.id) else {
                    throw CustomError.getRef
                }
                _ = try userRef.setData(from: rowMemberData)
                
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
        listener?.remove()
    }
}

struct TestUser {
    let testUser: User = User(id: "sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424", iconURL: nil, iconPath: nil, userColor: .red, joins: [])
}
