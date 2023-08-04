//
//  TeamNotificationViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/04.
//

import Foundation
import Firebase
import FirebaseFirestore

class TeamNotificationViewModel: ObservableObject {

    init() { print("<<<<<<<<<  TeamNotificationViewModel_init  >>>>>>>>>") }

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? { Auth.auth().currentUser?.uid }

    /// 通知の表示開始を管理するプロパティ。
    /// このプロパティがトグルされると、TeamNotificationViewが初期化され、
    /// ビュー側で通知データの取得が始まる。
    @Published var show: Bool = false
    /// 現在表示されている通知を保持するプロパティ。
    /// ユーザーが保持している通知の数が無くなるまで、ビュー側で更新が続く。
    @Published var currentNotification: TeamNotifyFrame?

    /// アイテムや新規通知をチーム内の各メンバーに渡すメソッド。
    func setNotificationToFirestore(team: Team?, type: NotificationType) {
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
}
