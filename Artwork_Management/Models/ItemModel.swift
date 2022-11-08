//
//  ItemModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import SwiftUI

struct Item: Identifiable, Equatable, Hashable {

    var id = UUID().uuidString
    var tag: String
    var name: String
    var detail: String
    var photo: String
    var cost: Int
    var price: Int
    var amount: Int
    var sales: Int
    var inventory: Int
    var totalAmount: Int
    var totalInventory: Int
    let createTime: Date
    var updateTime: Date
}

enum Status {
    case create
    case update
}

enum Mode {
    case dark
    case light
}
