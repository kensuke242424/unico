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

// NOTE: アイテムの「追加」「更新」を管理します
enum Status {
    case create
    case update
}

enum Mode {
    case dark
    case light
}

// NOTE: アイテムのカラーを管理し、StringまたはColorを返します
enum UsedColor: CaseIterable {

    case red
    case blue
    case yellow
    case green
    case gray

    var text: String {
        switch self {
        case .red:
            return "赤"
        case .blue:
            return "青"
        case .yellow:
            return "黄"
        case .green:
            return "緑"
        default:
            return "灰"
        }
    }
    var color: Color {
        switch self {
        case .red:
            return .red
        case .blue:
            return .blue
        case .yellow:
            return .yellow
        case .green:
            return .green
        default:
            return .gray
        }
    }
}
