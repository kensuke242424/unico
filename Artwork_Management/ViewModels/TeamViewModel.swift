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

        do {
            let teamDocument = try await db?
                .collection("teams")
                .document(teamID)
                .getDocument()

            let teamData = try teamDocument?.data(as: Team.self)
            self.team =  teamData
        } catch {
            print("ERROR: チームデータ取得失敗")
            throw CustomError.fetch
        }
    }

    /// チームデータの追加・更新・削除のステートを管理するリスナーメソッド。
    /// 初期実行時にリスニング対象ドキュメントのデータが全取得される。(フラグはadded)
    func teamListener(id currentTeamID: String) async throws {

        teamListener = db?
            .collection("teams")
            .document(currentTeamID)
            .addSnapshotListener { snap, error in
            if let error {
                print("teamListener失敗: \(error.localizedDescription)")
            } else {

                do {
                    let teamData = try snap!.data(as: Team.self)
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

        membersListener = db?
            .collection("teams")
            .document(currentTeamID)
            .collection("members")
            .addSnapshotListener { snap, error in

                if let error {
                    print("ERROR: \(error.localizedDescription)")
                } else {

                    do {
                        self.members = snap!.documents.compactMap {
                            return try? $0.data(as: JoinMember.self, with: .estimate)
                        }
                    } catch {
                        print("メンバーデータ更新失敗")
                    }
                }
            }
    }

    /// Firestoreの「teams」コレクションに、新規チームを保存するメソッド。
    func addNewTeam(team newAddTeam: Team) async throws {

        do {
            try db?
                .collection("teams")
                .document(newAddTeam.id)
                .setData(from: newAddTeam)
        } catch {
            print("ERROR: 新規チームの保存失敗")
            throw CustomError.setData
        }
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
                print("ERROR: JoinTeam更新失敗")
                UserRelatedError.failedUpdateJoinsMyMemberData
            }
        }
    }

    /// 新規チーム作成時に使用するメソッド。作成者のメンバーデータを新規チームのサブコレクションに保存する。
    func addFirstMemberToFirestore(teamId: String, data userData: User) async throws {

        let newMemberData = JoinMember(id: userData.id,
                                       name: userData.name,
                                       iconURL: userData.iconURL)
        do {
            try db?
                .collection("teams")
                .document(teamId)
                .collection("members")
                .document(userData.id)
                .setData(from: newMemberData)
        } catch {
            throw TeamRelatedError.filedAddFirstMember
        }
    }
    /// チームのサブコレクション「members」に、新規加入したユーザーのデータを保存するメソッド。
    func setDetectedNewMember(from detectedUser: User) async throws {
        guard let team else { throw CustomError.teamEmpty }

        // 対象ユーザーがすでにメンバー加入済みであるかをチェック
        for memberId in self.membersId where detectedUser.id == memberId {
            throw CustomError.memberDuplication
        }

        let newMemberData = JoinMember(id: detectedUser.id,
                                       name: detectedUser.name,
                                       iconURL: detectedUser.iconURL)
        do {
            try db?
                .collection("teams")
                .document(team.id)
                .collection("members")
                .document(detectedUser.id)
                .setData(from: newMemberData)
        }
    }

    /// チーム作成時にデフォルトのサンプルアイテムを追加するメソッド。
    func setSampleItem(sampleItems: [Item] = sampleItems, teamID: String) async {

        sampleItems.compactMap { item in
            /// サンプルアイテムのteamIdを新規チームのIdに更新する
            var item = item
            item.teamID = teamID

            do {
                try db?
                    .collection("teams")
                    .document(teamID)
                    .collection("items")
                    .addDocument(from: item)

            } catch {
                print("ERROR: サンプルアイテム\(item.name)の追加失敗")
            }
        }
    }

    // メンバー招待画面で取得した相手のユーザIDを使って、Firestoreのusersからデータをフェッチ
    func fetchDetectUserData(id userID: String) async throws -> User? {

        do {
            let detectUserDocument = try await db?
                .collection("users")
                .document(userID)
                .getDocument()

            let detectUserData = try detectUserDocument?.data(as: User.self)
            return detectUserData
        } catch {
            print("detectUserFetchData_失敗")
            throw CustomError.getDetectUser
        }
    }

    /// チーム参加を許可したユーザーに対して、チーム情報（joinTeam）を渡すメソッド。
    /// Firestoreのusersコレクションの中から、相手ユーザードキュメントのサブコレクション（joins）にデータをセットする。
    func passJoinTeamToDetectedMember(for detectedUser: User, from currentJoinTeam: JoinTeam?) async throws {
        guard let currentJoinTeam else { throw TeamRelatedError.missingData }

        // 相手に渡すjoinTeamデータを生成
        var passJoinTeam = currentJoinTeam
        // 背景データはサンプル背景に差し替える
        passJoinTeam.currentBackground = sampleBackground
        // approvedをfalseとして渡すことで、相手に届いた時に参加通知が発火する
        passJoinTeam.approved = false

        do {
            try db?
                .collection("users")
                .document(detectedUser.id)
                .collection("joins")
                .document(passJoinTeam.id)
                .setData(from: passJoinTeam)

        } catch {
            print("ERROR: 新規参加ユーザーへのJoinTeam譲渡失敗")
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
    /// ユーザー作成時は既存のチームIDが存在しないため、View側で生成したidを受け取ってpathを生成する
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

    func deleteImage(path: String?) async {

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

    func updateTeam(data updatedTeamData: Team) async throws {
        guard let team else { throw CustomError.teamEmpty }

        // 更新前の元々のアイコンパスを保持しておく
        // 更新成功が確認できてから以前のアイコンデータを削除する
        let defaultIconPath = team.iconPath

        do {
            try db?
                .collection("teams")
                .document(team.id)
                .setData(from: updatedTeamData)
        } catch {
            // アイコンデータが変更されていた場合は、firestorageから画像を削除
            if defaultIconPath != updatedTeamData.iconPath {
                await deleteImage(path: updatedTeamData.iconPath)
            }
            print("ERROR: チーム更新失敗")
            throw TeamRelatedError.failedUpdateTeam
        }
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
            print("ERROR: 脱退チームのドキュメント削除失敗")
            throw UserRelatedError.failedEscapeTeam
        }
    }

    /// 選択されたチームの画像関連データをFirestorageから削除するメソッド。
    /// 主にチーム脱退処理が行われた際に使う。
    func deleteTeamImages(for team: Team?) async {
        guard let team else { return }

        /// 削除する画像データのファイルパスを配列に格納
        var teamImagesPath: [String?]
        teamImagesPath = [team.iconPath,
                          team.backgroundPath]
        
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
    /// ユーザーが選択したチームのデータを全て削除する
    func deleteEscapedTeamDocuments(for selectedteam: JoinTeam?) async throws {
        guard let selectedteam else { throw TeamRelatedError.missingData }
        let teamRef = db?
            .collection("teams")
            .document(selectedteam.id)

        do {
            let document = try await teamRef?.getDocument()
            let escapedTeam = try document?.data(as: Team.self)
            // Firestorageから画像データ削除
            await deleteImage(path: escapedTeam?.iconPath)

            await deleteImage(path: escapedTeam?.backgroundPath)
            // チームドキュメントを削除
            try await teamRef?.delete()

        } catch {
            print("脱退チームのドキュメント削除失敗")
            throw TeamRelatedError.failedDeleteTeamDocuments
        }
    }
    /// チームの保持しているアイテムドキュメントを全て削除するメソッド。
    /// ユーザーがチーム脱退やアカウント削除を行った際に、"チームに他のメンバーが存在しない"場合に使用される。
    func deleteTeamItemsDocument(teamId: String) async throws {

        do {
            let snapshot = try await db?
                .collection("teams")
                .document(teamId)
                .collection("items")
                .getDocuments()

            guard let snapshot else { return }

            for document in snapshot.documents {
                let item = try document.data(as: Item.self)
                try await document.reference.delete() // ドキュメント削除
                await deleteImage(path: item.photoPath) // 画像データ削除
            }
        } catch {
            print("ERROR: 脱退チームのアイテム削除失敗")
            throw TeamRelatedError.failedDeleteEscapeTeamItems
        }
    }

    /// チームの保持しているタグドキュメントを全て削除するメソッド。
    /// ユーザーがチーム脱退やアカウント削除を行った際に、"チームに他のメンバーが存在しない"場合に使用される。
    func deleteTeamTagsDocument(teamId: String) async throws {

        do {
            let snapshot = try await db?
                .collection("teams")
                .document(teamId)
                .collection("tags")
                .getDocuments()

            guard let snapshot else { throw TeamRelatedError.missingSnapshot }

            for document in snapshot.documents {
                try await document.reference.delete() // タグ削除
            }
        } catch {
            print("チームタグの削除失敗")
            throw TeamRelatedError.failedDeleteEscapeTeamTags
        }
    }
    /// チーム内のサブコレクション「members」のドキュメントを削除するメソッド。
    /// メンバーがサブコレクションとして持つログデータ「logs」を全て削除した後、ドキュメント本体を削除する。
    ///MEMO: ドキュメント本体だけを削除してもサブコレクションのデータは残るので注意
    func deleteTeamMemberDocument(teamId: String?, memberId: String?) async throws {
        guard let teamId, let memberId else { throw TeamRelatedError.missingData }

        do {
            // ログデータ全てのスナップショットを取得
            let logsSnapshot = try await db?
                .collection("teams")
                .document(teamId)
                .collection("members")
                .document(memberId)
                .collection("logs")
                .getDocuments()

            // ログデータ全てのドキュメントを削除
            let _ = logsSnapshot?.documents.compactMap { document in
                document.reference.delete()
            }
            // メンバードキュメントを削除
            try await db?
                .collection("teams")
                .document(teamId)
                .collection("members")
                .document(memberId)
                .delete()

        } catch {
            print("ERROR: メンバーデータの削除失敗")
            throw TeamRelatedError.failedDeleteMemberDocuments
        }
    }
    /// ユーザーが持つ所属チームデータサブコレクション「joins」のドキュメントを全て削除するメソッド。
    func deleteUserAllJoinsDocuments(joins joinTeams: [JoinTeam]) async throws {
        guard let uid else { throw TeamRelatedError.uidEmpty }

        do {
            // ユーザーが持つjoinsサブコレクションのスナップショット取得
            let joinsSnapshot = try await db?
                .collection("users")
                .document(uid)
                .collection("joins")
                .getDocuments()

            guard let joinsSnapshot else { throw TeamRelatedError.missingSnapshot }

            for document in joinsSnapshot.documents {
                try await document.reference.delete()
            }
        } catch {

        }
    }
    /// チームに所属しているメンバーのメンバーIdを取得するメソッド。
    func getMembersId(teamId: String?) async throws -> [String]? {
        guard let teamId else { throw TeamRelatedError.missingData }

        /// 所属チームメンバー全員のスナップショットを取得
        let membersSnapshot = try await db?
            .collection("teams")
            .document(teamId)
            .collection("members")
            .getDocuments()

        // メンバー全員のidを取得
        return membersSnapshot?.documents.compactMap {$0.documentID}
    }

    /// アカウント削除時に実行されるメソッド。削除実行アカウントが所属する全てのチームのデータを削除する
    /// ✅所属チームのメンバーが削除アカウントのユーザーのみだった場合 ⇨ チームデータを全て消去
    /// ✅所属チームのメンバーが削除アカウントのユーザー以外にも在籍している場合 ⇨ 関連ユーザーデータのみ削除
    func deleteAllDocumentsController(joins joinTeams: [JoinTeam]) async throws {
        guard let uid else { throw TeamRelatedError.uidEmpty }

        // ユーザーが所属している全チームのリファレンス群を取得
        var teamRefs = joinTeams.compactMap {
            return db?
                .collection("teams")
                .document($0.id)
        }

        do {
            // 各所属チームのリファレンスごとに削除処理を実行していく
            for teamRef in teamRefs {
                /// チームのドキュメントId
                let teamId = teamRef.documentID
                /// 所属チームメンバー全員のスナップショットを取得
                let membersSnapshot = try await teamRef
                    .collection("members")
                    .getDocuments()

                // メンバー全員のidを取得
                let membersId: [String] = membersSnapshot.documents.compactMap {$0.documentID}

                if membersId.count == 1 &&
                    membersId.first == uid {
                    // ⚠️チーム内に自分以外のメンバーが居なかった場合、全データをFirestoreから削除
                    try await deleteTeamMemberDocument(teamId: teamId, memberId: uid)
                    try await deleteTeamTagsDocument(teamId: teamId)
                    try await deleteTeamItemsDocument(teamId: teamId)
                    try await teamRef.delete() // 最後にチームドキュメントを削除

                } else {
                     // 削除対象ユーザーの他にもチーム所属者がいた場合、自身のみmembersサブコレクションから削除
                    try await deleteTeamMemberDocument(teamId: teamId, memberId: uid)
                }
            } // for teamRef in teamRefs
        } // do
    }

    func removeListener() {
        teamListener?.remove()
        membersListener?.remove()
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
    case filedAddFirstMember
    case failedFetchUser
    case failedUpdateTeam
    case failedFetchAddedNewUser
    case failedTeamListen
    case failedUpdateLastLogIn
    case failedDeleteTeamDocuments
    case failedDeleteEscapeTeamItems
    case failedDeleteEscapeTeamTags
    case failedDeleteMemberDocuments
}
