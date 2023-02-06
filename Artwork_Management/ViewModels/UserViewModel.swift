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
    case uidEmpty, getRef, fetch, setData, updateData, getDocument, photoUrlEmpty, userEmpty, teamEmpty, getDetectUser, inputTextEmpty, memberDuplication, addTeamIDToJoinedUser
}

class UserViewModel: ObservableObject {

    init() {
        print("<<<<<<<<<  UserViewModel_init  >>>>>>>>>")
    }

    var listener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { return Auth.auth().currentUser?.uid }

    @Published var user: User?
    @Published var canUserFetchedListener: Bool?
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
            throw CustomError.getDocument
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
                        self.updatedUser.toggle()
                    }
                } catch {
                    print("userRealtimeListener_Error: try snap?.data(as: User.self)")
                }
            }
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

    func uploadUserImageData(_ image: UIImage?) async -> (url: URL?, filePath: String?) {

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }
        guard var user else { return (url: nil, filePath: nil) }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "users/\(user.id)/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        } catch {
            return (url: nil, filePath: nil)
        }
    }

    func updateUserNameAndIcon(name updateName: String, data iconData: (url: URL?, filePath: String?)) async throws {

        // 取得アイコンデータurlがnilだったら処理終了
        guard iconData.url != nil else { return }
        guard var user else { throw CustomError.userEmpty }
        guard let userRef = db?.collection("users").document(user.id) else { throw CustomError.getDocument }

        do {
            // 更新前の元々のアイコンパスを保持しておく。更新成功が確認できてから前データを削除する
            let defaultIconPath = user.iconPath
            user.name = updateName
            user.iconURL = iconData.url
            user.iconPath = iconData.filePath

            _ = try userRef.setData(from: user)
            // ⬆︎のsetDataが成功したら、前のアイコンデータをfirestorageから削除
            await deleteUserImageData(path: defaultIconPath)
        } catch {
            // アイコンデータ更新失敗のため、保存予定だったアイコンデータをfirestorageから削除
            await deleteUserImageData(path: iconData.filePath)
            print("error: updateTeamNameAndIcon_do_try_catch")
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

    deinit {
        listener?.remove()
    }
}

struct TestUser {
    let testUser: User = User(id: "sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424", iconURL: nil, iconPath: nil, userColor: .red, joins: [])
}
