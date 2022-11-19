//
//  GroupModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/19.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Team: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var iconURL: URL?
    var iconPath: String?
    var members: [JoinMember]
}

struct JoinMember: Codable {
    var memberID: String
    var name: String
    var iconURL: URL?
}
