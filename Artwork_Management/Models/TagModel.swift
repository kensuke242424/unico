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
