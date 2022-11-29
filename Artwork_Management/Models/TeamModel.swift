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
    var id: String
    var name: String
    var iconURL: URL?
    var iconPath: String?
    var headerURL: URL?
    var headerPath: String?
    var members: [JoinMember]
}

// Team構造体が保持するメンバー一人分の情報
// Homeのヘッダー、セットカラーはユーザ個々に設定可能
struct JoinMember: Codable {
    var memberUID: String
    var name: String
    var iconURL: URL?
}
