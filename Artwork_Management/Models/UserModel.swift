//
//  UserModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var address: String
    var password: String
    var iconURL: URL?
    var iconPath: String?
    var joins: [JoinTeam]
}

struct JoinTeam: Codable {
    var teamID: String
    var name: String
    var headerURL: URL?
    var headerPath: String?
    var settingColor: MemberColor
}

// Todo: ユーザそれぞれが個々に選ぶアプリ全体のカラー
enum MemberColor: CaseIterable, Codable {
    case red
    case blue
    case yellow
    case orange
    case pink
    case gray
}
