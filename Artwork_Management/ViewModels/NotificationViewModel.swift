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

    init() { print("<<<<<<<<<  NotificationViewModel_init  >>>>>>>>>") }

    var listener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { return Auth.auth().currentUser?.uid }

    @Published var boardFrames: [NotifyFrame] = []

    /// チームドキュメント内の自身のデータ(teamMember)のnotificationsテーブルを監視して、
    /// 新しい通知が来たら自動取得し、画面に表示させるためのリスナー。
//    @MainActor
//    func notificationListener(team: Team?) {
//        print("notificationListener実行")
//        guard var team else { return }
//        guard let teamRef = db?.collection("teams").document(team.id) else { return }
//
//        listener = teamRef.addSnapshotListener { snap, error in
//            if let error {
//                print("notificationListener失敗: \(error.localizedDescription)")
//            } else {
//                guard let snap else {
//                    print("notificationListener: snapがnilです")
//                    return
//                }
//                do {
//                    let team = try snap.data(as: Team.self)
//                    guard let myData = team.members.first(where: {$0.memberUID == self.uid}) else { return }
//                    for notify in myData.notifications {
//                        self.boardFrames.append(notify)
//                    }
//
//                    print("notificationListenerが新しい通知データを取得")
//                } catch {
//                    print("notificationListener: try snap?.data(as: Team.self)")
//                }
//            }
//        }
//    }

    @MainActor
    func notificationListener(id teamID: String?) {
        print("notificationListener実行")
        guard var teamID else { return }
        guard let uid else { return }
        let myMemberRef = db?.collection("teams").document(teamID)
//            .whereField("memberUID", isEqualTo: uid)
        guard let myMemberRef else {
            print("ERROR: myMemberRef nil")
            return
        }

        listener = myMemberRef.addSnapshotListener { snapshot, error in
            if let error {
                print("notificationListener失敗: \(error.localizedDescription)")

            } else {
                guard let snapshot else { print("snap_nil"); return}


                do {
                    let myMemberData = try snapshot.data(as: JoinMember.self)
                    for notify in myMemberData.notifications {
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
            NotifyFrame(type: type.self,
                       message: type.message,
                       imageURL: type.imageURL,
                       exitTime: type.waitTime)
        )
    }

    /// アイテムや新規通知をチーム内の各メンバーに渡すメソッド。
    func setNotificationToFirestore(team: Team?, type: NotificationType) {
        guard var team else { return }
        guard let teamRef = db?.collection("teams").document(team.id) else { return }
        let notification = NotifyFrame(type: type,
                                    message: type.message,
                                    imageURL: type.imageURL,
                                    exitTime: type.waitTime)
        for index in team.members.indices {
            team.members[index].notifications.append(notification)
        }

        do {
            _ = try teamRef.setData(from: team)
        } catch {
            print("Error: setNotificationToFirestore")
        }
    }
    /// 通知を自身のメンバーデータ内から削除するメソッド。
    func removeNotificationToFirestore(team: Team?, data: NotifyFrame) {
        guard var team else { return }
        guard let teamRef = db?.collection("teams").document(team.id) else { return }

        guard let index = team.members.firstIndex(where: { $0.memberUID == uid }) else { return }
        team.members[index].notifications.removeAll(where: { $0.id == data.id })

        do {
            _ = try teamRef.setData(from: team)
        } catch {
            print("Error: setNotificationToFirestore")
        }
    }

    deinit {
        listener?.remove()
    }
}
