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
    case uidEmpty, getRef, fetch, setData, updateData, getDocument, photoUrlEmpty, teamEmpty, getDetectUser, inputTextEmpty, memberDuplication, addTeamIDToJoinedUser
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

    @MainActor
    func fetchUser() async throws {
//        guard let uid = uid else { throw CustomError.uidEmpty }
//        guard let userRef = db?.collection("users").document(uid) else { throw CustomError.getRef }
//
//        do {
//            let document = try await userRef.getDocument(source: .default)
//            let user = try document.data(as: User.self)
//            self.user = user
//
//        } catch {
//            throw CustomError.getDocument
//        }

        // ✅リスナーによるフェッチver.
        // firebaseのリスナー機能が非同期に対応していない？リスナーによる完了を待たずに他のフェッチ処理が進んでしまうためクラッシュする。現在使えない
        guard let uid = uid else { throw CustomError.uidEmpty }
        guard let userRef = db?.collection("users").document(uid) else { throw CustomError.getRef }

        listener = userRef.addSnapshotListener { snap, error in
            guard let snap else {
                print("Error: fetchUser_\(error!)")
                return
            }
            do {
                let userData = try snap.data(as: User.self)
                self.user = userData
                print("fetchUser_更新をリスナーで検知")
                self.canUserFetchedListener = true
            } catch {
                print("Error: try snap.data(as: User.self)")
                self.canUserFetchedListener = false
                return
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

    deinit {
        listener?.remove()
    }
}

struct TestUser {
    let testUser: User = User(id: "sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424", iconURL: nil, iconPath: nil, userColor: .red, joins: [])
}
