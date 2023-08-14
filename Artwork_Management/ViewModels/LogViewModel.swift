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
class LogViewModel: ObservableObject {
    init() { print("<<<<<<<<<  LogsViewModel_init  >>>>>>>>>") }
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var listener: ListenerRegistration?
    var uid: String? { Auth.auth().currentUser?.uid }

    //TODO: 変更履歴が閲覧できるリストページの作成
    /// Firestoreから取得したチームのログデータを管理するプロパティ。
    @Published var logs: [Log] = []

    func listener(id currentTeamID: String?) {
        print("LogsViewModel_listener起動")
        guard let uid, let currentTeamID else { return }
        guard let logsRef = db?
            .collection("teams")
            .document(currentTeamID)
            .collection("logs") else { return }

        listener = logsRef.addSnapshotListener { (snapshot, _) in
            guard let documents = snapshot?.documents else { return }

            do {
                self.logs = documents.compactMap { (snap) -> Log? in
                    return try? snap.data(as: Log.self, with: .estimate)
                }
                print("Logデータ更新")
            }
            catch {
                print("ERROR: try snap?.data(as: Team.self)")
            }
        }
    }

    /// アイテムや新規通知をチームのサブコレクション「members」の各メンバーデータに渡すメソッド。
    func addLog(to team: Team?, by user: User?,  type logType: LogType) {
        guard let team, let user else { return }

        let newLog = Log(id: UUID().uuidString,
                         teamId    : team.id,
                         createTime: Date(),
                         editByIcon: user.iconURL,
                         logType      : logType)

        let membersRef = db?
            .collection("teams")
            .document(team.id)
            .collection("members")

        do {
            membersRef?.getDocuments { (snapshot, _) in
                guard let snapshot else { return }

                snapshot.documents.compactMap { (member) -> () in

                    let memberId = member.documentID

                    // ログのセットタイプが.localの場合、自身だけにログを追加する
                    if logType.setRule == .global || memberId == user.id {
                        try? membersRef?
                            .document(memberId)
                            .collection("logs")
                            .document(newLog.id)
                            .setData(from: newLog, merge: true) // 保存
                    }
                }
            }
        }
    }

    deinit {
        listener?.remove()
    }
}
