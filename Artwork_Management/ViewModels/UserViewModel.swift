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
    case uidEmpty, getRef, fetch, setData, updateData, getDocument,getUserDocument, photoUrlEmpty, userEmpty, teamEmpty, getDetectUser, inputTextEmpty, memberDuplication, addTeamIDToJoinedUser, createAnonymous, existUserDocument, existAccountEmail, deleteAccount
}

class UserViewModel: ObservableObject {

    init() {
        print("<<<<<<<<<  UserViewModel_init  >>>>>>>>>")
        isAnonymousCheck()
    }

    var listener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { return Auth.auth().currentUser?.uid }
    var memberColor: MemberColor {
//        return user?.userColor ?? MemberColor.blue
        return MemberColor.yellow
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
        print("userVM_isAnonymousCheck実行")
        
        if let user = Auth.auth().currentUser, user.isAnonymous {
            print("currentUser: anonymous user")
            self.isAnonymous = true
        } else {
            print("currentUser: Not Anonymous user")
            self.isAnonymous = false
        }
    }

    func userRealtimeListener() async throws {
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
                print("userRealtimeListener開始")
                do {
                    let userData = try snap.data(as: User.self)
                    self.user = userData
                    print("userRealtimeListenerによりチームデータを更新")
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

    func uploadUserImage(_ image: UIImage?) async -> (url: URL?, filePath: String?) {

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

    func updateUserNameAndIcon(name updateName: String, data updateIconData: (url: URL?, filePath: String?)) async throws {

        // 取得アイコンデータurlがnilであれば更新しない
        guard var userDataSource = user else { throw CustomError.userEmpty }
        guard let userRef = db?.collection("users").document(userDataSource.id) else { throw CustomError.getDocument }

        do {
            // 更新前の元々のアイコンパスを保持しておく。更新成功後のデフォルトデータ削除に使う
            let defaultIconPath = userDataSource.iconPath
            userDataSource.name     = updateName
            userDataSource.iconURL  = updateIconData.url
            userDataSource.iconPath = updateIconData.filePath

            _ = try userRef.setData(from: userDataSource)
            // アイコンデータは変えていない場合、削除処理をスキップする
            if defaultIconPath != updateIconData.filePath {
                await deleteUserImageData(path: defaultIconPath)
            }
        } catch {
            // アイコンデータ更新失敗のため、保存予定だったアイコンデータをfirestorageから削除
            await deleteUserImageData(path: updateIconData.filePath)
            print("error: updateTeamNameAndIcon_do_try_catch")
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
    
    func updateUserJoinTeamData(data updateTeamData: JoinTeam, members joinMembers: [JoinMember]) async throws {

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

                do {
                    var memberData = try memberDocument.data(as: User.self)

                    // ユーザのjoins配列からアップデート対象のチームを検出する
                    for (index, joinTeam) in memberData.joins.enumerated() where joinTeam.teamID == updateTeamData.teamID {
                        // ユーザ内の対象チームデータを更新
                        memberData.joins[index] = updateTeamData
                        // 更新後のユーザデータを再保存するためのリファレンスを取得
                        guard let teamRef = db?.collection("users").document(memberData.id) else { throw CustomError.getRef }
                        // リファレンスをもとにsetDataを実行
                        try teamRef.setData(from: memberData)
                    }
                }
            }
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

    // アカウント削除対象ユーザーのユーザードキュメントを削除する
    func deleteAccountRelatedUserData() async throws {

        // ユーザが所属している各チームのid配列を使ってクエリを叩く
        guard let userID = user?.id else { throw CustomError.uidEmpty }
        guard let userRef = db?.collection("users").document(userID) else { throw CustomError.getRef }

        do {
            _ = try await userRef.getDocument().reference.delete()
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
