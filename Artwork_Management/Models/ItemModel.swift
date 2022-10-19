//
//  ItemModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import Foundation
import SwiftUI

// Firestore内で管理されるItemオブジェクト
struct Item: Identifiable, Equatable, Hashable {

    var id = UUID()
    var tag: String
    var tagColor: String
    var name: String
    var detail: String
    var photo: String
    var price: Int
    var sales: Int
    var inventory: Int
    let createTime: Date
    var updateTime: Date
}

// iPhone側で扱われるオブジェクト
struct Tag: Identifiable, Equatable {
    var id = UUID()
    var tagName: String
    var tagColor: UsedColor
}
