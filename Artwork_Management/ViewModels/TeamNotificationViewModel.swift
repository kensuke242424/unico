//
//  TeamNotificationViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/04.
//

import SwiftUI
import Firebase
import FirebaseFirestore

/// チーム全体に届く通知ボードの保存・表示・削除を管理するクラス。
class TeamNotificationViewModel: ObservableObject {

    init() { print("<<<<<<<<<  TeamNotificationViewModel_init  >>>>>>>>>") }

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var listener: ListenerRegistration?
    var uid: String? { Auth.auth().currentUser?.uid }

    /// 通知の表示開始を管理するプロパティ。
    /// このプロパティがトグルされると、TeamNotificationViewが初期化され、
    /// ビュー側で通知データの取得が始まる。
    @Published var show: Bool = false
    /// 現在表示されている通知を保持するプロパティ。
    /// ユーザーが保持している通知の数が無くなるまで、ビュー側で更新が続く。
    @Published var currentNotification: TeamNotifyFrame?
    @Published var myNotifications: [TeamNotifyFrame] = []

    /// メンバーデータのステートを監視するリスナーメソッド。
    /// 初期実行時にリスニング対象ドキュメントのデータが全取得される。(フラグはadded)
    func listener(id currentTeamID: String?) {
        print("notificationListener実行")
        guard let uid, let currentTeamID else { return }
        guard let teamRef = db?.collection("teams")
            .document(currentTeamID) else { return }

        listener = teamRef.addSnapshotListener { snap, error in
            if let error {
                print("ERROR: \(error.localizedDescription)")
            } else {
                guard let snap else { print("ERROR: snap nil"); return }

                do {
                    let teamData = try snap.data(as: Team.self)
                    guard let myData = teamData.members
                        .first(where: { $0.memberUID == uid }) else {
                        return
                    }
                    self.myNotifications = myData.notifications.compactMap({ $0 })
                } catch {
                    print("ERROR: try snap?.data(as: Team.self)")
                }
            }
        }
    }

    /// アイテムや新規通知をチーム内の各メンバーに渡すメソッド。
    func setNotificationToFirestore(team: Team?, type: TeamNotificationType) {
        guard var team else { return }
        guard let teamRef = db?.collection("teams").document(team.id) else { return }
        let notification = TeamNotifyFrame(type: type,
                                    message: type.message,
                                    imageURL: type.imageURL,
                                    exitTime: type.waitTime)
        for index in team.members.indices {
            team.members[index].notifications.append(notification)
        }

        do {
            _ = try teamRef.setData(from: team)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            }
        } catch {
            print("Error: setNotificationToFirestore")
        }
    }
    /// 自身のみの通知データを消去するメソッド。他メンバーの通知データはそれぞれがログインした時に表示される。
    func removeMyNotificationToFirestore(team: Team?, data: TeamNotifyFrame) {
        guard var team else { return }
        guard let teamRef = db?.collection("teams").document(team.id) else { return }

        guard let index = team.members.firstIndex(where: { $0.memberUID == uid }) else { return }
        team.members[index].notifications.removeAll(where: { $0.id == data.id })
        print(team.members[index].notifications)

        do {
            _ = try teamRef.setData(from: team)
        } catch {
            print("Error: setNotificationToFirestore")
        }
    }
    /// 全メンバーの対象通知データを消去。他のメンバーがログインするまで残しておく必要がない通知データに使う。
    func removeAllMemberNotificationToFirestore(team: Team?, data: TeamNotifyFrame) {
        guard var team else { return }
        guard let teamRef = db?.collection("teams").document(team.id) else { return }

        for index in team.members.indices {
            team.members[index].notifications.removeAll(where: { $0.id == data.id })
            print(team.members[index].notifications)
        }

        do {
            _ = try teamRef.setData(from: team)
            print("全メンバーの対象通知データを消去")
        } catch {
            print("Error: setNotificationToFirestore")
        }
    }
    deinit {
        listener?.remove()
    }
}
