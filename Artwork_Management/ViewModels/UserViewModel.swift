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

    @Published var users: [User] = []
    var uid = ""

    @MainActor
    func fetchUser() async -> Bool {

        guard let uid = Auth.auth().currentUser?.uid,
                let userRef = db?.collection("users").document(uid) else { return false }

        do {
            let document = try await userRef.getDocument(source: .default)
            let user = try document.data(as: User.self)
            self.users.append(user)
        } catch {
            print("fetchUser失敗")
            return false
        }
        return true
    }

    func logOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            return false
        }
    }
}

struct TestUser {
    let testUser: User = User(id: "sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424", iconURL: nil, iconPath: nil, joins: [])
}
