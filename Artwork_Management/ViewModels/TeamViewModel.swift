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

    /// チームデータの追加・更新・削除のステートを管理するリスナーメソッド。
    /// 初期実行時にリスニング対象ドキュメントのデータが全取得される。(フラグはadded)
    func teamListener(id currentTeamID: String) async throws {
        teamListener = FirestoreReference
            .teams.collectionReference
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

        membersListener = FirestoreReference
            .members(teamId: currentTeamID)
            .collectionReference
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

    func setTeam(data: Team) async {
        do {
            try await Team.setData(path: .teams, docId: data.id, data: data)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// メンバーデータを指定チームのサブコレクション「members」に保存する。
    func setMember(teamId: String, data userData: User) async {

        let newMemberData = JoinMember(id: userData.id,
                                       name: userData.name,
                                       iconURL: userData.iconURL)
        do {
            try await JoinMember.setData(path: .members(teamId: teamId),
                                         docId: newMemberData.id,
                                         data: newMemberData)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// ユーザーが所属しているチーム全てに保存されている自身のメンバーデータを更新する。
    /// ユーザーデータの変更を行った時に、各チームのユーザーステートを揃えるために使う。
    func updateJoinTeamsMyMemberData(from updatedData: User, joins: [JoinTeam]) async {
        guard var myMemberData = self.self.myJoinMemberData else {
            assertionFailure("自身のメンバーデータが存在しません")
            return
        }

        /// データの更新
        myMemberData.name = updatedData.name
        myMemberData.iconURL = updatedData.iconURL

        for team in joins {
            do {
                try await Team.setMember(teamId: team.id, data: myMemberData)

            } catch let error as FirestoreError {
                print(error.localizedDescription)
            } catch {
                print("未知のエラー: \(error.localizedDescription)")
            }
        }
    }

    /// 対象ユーザーがすでにメンバー加入済みであるかをチェックするメソッド
    func isUserAlreadyMember(userId: String) -> Bool {
        return self.membersId.contains(userId)
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

    func setSampleData(teamId: String) async {
        await Team.setSampleItems(teamId: teamId)
        await Tag.setSampleTag(teamId: teamId)
    }

    /// チームに所属しているメンバーのメンバーIdを取得するメソッド。
    func fetchMembersId(teamId: String?) async throws -> [String]? {
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

    /// アカウント削除時に実行されるメソッド。削除実行アカウントが所属する全てのチームのデータを削除する
    /// ✅所属チームのメンバーが削除アカウントのユーザーのみだった場合 ⇨ チームデータを全て消去
    /// ✅所属チームのメンバーが削除アカウントのユーザー以外にも在籍している場合 ⇨ 関連ユーザーデータのみ削除
    func deleteAllTeamDocumentsController(joins joinTeams: [JoinTeam]) async throws {
        guard let uid else { throw TeamRelatedError.uidEmpty }

        // joinsデータのidを元に、ユーザーが所属している全チームのリファレンスIdを取得
        var teamRefs = joinTeams.compactMap {
            return db?
                .collection("teams")
                .document($0.id)
        }

        do {
            // 各所属チームのリファレンスごとに削除処理を実行していく
            for teamRef in teamRefs {
                let teamId = teamRef.documentID
                let membersId = try await fetchMembersId(teamId: teamId)
                // メンバーデータが存在しなかった場合は処理を中断し、別のチーム処理を再スタート
                guard let membersId else {
                    print("ERROR: チーム内にメンバーデータが存在しない")
                    continue
                }

                if membersId.count == 1 && membersId.first == uid {
                    // ✅チーム内に自分以外のメンバーが居なかった場合、チームの全データをFirestoreから削除
                    try await deleteTeamMemberDocument(teamId: teamId, memberId: uid)
                    try await deleteTeamTagsDocument(teamId: teamId)
                    try await deleteTeamItemsDocument(teamId: teamId)
                    try await teamRef.delete() // 最後にチームドキュメントを削除

                } else {
                     // ✅他にもチームメンバーが残っている場合、自身のmemberデータのみ削除
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
        removeListener()
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
