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
    case uidEmpty, getUserRef, teamFetch, userFetch, itemFetch, tagFetch
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
            guard let userRef = db?.collection("users").document(uid) else { throw CustomError.getUserRef }

        do {
            let document = try await userRef.getDocument(source: .default)
            let user = try document.data(as: User.self)
            self.users.append(user)

        } catch CustomError.uidEmpty {
            print("Error_fetchUser: uidEmpty")
        } catch CustomError.getUserRef {
            print("Error_fetchUser: getUserRef")
        } catch {
            print("Error_fetchUser: try fetch")
        }
    }
    // ログインタイムが一番近いチームを取得して、チームIDを返す
    // チームIDを持っていない(所属チームがない)場合、nilを返す
    func getFastLogInTeamID() async -> String? {

        if users.isEmpty { return nil }
        var joinsTeam = users.first!.joins
        joinsTeam.sort(by: { $0.logInTime!.dateValue() > $1.logInTime!.dateValue() })
        guard let fastLogInTeam = joinsTeam.first else { return nil }

        return fastLogInTeam.teamID
    }
}

struct TestUser {
    let testUser: User = User(id: "sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424", iconURL: nil, iconPath: nil, joins: [])
}
