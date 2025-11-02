//
//  LogInViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class TeamViewModel: ObservableObject, FirebaseErrorHandling {

    init() {
        print("<<<<<<<<<  TeamViewModel_init  >>>>>>>>>")
    }

    var teamListener: ListenerRegistration?
    var membersListener: ListenerRegistration?

    @Published var team: Team?
    @Published var members: [JoinMember] = []

    @Published var isShowCreateAndJoinTeam: Bool = false
    @Published var isShowSearchedNewMemberJoinTeam: Bool = false

    @Published var showErrorAlert = false
    @Published var errorMessage = ""

    var uid: String? { Auth.auth().currentUser?.uid }

    var myMemberIndex: Int? {
        return self.members.firstIndex(where: {$0.id == uid})
    }

    var myMemberData: JoinMember? {
        guard let index = myMemberIndex else { return nil }
        return self.members[index]
    }

    /// 現在の操作しているチームのメンバー全員のIdを格納するプロパティ。
    var memberIds: [String] {
        return self.members.compactMap {$0.id}
    }

    /// Firestoreへのチームデータ追加・更新・削除のステートを監視するリスナーメソッド。
    func teamListener(id currentTeamID: String) async {
        teamListener = Firestore.firestore()
            .collection("teams")
            .document(currentTeamID)
            .addSnapshotListener { snap, error in
            if let error {
                assertionFailure("teamListener失敗: \(error.localizedDescription)")
            } else {

                do {
                    let teamData = try snap!.data(as: Team.self)
                    self.team = teamData
                } catch {
                    self.handleErrors([error])
                }
            }
        }
    }

    /// Firestoreのチームサブコレクション「members」における追加・更新・削除のステートを監視するリスナーメソッド。
    func membersListener(id currentTeamID: String) async {

        membersListener = Firestore.firestore()
            .collection("teams")
            .document(currentTeamID)
            .collection("members")
            .addSnapshotListener { snap, error in
                if let error {
                    assertionFailure("teamListener失敗: \(error.localizedDescription)")
                } else {

                    self.members = snap!.documents.compactMap {
                        do {
                            let member = try $0.data(as: JoinMember.self, with: .estimate)
                            return member

                        } catch {
                            self.handleErrors([error])
                            return nil
                        }
                    }
                }
            }
    }

    func setTeam(data: Team) async {
        do {
            try await Team.setData(.teams, docId: data.id, data: data)

        } catch {
            handleErrors([error])
        }
    }

    /// 渡されたユーザーデータからメンバーデータを作り、指定チームのサブコレクション「members」に保存する。
    func setMember(teamId: String, data userData: User) async {

        let newMemberData = JoinMember(id: userData.id,
                                       name: userData.name,
                                       iconURL: userData.iconURL)
        do {
            try await JoinMember.setData(.members(teamId: teamId),
                                         docId: newMemberData.id,
                                         data: newMemberData)
        } catch {
            handleErrors([error])
        }
    }

    /// ユーザーデータの変更を行った時に、各チームのユーザーステートを揃えるために使う。
    /// ユーザーが所属しているチーム全てに保存されている自身のメンバーデータを更新する。
    func updateJoinTeamsMyMemberData(from updatedData: User, joins: [JoinTeam]) async {
        guard var myMemberData = self.myMemberData else {
            assertionFailure("自身のメンバーデータが存在しません")
            return
        }

        // データの更新
        myMemberData.name = updatedData.name
        myMemberData.iconURL = updatedData.iconURL

        for joinTeam in joins {
            do {
                try await JoinMember.setData(.members(teamId: joinTeam.id),
                                             docId: myMemberData.id,
                                             data: myMemberData)
            } catch {
                handleErrors([error])
            }
        }
    }

    /// 対象ユーザーがすでにメンバー加入済みであるかをチェックするメソッド
    func isUserAlreadyMember(userId: String) -> Bool {
        return self.memberIds.contains(userId)
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
    func firstUploadTeamImage(_ image: UIImage?, id teamId: String) async -> (url: URL?, filePath: String?) {

        do {
            return try await FirebaseStorageManager.uploadImage(image, .team(teamId: teamId))

        } catch {
            handleErrors([error])
            return (url: nil, filePath: nil)
        }
    }

    func uploadTeamImage(_ image: UIImage?, teamId: String?) async -> (url: URL?, filePath: String?) {

        guard let teamId else {
            assertionFailure("teamId: nil")
            return (url: nil, filePath: nil)
        }

        do {
            return try await FirebaseStorageManager.uploadImage(image, .team(teamId: teamId))

        } catch {
            handleErrors([error])
            return (url: nil, filePath: nil)
        }
    }
    
    /// 初期値のサンプルアイテム&タグをFirestoreに保存する。新規チーム作成時に使用。
    func setSampleData(teamId: String) async {
        await Team.setSampleItems(teamId: teamId)
        await Team.setSampleTag(teamId: teamId)
    }

    /// チームに所属しているメンバーのメンバーIdを取得するメソッド。
    func getMembersId(teamId: String) async -> [String]? {

        do {
            /// 所属チームメンバー全員のスナップショットを取得
            let membersSnapshot = try await JoinMember.getDocuments(.members(teamId: teamId))

            return membersSnapshot.documents.compactMap {$0.documentID}

        } catch {
            handleErrors([error])
            return nil
        }
    }

    /// 選択されたチームの画像関連データをFirestorageから削除するメソッド。
    /// 主にチーム脱退処理が行われた際に使う。
    func deleteTeamImages(for team: Team?) async {
        guard let team else {
            assertionFailure("チームデータが存在しません")
            return
        }
        // アイコンと背景のパスを配列に格納
        let teamImagesPath = [team.iconPath, team.backgroundPath]
        
        for path in teamImagesPath {
            guard let path else { continue }

            do {
                try await FirebaseStorageManager.deleteImage(path: path)

            } catch {
                handleErrors([error])
            }
        }
    }

    /// ユーザーが選択したチームのドキュメントを削除する
    func deleteTeamDocument(for teamId: String) async {
        Logger.i("チームドキュメント削除開始: teamId=\(teamId)")
        do {
            // チームが既に削除されている可能性があるため、fetchエラーは無視
            var escapedTeam: Team? = nil
            do {
                escapedTeam = try await Team.fetch(.teams, docId: teamId)
            } catch {
                Logger.i("⚠️ チームドキュメントが既に削除されています（スキップ）")
                return
            }

            // チームドキュメントを削除
            try await Team.deleteDocument(.teams, docId: teamId)
            Logger.i("✅ チームドキュメント削除成功")

            // チームドキュメントの削除成功後に画像消去
            if let iconPath = escapedTeam?.iconPath {
                do {
                    try await FirebaseStorageManager.deleteImage(path: iconPath)
                    Logger.i("✅ チームアイコン画像削除成功")
                } catch {
                    if error.localizedDescription.contains("does not exist") {
                        Logger.i("⚠️ チームアイコン画像が既に削除されています（続行）")
                    } else {
                        Logger.e("❌ チームアイコン画像削除失敗: \(error.localizedDescription)")
                    }
                }
            }
            if let backgroundPath = escapedTeam?.backgroundPath {
                do {
                    try await FirebaseStorageManager.deleteImage(path: backgroundPath)
                    Logger.i("✅ チーム背景画像削除成功")
                } catch {
                    if error.localizedDescription.contains("does not exist") {
                        Logger.i("⚠️ チーム背景画像が既に削除されています（続行）")
                    } else {
                        Logger.e("❌ チーム背景画像削除失敗: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            Logger.e("❌ チームドキュメント削除失敗: \(error.localizedDescription)")
            // 致命的でないエラーのため処理を継続
        }
    }

    /// チームの保持しているアイテムドキュメントを全て削除するメソッド。
    /// ユーザーがチーム脱退やアカウント削除を行った際に、"チームに他のメンバーが存在しない"場合に使用される。
    func deleteItemDocuments(teamId: String) async {
        do {
            let snapshot = try await Item.getDocuments(.items(teamId: teamId))
            let itemCount = snapshot.documents.count

            if itemCount == 0 {
                Logger.i("削除するアイテムなし（スキップ）")
                return
            }

            Logger.i("アイテム削除開始: \(itemCount)件")
            for (index, document) in snapshot.documents.enumerated() {
                let item = try document.data(as: Item.self)
                try await document.reference.delete() // ドキュメント削除
                if let photoPath = item.photoPath {
                    do {
                        try await FirebaseStorageManager.deleteImage(path: photoPath)
                    } catch {
                        // 画像が既に削除されている場合は警告のみ
                        if error.localizedDescription.contains("does not exist") {
                            Logger.i("⚠️ アイテム画像が既に削除されています（続行）: \(item.name)")
                        } else {
                            Logger.e("❌ アイテム画像削除失敗: \(error.localizedDescription)")
                        }
                    }
                }
                Logger.i("✅ アイテム削除成功 (\(index + 1)/\(itemCount)): \(item.name)")
            }
        } catch {
            Logger.e("❌ アイテム削除失敗: \(error.localizedDescription)")
            handleErrors([error])
        }
    }

    /// チームの保持しているタグドキュメントを全て削除するメソッド。
    /// ユーザーがチーム脱退やアカウント削除を行った際に、"チームに他のメンバーが存在しない"場合に使用される。
    func deleteTagDocuments(teamId: String) async {
        Logger.i("タグ削除開始: teamId=\(teamId)")
        do {
            try await Tag.deleteDocuments(.tags(teamId: teamId))
            Logger.i("✅ タグ削除成功")
        } catch {
            Logger.e("❌ タグ削除失敗: \(error.localizedDescription)")
            handleErrors([error])
        }
    }

    /// チーム内のサブコレクション「members」のドキュメントを削除するメソッド。
    /// メンバーがサブコレクションとして持つログデータ「logs」を全て削除した後、ドキュメント本体を削除する。
    ///MEMO: ドキュメント本体だけを削除してもサブコレクションのデータは残るので注意
    func deleteTeamMemberDocument(teamId: String?, memberId: String?) async {
        guard let teamId, let memberId else {
            assertionFailure("チームまたは自身のメンバーIDが存在しません")
            return
        }

        Logger.i("メンバードキュメント削除開始: teamId=\(teamId), memberId=\(memberId)")
        do {
            try await JoinMember.deleteDocuments(.logs(teamId: teamId, memberId: memberId))
            Logger.i("✅ メンバーログ削除成功")
            try await Team.deleteDocument(.members(teamId: teamId), docId: memberId)
            Logger.i("✅ メンバードキュメント削除成功")
        } catch {
            Logger.e("❌ メンバードキュメント削除失敗: \(error.localizedDescription)")
            handleErrors([error])
        }
    }

    /// アカウント削除時に実行されるメソッド。削除実行アカウントが所属する全てのチームのデータを削除する
    /// ✅所属チームのメンバーが削除アカウントのユーザーのみだった場合 ⇨ チームデータを全て消去
    /// ✅所属チームのメンバーが削除アカウントのユーザー以外にも在籍している場合 ⇨ 関連ユーザーデータのみ削除
    func deleteAllJoinsTeamDocumentsController(joins joinTeams: [JoinTeam]) async {
        guard let uid else {
            assertionFailure("uid: nil")
            return
        }

        Logger.i("🔵 === チームデータ削除開始: \(joinTeams.count)チーム ===")

        // ユーザーが所属している全チームのリファレンスを取得
        let teamRefs = joinTeams.compactMap {
            return Team.getDocument(.teams, docId: $0.id)
        }

        // 各所属チームのリファレンスごとに削除処理を実行していく
        for (index, teamRef) in teamRefs.enumerated() {
            let teamId = teamRef.documentID
            let teamName = joinTeams.first(where: { $0.id == teamId })?.name ?? "不明"
            Logger.i("チーム削除処理 (\(index + 1)/\(joinTeams.count)): \(teamName) [id=\(teamId)]")

            let membersId = await getMembersId(teamId: teamId)

            // メンバーデータが存在しなかった場合は処理を中断し、別のチーム処理を再スタート
            guard let membersId else {
                Logger.e("❌ チーム内にメンバーデータが存在しません: \(teamName)")
                continue
            }

            if membersId.count == 1 && membersId.first == uid {
                Logger.i("自分のみがメンバー → チーム全体を削除: \(teamName)")
                // ✅チーム内に自分以外のメンバーが居なかった場合、チームの全データをFirestoreから削除
                await deleteTeamMemberDocument(teamId: teamId, memberId: uid)
                await deleteTagDocuments(teamId: teamId)
                await deleteItemDocuments(teamId: teamId)
                await deleteTeamDocument(for: teamId)
                Logger.i("✅ チーム全体削除完了: \(teamName)")

            } else {
                Logger.i("他のメンバーが存在（\(membersId.count)人） → 自分のメンバーデータのみ削除: \(teamName)")
                // ✅他にもチームメンバーが残っている場合、自身のmemberデータのみ削除
                await deleteTeamMemberDocument(teamId: teamId, memberId: uid)
                Logger.i("✅ メンバーデータ削除完了: \(teamName)")
            }
        } // for文

        Logger.i("🔵 === チームデータ削除完了 ===")
    }

    func removeListener() {
        teamListener?.remove()
        membersListener?.remove()
    }

    deinit {
        removeListener()
    }
}
