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

    func fetchUser() async -> Bool {

        guard let uid = Auth.auth().currentUser?.uid,
              let userRef = db?.collection("users").document(uid) else { return false }

        userRef.getDocument(as: User.self) { result in

            switch result {
            case .success(let user):
                self.users.append(user)
            case .failure(let error):
                print("fetchUser失敗: \(error)")
            }
        }
        if self.users.isEmpty {
            return false
        } else {
            return true
        }
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
