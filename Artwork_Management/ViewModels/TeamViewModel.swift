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
            team = []
            let teamDocument = try await teamRef.getDocument()
            let teamData = try teamDocument.data(as: Team.self)
            self.team.append(teamData)
            print("fetchTeam: \(team)")
        } catch {
            throw CustomError.fetch
        }
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

    func updateTeamHeaderImage(data: (url: URL?, filePath: String?)) async throws {

        guard var team = team.first else { throw CustomError.teamEmpty }
        guard let teamRef = db?.collection("teams").document(team.id) else { throw CustomError.getDocument }

        print("storage保存に必要なデータ取得おけ")
        do {
            team.headerURL = data.url
            team.headerPath = data.filePath
            try teamRef.setData(from: team)
            print("storageにヘッダー画像保存成功")
            try await getTeamHeaderImage(teamID: team.id)
            print("新規ヘッダー画像取得成功")
        } catch {
            print("ヘッダーの保存に失敗")
        }
    }

    @MainActor
    func getTeamHeaderImage(teamID: String) async throws {

        guard let teamRef = db?.collection("teams").document(teamID) else { throw CustomError.getRef  }

        do {
            let teamDocument = try await teamRef.getDocument()
            let teamData = try teamDocument.data(as: Team.self)
            self.team[0].headerURL = teamData.headerURL
            self.team[0].headerPath = teamData.headerPath
        } catch {
            throw CustomError.fetch
        }
    }
}
