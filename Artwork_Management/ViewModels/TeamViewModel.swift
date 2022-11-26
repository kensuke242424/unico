//
//  LogInViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class TeamViewModel: ObservableObject {

    init() {
        print("<<<<<<<<<  TeamViewModel_init  >>>>>>>>>")
    }

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name

    var teamID: String = "7gm2urHDCdZGCV9pX9ef"

    @Published var isShowCreateAndJoinTeam: Bool = false

    func fetchTeam() async -> Bool {

        return false
    }

    // Userのjoinsデータから最終ログイン日が一番最近のチームIDを返す
    // joins内にチームが存在しなければ、nilを返す
    func getJoinsTeamID() async -> String? {

        guard let uid = Auth.auth().currentUser?.uid, let usersRef = db?.collection("users") else {
            print("Error: foinTeamCheck_Auth.guard let uid = auth().currentUser?.uid")
            return nil
        }

        print(uid)

        do {
            let document = try await usersRef.document(uid).getDocument()
            print("document取得OK")
            let user = try document.data(as: User.self)
            print("user取得OK")
            let joinsData = user.joins
            print("joinsData: \(joinsData)")
        } catch {
            print("Error: fetchTeam_try await usersRef.document(uid).getDocument(as: User.self)")
            return nil
        }

        return nil
    }
}
