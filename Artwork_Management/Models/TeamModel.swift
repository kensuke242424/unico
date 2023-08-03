//
//  GroupModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/19.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

// チーム情報
struct Team: Identifiable, Codable {
    @ServerTimestamp var createTime: Timestamp?
    var id: String
    var name: String
    var iconURL: URL?
    var iconPath: String?
    var backgroundURL: URL?
    var backgroundPath: String?
    var members: [JoinMember]
}

// Team構造体が保持するメンバー一人分の情報
// Homeのヘッダー、セットカラーはユーザ個々に設定可能
struct JoinMember: Hashable, Codable {
    var memberUID: String
    var name: String
    var iconURL: URL?
    var notifications: [BoardFrame] = []
}

var testTeam: Team = Team(id: UUID().uuidString,
                          name: "テストチーム",
                          members: [JoinMember(memberUID: UUID().uuidString, name: "ken")]
)
