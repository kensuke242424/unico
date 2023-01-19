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

    var listener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { return Auth.auth().currentUser?.uid }

    @Published var team: Team?
    @Published var isShowCreateAndJoinTeam: Bool = false
    @Published var isShowSearchedNewUserJoinTeam: Bool = false
    @Published var showErrorAlert = false
    @Published var alertMessage = ""

    @MainActor
    func fetchTeam(teamID: String) async throws {

        guard let teamRef = db?.collection("teams").document(teamID) else { throw CustomError.getRef  }

        do {
            let teamDocument = try await teamRef.getDocument()
            let teamData = try teamDocument.data(as: Team.self)
            self.team =  teamData
        } catch {
            throw CustomError.fetch
        }
    }

    func teamRealtimeListener() async throws {

        guard let teamID = team?.id else { throw CustomError.teamEmpty }
        guard let teamRef = db?.collection("teams").document(teamID) else { throw CustomError.getRef  }

        listener = teamRef.addSnapshotListener { snap, error in
            if let error {
                print("teamRealtimeListener失敗: \(error.localizedDescription)")
            } else {
                guard let snap else {
                    print("teamRealtimeListener_Error: snapがnilです")
                    return
                }
                print("teamRealtimeListener開始")
                do {
                    let teamData = try snap.data(as: Team.self)
                    self.team = teamData
                    print("teamRealtimeListenerによりチームデータを更新")
                } catch {
                    print("teamRealtimeListener_Error: try snap?.data(as: Team.self)")
                }
            }
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

    func addNewTeamMember(data userData: User) async throws {
        print("addDetectedUser実行")
        guard var team else { throw CustomError.teamEmpty }
        guard let teamsRef = db?.collection("teams").document(team.id) else { throw CustomError.getRef }

        do {
            for member in team.members where userData.id == member.memberUID {
                throw CustomError.memberDuplication
            }

            let detectMemberData = JoinMember(memberUID: userData.id, name: userData.name, iconURL: userData.iconURL)
            team.members.append(detectMemberData)
            _ = try teamsRef.setData(from: team)
        }
    }

    // メンバー招待画面で取得した相手のユーザIDを使ってFirestoreのusersからデータをフェッチ
    func detectUserFetchData(id userID: String) async throws -> User? {

        guard let userRef = db?.collection("users").document(userID) else { throw CustomError.getDocument }

        do {
            let detectUserDocument = try await userRef.getDocument()
            let detectUserData = try detectUserDocument.data(as: User.self)
            return detectUserData
        } catch {
            print("detectUserFetchData_失敗")
            throw CustomError.getDetectUser
        }
    }

    func addTeamIDToJoinedUser(to toUID: String) async throws {

        guard let toUserRef = db?.collection("users").document(toUID) else { throw CustomError.getDocument }
        do {
            let toUserDocument = try await toUserRef.getDocument()
            var toUserData = try toUserDocument.data(as: User.self)
            let teamData = JoinTeam(teamID: team!.id, name: team!.name, iconURL: team!.iconURL)

            toUserData.joins.append(teamData)
            toUserData.lastLogIn = team!.id

            _ = try toUserRef.setData(from: toUserData)

        } catch {
            throw CustomError.addTeamIDToJoinedUser
        }
    }

    func updateTeamHeaderImage(data: (url: URL?, filePath: String?)) async throws {

        guard var team else { throw CustomError.teamEmpty }
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
            self.team?.headerURL = teamData.headerURL
            self.team?.headerPath = teamData.headerPath
        } catch {
            throw CustomError.fetch
        }
    }

    deinit {
        listener?.remove()
    }
}
