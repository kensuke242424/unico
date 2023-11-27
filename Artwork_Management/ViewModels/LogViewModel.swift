//
//  LogsViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/08.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

/// チームのデータ編集履歴を管理するクラス。
class LogViewModel: ObservableObject, FirebaseErrorHandling {

    //TODO: 変更履歴が閲覧できるリストページの作成
    /// Firestoreから取得したチームのログデータを管理するプロパティ。
    @Published var logs: [Log] = []

    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var listener: ListenerRegistration?
    var uid: String? { Auth.auth().currentUser?.uid }

    func logListener(id currentTeamID: String?) {
        guard let currentTeamID else { return }

        listener = db?
            .collection("teams")
            .document(currentTeamID)
            .collection("logs")
            .limit(to: 30)
            .addSnapshotListener { (snapshot, _) in

                guard let documents = snapshot?.documents else { return }

                self.logs = documents.compactMap { (snap) -> Log? in
                    do {
                        return try snap.data(as: Log.self, with: .estimate)
                    }catch {
                        self.handleErrors([error])
                        return nil
                    }
                }
            }
    }

    /// アイテムや新規通知をチームのサブコレクション「members」の各メンバーデータに渡すメソッド。
    func addLog(to team: Team?, by user: User?,  type logType: LogType) async {
        guard let team, let user else { assertionFailure("user, team: nil"); return }

        let newLog = Log(id: UUID().uuidString,
                         teamId    : team.id,
                         createTime: Date(),
                         editByIconURL: user.iconURL,
                         logType      : logType)

        do {
            let memberRefs = try await JoinMember.getDocuments(.members(teamId: team.id))

            for member in memberRefs.documents {
                let memberId = member.documentID
                // ログのセットタイプが.localの場合、自身だけにログを追加する
                if logType.setRule == .global || memberId == user.id {
                    try await Log.setData(.logs(teamId: team.id, memberId: memberId),
                                          docId: newLog.id,
                                          data: newLog)
                }
            }
        } catch {
            handleErrors([error])
        }
    }

    deinit {
        listener?.remove()
    }
}
