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
    }

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { return Auth.auth().currentUser?.uid }

    @Published var users: [User] = []

    @Published var showAlert = false
    @Published var userErrorMessage = ""

    @MainActor
    func fetchUser() async throws {

        print("fetchUser実行")

        guard let uid = uid else { return }
        guard let userRef = db?.collection("users").document(uid) else { return }

        let document = try await userRef.getDocument(source: .default)
        let user = try document.data(as: User.self)
        self.users.append(user)
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

struct TestUser {
    let testUser: User = User(id: "sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424", iconURL: nil, iconPath: nil, joins: [])
}
