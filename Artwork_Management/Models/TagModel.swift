//
//  TagModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Tag: Identifiable, Equatable, Codable {
    @DocumentID var id = UUID().uuidString
    var oderIndex: Int
    var tagName: String
    var tagColor: UsedColor
}

var testTag: [Tag] {
    [
        Tag(oderIndex: 0, tagName: "サンプルタグ1", tagColor: .gray),
        Tag(oderIndex: 1, tagName: "サンプルタグ2", tagColor: .gray),
        Tag(oderIndex: 2, tagName: "サンプルタグ3", tagColor: .gray),
    ]
}

enum UsedColor: CaseIterable, Codable {

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
