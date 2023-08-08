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

/// チームに保存されているチームログを管理するクラス。
class LogViewModel: ObservableObject {
    init() { print("<<<<<<<<<  LogsViewModel_init  >>>>>>>>>") }
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var listener: ListenerRegistration?
    var uid: String? { Auth.auth().currentUser?.uid }

    /// Firestoreから取得したチームのログデータを管理するプロパティ。
    @Published var logs: [Log] = []

    @Published var currentNotification: Log?

    func listener(id currentTeamID: String?) {
        print("LogsViewModel_listener実行")
        guard let uid, let currentTeamID else { return }
        guard let logsRef = db?.collection("teams")
            .document(currentTeamID)
            .collection("logs") else { return }

        listener = logsRef.addSnapshotListener { (snapshot, _) in
            print("LogListener起動")
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

    /// アイテムや新規通知をチーム内の各メンバーに渡すメソッド。
    func addLog(team: Team?, type logType: LogType) {
        guard var team else { return }
        guard let myMemberData = getCurrentTeamMyMemberData(team: team) else { return }

        let newLog = Log(createTime: Date(),
                         editByIcon: myMemberData.iconURL,
                         type: logType)
        guard let logsRef = db?
            .collection("teams")
            .document(team.id)
            .collection("logs").document(newLog.id) else { return }

        do {
            _ = try logsRef.setData(from: newLog)
        } catch {
            print("Error: setNotification")
        }
    }

    /// 現在の操作チームのメンバーidを取得するメソッド。。
    func getCurrentTeamMyMemberData(team: Team) -> JoinMember? {
        let getGyMemberData = team.members.first(where: { $0.memberUID == uid })
        return getGyMemberData
    }

    deinit {
        listener?.remove()
    }
}
