//
//  NotificationViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class NotificationViewModel: ObservableObject {

    var listener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { return Auth.auth().currentUser?.uid }

    @Published var boardFrames: [BoardFrame] = []

    /// チームドキュメント内の自身のデータ(teamMember)のnotificationsテーブルを監視して、
    /// 新しい通知が来たら自動取得し、画面に表示させるためのリスナー。
    @MainActor
    func notificationListener(team: Team?) {
        print("notificationListener実行")
        guard var team else { return }
        guard let teamRef = db?.collection("teams").document(team.id) else { return }

        listener = teamRef.addSnapshotListener { snap, error in
            if let error {
                print("notificationListener失敗: \(error.localizedDescription)")
            } else {
                guard let snap else {
                    print("notificationListener: snapがnilです")
                    return
                }
                do {
                    let team = try snap.data(as: Team.self)
                    guard let myData = team.members.first(where: {$0.memberUID == self.uid}) else { return }
                    for notify in myData.notifications {
                        self.boardFrames.append(notify)
                    }

                    print("notificationListenerが新しい通知データを取得")
                } catch {
                    print("notificationListener: try snap?.data(as: Team.self)")
                }
            }
        }
    }
    func setNotify(type: NotificationType) {
        boardFrames.append(
            BoardFrame(type: type.self,
                       message: type.message,
                       imageURL: type.imageURL,
                       exitTime: type.waitTime)
        )
    }

    deinit {
        listener?.remove()
    }
}
