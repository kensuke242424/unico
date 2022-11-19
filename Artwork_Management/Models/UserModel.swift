//
//  UserModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import Foundation

struct User: Identifiable, Codable {
    var id = UUID().uuidString
    var name: String
    var address: String
    var password: String
    var iconURL: URL?
    var joins: [JoinGroup]
}

struct JoinGroup: Codable {
    var id: String
    var name: String
    var iconURL: URL?
    var headerURL: URL?
    var color: String
}
