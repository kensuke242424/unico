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
    var uid: String? { return Auth.auth().currentUser?.uid }

    @Published var team: [Team] = []
    @Published var isShowCreateAndJoinTeam: Bool = false

    @MainActor
    func fetchTeam(teamID: String) async throws {

        guard let teamRef = db?.collection("teams").document(teamID) else { throw CustomError.getRef  }

        do {
            let teamDocument = try await teamRef.getDocument()
            let teamData = try teamDocument.data(as: Team.self)
            self.team.append(teamData)
        } catch {
            throw CustomError.fetch
        }
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
            let user = try document.data(as: User.self)
            let joinsData = user.joins
        } catch {
            print("Error: fetchTeam_try await usersRef.document(uid).getDocument(as: User.self)")
            return nil
        }
        return nil
    }

    func addTeam(teamData: Team) async throws {
        print("addTeamAndGetID実行")

        guard let teamsRef = db?.collection("teams") else {
            print("error: guard let teamsRef = db?.collection(teams)")
            throw CustomError.getRef
        }

        do {
            _ = try teamsRef.document(teamData.id).setData(from: teamData)
        } catch {
            print("Error: try db!.collection(collectionID).addDocument(from: itemData)")
            throw CustomError.setData
        }
        print("addTeamAndGetID完了")
    }
}
