//
//  ItemModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import Foundation
import SwiftUI

// Firestore内で管理されるItemオブジェクト
struct Item: Identifiable {

    var id = UUID()
    var tag: String
    var tagColor: String
    let name: String
    let detail: String
    let photo: String
    let price: Int
    let sales: Int
    let inventory: Int
    let createTime: Date
    let updateTime: Date
}

// iPhone側で扱われるオブジェクト
struct Tag: Identifiable, Equatable {
    var id = UUID()
    var tagName: String
    var tagColor: UsedColor
}
