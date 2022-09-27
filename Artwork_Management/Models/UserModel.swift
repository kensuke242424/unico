//
//  UserModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import Foundation

struct User: Identifiable {

    var id = UUID()
    let name: String
    let address: String
    let password: String
}
