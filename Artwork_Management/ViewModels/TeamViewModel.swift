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

    var teamListener: ListenerRegistration?
    var membersListener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { Auth.auth().currentUser?.uid }

    @Published var team: Team?
    @Published var members: [JoinMember] = []

    @Published var isShowCreateAndJoinTeam: Bool = false
    @Published var isShowSearchedNewMemberJoinTeam: Bool = false
    @Published var showErrorAlert = false
    @Published var alertMessage = ""

    var teamID: String? { team?.id }
    /// 現在の操作チーム「members」内のフィールドから自身のmemberデータインデックスを取得するプロパティ。
    var myMemberIndex: Int? {
        return self.members.firstIndex(where: {$0.id == uid})
    }
    var myJoinMemberData: JoinMember? {
        guard let index = myMemberIndex else { return nil }
        return self.members[index]
    }
    /// 現在の操作しているチームのメンバー全員のIdを格納するプロパティ。
    var membersId: [String] {
        return self.members.compactMap {$0.id}
    }

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
    /// チームデータの追加・更新・削除のステートを管理するリスナーメソッド。
    /// 初期実行時にリスニング対象ドキュメントのデータが全取得される。(フラグはadded)
    func teamListener(id currentTeamID: String) async throws {
        let teamRef = db?
            .collection("teams")
            .document(currentTeamID)

        guard let teamRef else { throw CustomError.getRef }

        teamListener = teamRef.addSnapshotListener { snap, error in
            if let error {
                print("teamListener失敗: \(error.localizedDescription)")
            } else {
                print("teamListener起動")

                do {
                    let teamData = try snap?.data(as: Team.self)
                    withAnimation {self.team = teamData}
                    print("チームデータを更新")
                } catch {
                    print("チームデータ更新失敗")
                }
            }
        }
    }

    /// チームのサブコレクション「members」における追加・更新・削除のステートを管理するリスナーメソッド。
    /// 初期実行時にリスニング対象ドキュメントのデータが全取得される。(フラグはadded)
    func membersListener(id currentTeamID: String) async {
        let membersRef = db?
            .collection("teams")
            .document(currentTeamID)
            .collection("members")
        guard let membersRef else { return }

        membersListener = membersRef.addSnapshotListener { snapshot, error in
            if let error {
                print("membersListener起動失敗: \(error.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else { return }
                print("teamListener開始")

                do {
                    self.members = documents.compactMap { (snap) -> JoinMember? in
                        return try? snap.data(as: JoinMember.self, with: .estimate)
                    }
                    print("メンバーデータを更新")
                } catch {
                    print("メンバーデータ更新失敗")
                }
            }
        }
    }

    func addTeamToFirestore(teamData: Team) async throws {
        print("addTeamAndGetID実行")

        let teamsRef = db?
            .collection("teams")
            .document(teamData.id)

        do {
            _ = try teamsRef?.setData(from: teamData)
        } catch {
            print("Error: try db!.collection(collectionID).addDocument(from: itemData)")
            throw CustomError.setData
        }
        print("addTeamAndGetID完了")
    }

    /// ユーザーが所属しているチーム全てに保存されている自身のメンバーデータを更新する。
    /// ユーザーデータの変更を行った時に、各チームのユーザーステートを揃えるために使う。
    func updateJoinTeamsMyData(from updatedData: User, joins: [JoinTeam]) async throws {
        guard var myJoinMember = self.myJoinMemberData else {
            throw TeamRelatedError.missingData
        }

        /// データの更新
        myJoinMember.name = updatedData.name
        myJoinMember.iconURL = updatedData.iconURL

        joins.compactMap { team in
            do {
                try db?
                    .collection("teams")
                    .document(team.id) // 所属チームの一つ
                    .collection("members")
                    .document(myJoinMember.id)
                    .setData(from: myJoinMember)
            } catch {
                UserRelatedError.failedUpdateJoinsMyMemberData
            }
        }
    }

    /// 新規チーム作成時に使用するメソッド。作成者のメンバーデータを新規チームのサブコレクションに保存する。
    func addFirstMemberToFirestore(teamId: String, data userData: User) async throws {
        print("addFirstMemberData実行")
        let membersRef = db?
            .collection("teams")
            .document(teamId)
            .collection("members")

        let newMemberData = JoinMember(id: userData.id,
                                       name: userData.name,
                                       iconURL: userData.iconURL)
        do {
            _ = try membersRef?
                .document(userData.id)
                .setData(from: newMemberData)
        }
    }
    /// チームのサブコレクション「members」に、新規加入したユーザーのデータを保存するメソッド。
    ///
    func addDetectedNewMember(for detectedUser: User) async throws {
        guard let team else { throw CustomError.teamEmpty }
        let memberRef = db?
            .collection("teams")
            .document(team.id)
            .collection("members")
            .document(detectedUser.id)

        do {
            for memberId in self.membersId where detectedUser.id == memberId {
                throw CustomError.memberDuplication
            }

            let newMemberData = JoinMember(id: detectedUser.id,
                                           name: detectedUser.name,
                                           iconURL: detectedUser.iconURL)

            _ = try memberRef?.setData(from: newMemberData)
        }
    }

    /// チーム作成時にデフォルトのサンプルアイテムを追加するメソッド。
    func setSampleItem(itemsData: [Item] = sampleItems, teamID: String) async {

        let itemsRef = db?
            .collection("teams")
            .document(teamID)
            .collection("items")

        for itemData in itemsData {
            do {
                /// サンプルアイテムデータのteamIDとタグを更新する
                var itemData = itemData
                itemData.teamID = teamID

                try db?
                    .collection("teams")
                    .document(teamID)
                    .collection("items")
                    .addDocument(from: itemData)

            } catch {
                print("Error: addDocument(from: \(itemData.name)")
            }
        }
    }

    // メンバー招待画面で取得した相手のユーザIDを使って、Firestoreのusersからデータをフェッチ
    func fetchDetectUserData(id userID: String) async throws -> User? {

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
    /// チーム参加を許可したユーザーに対して、チーム情報（joinTeam）を渡すメソッド。
    /// Firestoreのusersコレクションの中から、相手ユーザードキュメントのサブコレクション（joins）にデータをセットする。
    func addJoinTeamToDetectedMember(for detectedUser: User) async throws {
        guard let team else { throw CustomError.teamEmpty }

        /// 現在のチームのjoinTeamデータを生成
        let joinTeamContainer = JoinTeam(id: team.id,
                                         name: team.name,
                                         iconURL: team.iconURL,
                                         currentBackground: sampleBackground,
                                         approved: false)
        do {
            try db?
                .collection("users")
                .document(detectedUser.id)
                .collection("joins")
                .document(team.id)
                .setData(from: joinTeamContainer)

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

    /// 現在操作しているチームのcreateTime(Date)から、現在までの使用日数を算出するメソッド。
    func getUsageDayCount() -> Int {
        guard let team else { return 0 }
        let nowDate = Date()
        /// チーム作成日時と現在日時の差分から利用日数を取得
        let timeInterval = team.createTime.distance(to: nowDate)
        let usageDay = Int(ceil(timeInterval / 60 / 60 / 24)) // ceil -> 小数点切り上げ

        return usageDay
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

    /// デフォルト付属の背景イメージデータ群から一つのUIImageをランダムで取り出すメソッド
    func getRandomBackgroundUIImage() -> UIImage? {

        let pickUpBackground: UIImage?
        let pickUpBackgroundCategory = BackgroundCategory.allCases.randomElement()

        guard let getCategory = pickUpBackgroundCategory else { return nil }
        guard let getImageString = getCategory.imageContents.randomElement() else {return nil }
        pickUpBackground = UIImage(named: getImageString)
        print(pickUpBackground)

        return pickUpBackground
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

    func updateTeam(data updatedTeamData: Team) async throws {

        // 取得アイコンデータurlがnilだったら処理終了
        guard let team else { throw CustomError.teamEmpty }
        let teamRef = db?
            .collection("teams")
            .document(team.id)

        do {
            // 更新前の元々のアイコンパスを保持しておく
            // 更新成功が確認できてから以前のアイコンデータを削除する
            let defaultIconPath = team.iconPath
            _ = try teamRef?.setData(from: updatedTeamData)
            // アイコンデータは変えていない場合、削除処理をスキップする
            if defaultIconPath != updatedTeamData.iconPath {
                await deleteTeamImageData(path: defaultIconPath)
            }
        } catch {
            // アイコンデータ更新失敗のため、保存予定だったアイコンデータをfirestorageから削除
            await deleteTeamImageData(path: updatedTeamData.iconPath)
            print("ERROR: updateTeam")
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

    /// 選択されたチーム内の自身のメンバーデータを削除するメソッド。
    /// チーム脱退操作が実行された時に使う。
    func deleteMyMemberDataFromTeam(for selectedTeam: JoinTeam) async throws {
        guard let uid else { throw TeamRelatedError.uidEmpty }

        do {
            try await db?
                .collection("teams")
                .document(selectedTeam.id)
                .collection("members")
                .document(uid)
                .delete() // 削除

        } catch {
            throw UserRelatedError.failedEscapeTeam
        }
    }

    /// 選択されたチームの画像関連データをFirestorageから削除するメソッド。
    /// 主にチーム脱退処理が行われた際に使う。
    func deleteEscapingTeamImages(for escapingTeam: Team?) async {
        guard let escapingTeam else { return }

        /// 削除する画像データのファイルパスを配列に格納
        var teamImagesPath: [String?]
        teamImagesPath = [escapingTeam.iconPath,
                          escapingTeam.backgroundPath]
        
        let storage = Storage.storage()
        let reference = storage.reference()
        
        for path in teamImagesPath {
            guard let path else { continue }
            let imageRef = reference.child(path)
            imageRef.delete { error in
                if let error {
                    print("チーム画像の削除失敗")
                    print(error.localizedDescription)
                }
            }
        } // for in
    }
    /// ユーザーが選択したチームのデータを削除する
    func deleteSelectedTeamDocuments(selected selectedTeam: JoinTeam) async throws {
        let teamRef = db?
            .collection("teams")
            .document(selectedTeam.id)

        do {
            let document = try await teamRef?.getDocument()
            let escapingTeam = try await document?.data(as: Team.self)
            await deleteEscapingTeamImages(for: escapingTeam)
            try await teamRef?.delete()

        } catch {
            print("脱退チームのドキュメント削除失敗")
            throw TeamRelatedError.failedDeleteTeamDocuments
        }
    }
    /// チームの保持しているアイテムドキュメントを全て削除するメソッド。
    func deleteAllTeamItems() async {
        guard let team else { return }
        guard let itemsRef = db?.collection("teams").document(team.id).collection("items") else { return }
        do {
            let snapshot = try await itemsRef.getDocuments()
            for document in snapshot.documents {
                _ = try await document.reference.delete()
            }
        } catch {
            print("チームアイテムの削除に失敗しました")
        }
    }

    /// チームの保持しているタグドキュメントを全て削除するメソッド。
    func deleteAllTeamTags() async {
        guard let team else { return }
        guard let itemsRef = db?.collection("teams").document(team.id).collection("tags") else { return }
        do {
            let snapshot = try await itemsRef.getDocuments()
            for document in snapshot.documents {
                _ = try await document.reference.delete()
            }
        } catch {
            print("チームアイテムの削除に失敗しました")
        }
    }

    /// アカウント削除時に実行されるメソッド。削除実行アカウントが所属する全てのチームのデータを削除する
    /// ✅所属チームのメンバーが削除アカウントのユーザーのみだった場合 ⇨ チームデータを全て消去
    /// ✅所属チームのメンバーが削除アカウントのユーザー以外にも在籍している場合 ⇨ 関連ユーザーデータのみ削除
    func deleteAccountRelatedTeamData(uid userID: String, joinsTeam: [JoinTeam]) async throws {

        var joinsTeamID: [String] = []
        // ユーザが参加している各チームのid文字列データを配列に格納(whereFieldクエリで使う)
        for joinTeam in joinsTeam {
            joinsTeamID.append(joinTeam.id)
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

                    if self.membersId.count == 1 &&
                        self.membersId.first == userID {
                        // 削除対象ユーザーの他にチームメンバーが居なかった場合、全データをFirestoreから削除
                        _ = await deleteAllTeamTags()
                        _ = await deleteAllTeamItems()
                        _ = try await teamRowDocument.reference.delete()

                    } else {
                        // 削除対象ユーザーの他にもチーム所属者がいた場合、自身のみmembersから処理し、保存
//                        teamData.membersId.removeAll(where: { $0 == userID })
                        try teamRowRef.setData(from: teamData)
                    }
                }
            }
        }
    }

    deinit {
        teamListener?.remove()
        membersListener?.remove()
    }
}

enum TeamRelatedError:Error {
    case uidEmpty
    case joinsEmpty
    case referenceEmpty
    case missingData
    case missingSnapshot
    case failedCreateJoinTeam
    case failedFetchUser
    case failedFetchAddedNewUser
    case failedTeamListen
    case failedUpdateLastLogIn
    case failedDeleteTeamDocuments
}
