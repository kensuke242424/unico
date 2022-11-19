//
//  UserViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserViewModel: ObservableObject {

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid = "sampleUserID(uid)"

    @Published var users: [User] = [User(id :"sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com", password: "ninnzinn2424", iconURL: nil, iconPath: nil, teams: [])]


    func addUser(userData: User, groupID: String) {

        print("addUser実行")

        guard let itemsRef = db?.collection("users") else {
            print("error: guard let tagsRef")
            return
        }

        do {
            _ = try itemsRef.addDocument(from: userData)
        } catch {
            print("Error: try db!.collection(collectionID).addDocument(from: itemData)")
        }
        print("addUser完了")
    }

}

struct TestUser {
    let testUser: User = User(id :"sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com", password: "ninnzinn2424", iconURL: nil, iconPath: nil, teams: [])
}
