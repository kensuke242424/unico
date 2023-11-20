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

class TeamViewModel: ObservableObject {

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
    @Published var alertMessage = ""

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
                    print("チームデータ更新失敗")
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
                    assertionFailure("ERROR: \(error.localizedDescription)")
                } else {

                    do {
                        self.members = snap!.documents.compactMap {
                            return try? $0.data(as: JoinMember.self, with: .estimate)
                        }
                    }
                }
            }
    }

    func setTeam(data: Team) async {
        do {
            try await Team.setData(.teams, docId: data.id, data: data)

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
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

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
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

            } catch let error as FirestoreError {
                print(error.localizedDescription)
            } catch {
                print("未知のエラー: \(error.localizedDescription)")
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
            print("ERROR: 画像のアップロードに失敗")
            return (url: nil, filePath: nil)
        }
    }

    func uploadTeamImage(_ image: UIImage?) async -> (url: URL?, filePath: String?) {
        guard let teamId = team?.id else {
            assertionFailure("teamIdが存在しません")
            return (url: nil, filePath: nil)
        }

        do {
            return try await FirebaseStorageManager.uploadImage(image, .team(teamId: teamId))
        } catch {
            print("ERROR: 画像のアップロードに失敗")
            return (url: nil, filePath: nil)
        }
    }
    
    /// 初期値のサンプルアイテム&タグをFirestoreに保存する。新規チーム作成時に使用。
    func setSampleData(teamId: String) async {
        await Team.setSampleItems(teamId: teamId)
        await Tag.setSampleTag(teamId: teamId)
    }

    /// チームに所属しているメンバーのメンバーIdを取得するメソッド。
    func getMembersId(teamId: String) async -> [String]? {

        do {
            /// 所属チームメンバー全員のスナップショットを取得
            let membersSnapshot = try await JoinMember.getDocuments(.members(teamId: teamId))

            return membersSnapshot?.documents.compactMap {$0.documentID}

        } catch let error as FirestoreError {
            assertionFailure(error.localizedDescription)
            return nil

        } catch {
            assertionFailure("未知のエラー: \(error.localizedDescription)")
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

            await FirebaseStorageManager.deleteImage(path: path)
        }
    }

    /// ユーザーが選択したチームのドキュメントを削除する
    func deleteTeamDocument(for teamId: String) async {
        do {
            let escapedTeam: Team = try await Team.fetch(.teams, docId: teamId)
            // チームドキュメントを削除
            try await Team.deleteDocument(.teams, docId: teamId)
            // チームドキュメントの削除成功後に画像消去
            await FirebaseStorageManager.deleteImage(path: escapedTeam.iconPath)
            await FirebaseStorageManager.deleteImage(path: escapedTeam.backgroundPath)

        } catch let error as FirestoreError {
            print(error.localizedDescription)

        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// チームの保持しているアイテムドキュメントを全て削除するメソッド。
    /// ユーザーがチーム脱退やアカウント削除を行った際に、"チームに他のメンバーが存在しない"場合に使用される。
    func deleteItemDocuments(teamId: String) async {

        do {
            let snapshot = try await Item.getDocuments(.items(teamId: teamId))
            guard let snapshot else { return }

            for document in snapshot.documents {
                let item = try document.data(as: Item.self)

                try await document.reference.delete() // ドキュメント削除
                await FirebaseStorageManager.deleteImage(path: item.photoPath)
            }

        } catch let error as FirestoreError {
            print(error.localizedDescription)

        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// チームの保持しているタグドキュメントを全て削除するメソッド。
    /// ユーザーがチーム脱退やアカウント削除を行った際に、"チームに他のメンバーが存在しない"場合に使用される。
    func deleteTagDocuments(teamId: String) async {

        do {
            try await Tag.deleteDocuments(.tags(teamId: teamId))

        } catch let error as FirestoreError {
            print(error.localizedDescription)
        } catch {
            print("未知のエラー: \(error.localizedDescription)")
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

        do {
            try await JoinMember.deleteDocuments(.logs(teamId: teamId, memberId: memberId))
            try await Team.deleteDocument(.members(teamId: teamId), docId: memberId)

        } catch let error as FirestoreError {
            print(error.localizedDescription)

        } catch {
            print("未知のエラー: \(error.localizedDescription)")
        }
    }

    /// アカウント削除時に実行されるメソッド。削除実行アカウントが所属する全てのチームのデータを削除する
    /// ✅所属チームのメンバーが削除アカウントのユーザーのみだった場合 ⇨ チームデータを全て消去
    /// ✅所属チームのメンバーが削除アカウントのユーザー以外にも在籍している場合 ⇨ 関連ユーザーデータのみ削除
    func deleteAllTeamDocumentsController(joins joinTeams: [JoinTeam]) async throws {
        guard let uid else {
            assertionFailure("uidが存在しません")
            return
        }

        // ユーザーが所属している全チームのリファレンスを取得
        let teamRefs = joinTeams.compactMap {
            return Team.getReference(.teams, docId: $0.id)
        }

        do {
            // 各所属チームのリファレンスごとに削除処理を実行していく
            for teamRef in teamRefs {
                let teamId = teamRef.documentID
                let membersId = await getMembersId(teamId: teamId)

                // メンバーデータが存在しなかった場合は処理を中断し、別のチーム処理を再スタート
                guard let membersId else {
                    print("ERROR: チーム内にメンバーデータが存在しません")
                    continue
                }

                if membersId.count == 1 && membersId.first == uid {
                    // ✅チーム内に自分以外のメンバーが居なかった場合、チームの全データをFirestoreから削除
                    await deleteTeamMemberDocument(teamId: teamId, memberId: uid)
                    await deleteTagDocuments(teamId: teamId)
                    await deleteItemDocuments(teamId: teamId)
                    await deleteTeamDocument(for: teamId)

                } else {
                     // ✅他にもチームメンバーが残っている場合、自身のmemberデータのみ削除
                    await deleteTeamMemberDocument(teamId: teamId, memberId: uid)
                }
            }
        }
    }

    func removeListener() {
        teamListener?.remove()
        membersListener?.remove()
    }

    deinit {
        removeListener()
    }
}
