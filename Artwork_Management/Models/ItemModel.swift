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

    let id = UUID()
    let tag: String
    let tagColor: String
    let name: String
    let detail: String
    let photo: String
    let price: Int
    let sales: Int
    let inventory: Int
    let createTime: Date
    let updateTime: Date
}

// iPhone本体で扱われる
struct Tag: Identifiable {
    var id = UUID()
    var tagName: String
    var tagColor: Color
}
