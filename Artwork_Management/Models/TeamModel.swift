//
//  GroupModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/19.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

// チーム情報
struct Team: FirestoreSerializable, Identifiable, Codable, Equatable {
    static func firestorePath() -> FirestorePath {
        return .teams
    }

    var createTime = Date()
    var id: String
    var name: String
    var iconURL: URL?
    var iconPath: String?
    var backgroundURL: URL?
    var backgroundPath: String?
    var logs: [Log] = []
}

/// teamsドキュメントのサブコレクションとして保存されるメンバー一人分の要素を持つデータ
struct JoinMember: Hashable, Codable {
    var id: String
    var name: String
    var iconURL: URL?
    var notifications: [Log] = []
}
