//
//  LogInViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
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
    @Published var isShowSearchedNewMemberJoinTeam: Bool = false
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
    
    func resizeUIImage(image: UIImage?, width: CGFloat) -> UIImage? {
        
        if let originalImage = image {
            // オリジナル画像のサイズからアスペクト比を計算
            let aspectScale = originalImage.size.height / originalImage.size.width
            
            // widthからアスペクト比を元にリサイズ後のサイズを取得
            let resizedSize = CGSize(width: width * 3, height: width * Double(aspectScale) * 3)
            
            // リサイズ後のUIImageを生成して返却
            UIGraphicsBeginImageContext(resizedSize)
            originalImage.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return resizedImage
        } else {
            return nil
        }
    }

    /// ユーザー作成時のみ呼び出されるチーム画像保存メソッド
    /// ユーザー作成時は既存のチームIDが存在しないため、View側で生成したidを引っ張ってくる
    func firstUploadTeamImage(_ image: UIImage?, id createTeamID: String) async -> (url: URL?, filePath: String?) {

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "teams/\(createTeamID)/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        } catch {
            return (url: nil, filePath: nil)
        }
    }

    func uploadTeamImage(_ image: UIImage?) async -> (url: URL?, filePath: String?) {

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }
        guard let teamID = team?.id else { return (url: nil, filePath: nil) }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "teams/\(teamID)/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        } catch {
            return (url: nil, filePath: nil)
        }
    }

    func deleteTeamImageData(path: String?) async {

        guard let path = path else { return }

        let storage = Storage.storage()
        let reference = storage.reference()
        let imageRef = reference.child(path)

        imageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                print("imageRef.delete succsess!")
            }
        }
    }

    func updateTeamBackgroundImage(data: (url: URL?, filePath: String?)) async throws {

        guard var team else { throw CustomError.teamEmpty }
        guard let teamRef = db?.collection("teams").document(team.id) else { throw CustomError.getDocument }

        print("storage保存に必要なデータ取得おけ")
        do {
            team.backgroundURL = data.url
            team.backgroundPath = data.filePath
            try teamRef.setData(from: team)
            print("storageにヘッダー画像保存成功")
            try await fetchNewTeamBackgroundImage(teamID: team.id)
            print("新規ヘッダー画像取得成功")
        } catch {
            print("ヘッダーの保存に失敗")
        }
    }

    func updateTeamNameAndIcon(name updateName: String, data updateIconData: (url: URL?, filePath: String?)) async throws {

        // 取得アイコンデータurlがnilだったら処理終了
        guard var teamDataSource = team else { throw CustomError.teamEmpty }
        guard let teamRef = db?.collection("teams").document(teamDataSource.id) else { throw CustomError.getDocument }

        do {
            // 更新前の元々のアイコンパスを保持しておく。更新成功が確認できてから前データを削除する
            let defaultIconPath = teamDataSource.iconPath
            teamDataSource.name = updateName
            teamDataSource.iconURL = updateIconData.url
            teamDataSource.iconPath = updateIconData.filePath

            _ = try teamRef.setData(from: teamDataSource)
            // アイコンデータは変えていない場合、削除処理をスキップする
            if defaultIconPath != updateIconData.filePath {
                await deleteTeamImageData(path: defaultIconPath)
            }
        } catch {
            // アイコンデータ更新失敗のため、保存予定だったアイコンデータをfirestorageから削除
            await deleteTeamImageData(path: updateIconData.filePath)
            print("error: updateTeamNameAndIcon_do_try_catch")
        }
    }

    func updateTeamJoinMemberData(data updateMemberData: JoinMember, joins joinsTeam: [JoinTeam]) async throws {

        var joinsTeamID: [String] = []
        // ユーザが参加している各チームのid文字列データを配列に格納(whereFieldクエリで使う)
        for joinTeam in joinsTeam {
            joinsTeamID.append(joinTeam.teamID)
        }

        // ユーザが所属している各チームのid配列を使ってクエリを叩く
        guard let joinTeamRefs = db?.collection("teams")
            .whereField("id", in: joinsTeamID) else { throw CustomError.getRef }

        do {
            let snapshot = try await joinTeamRefs.getDocuments()

            for teamDocument in snapshot.documents {

                do {
                    var teamData = try teamDocument.data(as: Team.self)

                    // チームのmembers配列からcurrentのユーザメンバーデータを検出する
                    for (index, teamMember) in teamData.members.enumerated() where teamMember.memberUID == uid {
                        // チーム内の対象メンバーデータを更新
                        teamData.members[index] = updateMemberData
                        // 更新対象チームの更新用リファレンスを生成
                        guard let teamRef = db?.collection("teams").document(teamData.id) else { throw CustomError.getRef }
                        // リファレンスをもとにsetDataを実行
                        try teamRef.setData(from: teamData)
                    }
                }
            }
        }
    }

    @MainActor
    func fetchNewTeamBackgroundImage(teamID: String) async throws {

        guard let teamRef = db?.collection("teams").document(teamID) else { throw CustomError.getRef  }

        do {
            let teamDocument = try await teamRef.getDocument()
            let teamData = try teamDocument.data(as: Team.self)
            self.team?.backgroundURL = teamData.backgroundURL
            self.team?.backgroundPath = teamData.backgroundPath
        } catch {
            throw CustomError.fetch
        }
    }
    
    func getUIImageByUrl(url: URL?) -> UIImage? {
        guard let url else { return nil }
        var iamge: UIImage?
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                iamge = UIImage(data: data)
                print("teamIconのurl->UIImage成功")

            } catch let err {
                print("Error : \(err.localizedDescription)")
            }
        }
        print("imageの返却")
        return iamge
    }
    
    func deleteAllTeamImages() async {
        guard let team else { return }
        
        var teamImagesPath: [String?]
        teamImagesPath = [team.iconPath,
                          team.backgroundPath]
        
        let storage = Storage.storage()
        let reference = storage.reference()
        
        for path in teamImagesPath {
            guard let path else { return }
            let imageRef = reference.child(path)
            imageRef.delete { error in
                if let error = error {
                    print("画像の削除に失敗しました: \(path)")
                    print(error)
                } else {
                    print("画像の削除に成功しました")
                }
            }
        } // for in
    }
    /// ユーザーが選択したチームのデータを削除する
    func deleteSelectedTeamDocuments(selected selectedTeam: JoinTeam) async {
        guard let teamRef = db?.collection("teams").document(selectedTeam.teamID) else {
            print("error: deleteAllTeamDocumentsでリファレンスを取得できませんでした")
            return
        }
        do {
            _ = try await teamRef.delete()
        } catch {
            print("チームドキュメントの削除に失敗しました")
        }
    }

    /// アカウント削除時に実行されるメソッド。削除実行アカウントが所属するチームの関連データを削除する
    /// ✅所属チームのメンバーが削除アカウントのユーザーのみだった場合 ⇨ チームデータを全て消去
    /// ✅所属チームのメンバーが削除アカウントのユーザー以外にも在籍している場合 ⇨ 関連ユーザーデータのみ削除
    func deleteAccountRelatedTeamData(uid userID: String, joinsTeam: [JoinTeam]) async throws {

        var joinsTeamID: [String] = []
        // ユーザが参加している各チームのid文字列データを配列に格納(whereFieldクエリで使う)
        for joinTeam in joinsTeam {
            joinsTeamID.append(joinTeam.teamID)
        }

        // ユーザが所属している各チームのid配列を使ってクエリを叩く
        guard let joinTeamRefs = db?.collection("teams")
            .whereField("id", in: joinsTeamID) else {
            print("deleteAccountRelatedTeamDataでのクエリに失敗しました")
            throw CustomError.getRef
        }

        do {
            let snapshot = try await joinTeamRefs.getDocuments()

            for teamRowDocument in snapshot.documents {

                do {
                    // 所属チーム一つ分のドキュメント取得
                    var teamData = try teamRowDocument.data(as: Team.self)
                    guard let teamRowRef = db?.collection("teams").document(teamData.id) else {
                        print("\(teamData.name)チームのリファレンス取得に失敗しました")
                        continue
                    }

                    if teamData.members.count == 1 &&
                        teamData.members.first?.memberUID == userID {
                        // 削除対象ユーザーの他にチームメンバーが居なかった場合、全データをFirestoreから削除
                        _ = try await teamRowDocument.reference.delete()

                    } else {
                        // 削除対象ユーザーの他にもチーム所属者がいた場合、削除ユーザーのみmembersから処理し、保存
                        teamData.members.removeAll(where: { $0.memberUID == userID })
                        try teamRowRef.setData(from: teamData)
                    }
                }
            }
        }
    }

    deinit {
        listener?.remove()
    }
}
