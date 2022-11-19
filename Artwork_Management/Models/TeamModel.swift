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
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var iconURL: URL?
    var iconPath: String?
    var members: [JoinMember]
}

// Team構造体が保持するメンバー一人分の情報
// Homeのヘッダー、セットカラーはユーザ個々に設定可能
struct JoinMember: Codable {
    var memberUID: String
    var name: String
    var iconURL: URL?
    var iconPath: String?
    var headerURL: URL?
    var headerPath: String?
    var settingColor: MemberColor
}

// ユーザそれぞれが個々に選ぶアプリ全体のカラー
enum MemberColor: CaseIterable, Codable {
    case red
    case blue
    case yellow
    case orange
    case pink
    case gray
}
