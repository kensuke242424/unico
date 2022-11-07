//
//  UserModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import Foundation

struct User: Identifiable {
    var id = UUID().uuidString
    var name: String
    var address: String
    var password: String
    var photoImage: String
    var headerImage: String
}
