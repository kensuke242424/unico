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
    var teams: [JoinTeam]
}

struct JoinTeam: Codable {
    var groupID: String
    var name: String
    var headerURL: URL?
    var color: String
}
