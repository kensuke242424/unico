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
    case uidEmpty, getRef, fetch, setData, updateData, getDocument, photoUrlEmpty, teamEmpty, getDetectUser, inputTextEmpty, memberDuplication
}

class UserViewModel: ObservableObject {

    init() {
        print("<<<<<<<<<  UserViewModel_init  >>>>>>>>>")
    }

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { return Auth.auth().currentUser?.uid }

    @Published var users: [User] = []

    @Published var showAlert = false
    @Published var userErrorMessage = ""

    @MainActor
    func fetchUser() async throws {
            guard let uid = uid else { throw CustomError.uidEmpty }
            guard let userRef = db?.collection("users").document(uid) else { throw CustomError.getRef }

        do {
            users = []
            let document = try await userRef.getDocument(source: .default)
            let user = try document.data(as: User.self)
            self.users.append(user)

        } catch {
            throw CustomError.getDocument
        }
    }

    func addNewJoinTeam(newJoinTeam: JoinTeam) async throws {

        guard let uid = uid, var user = users.first else { throw CustomError.uidEmpty }
        guard let userRef = db?.collection("users").document(uid) else { throw CustomError.getRef }

        user.joins.append(newJoinTeam)
        user.lastLogIn = newJoinTeam.teamID

        do {
            try userRef.setData(from: user)
        } catch {
            throw CustomError.updateData
        }
    }
}

struct TestUser {
    let testUser: User = User(id: "sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424", iconURL: nil, iconPath: nil, userColor: .red, joins: [])
}
