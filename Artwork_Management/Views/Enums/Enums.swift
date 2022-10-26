//
//  Enums.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/11.
//
import SwiftUI

// Stock画面のアイテムカードの大きさを変更？
enum StockCardSize {
    case mini
    case medium
}

// NOTE: アイテムのソートタイプを管理します
enum SortType {
    case salesUp
    case salesDown
    case updateAtUp
    case createAtUp
    case start
}

// NOTE: アイテムのタググループ有無を管理します
enum TagGroup {
    case on // swiftlint:disable:this identifier_name
    case off
}

// NOTE: アイテムの「追加」「更新」を管理します
enum Status {
    case create
    case update
}

enum SearchFocus {
    case check
}

enum Field {
    case tag
    case name
    case stock
    case price
    case sales
    case detail
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
