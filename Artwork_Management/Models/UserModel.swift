//
//  UserModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var address: String
    var password: String
    var iconURL: URL?
    var groups: [JoinGroup]
}

struct JoinGroup: Codable {
    var groupID: String
    var name: String
    var iconURL: URL?
    var headerURL: URL?
    var color: String
}
