//
//  BoardFrame.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI

/// 通知ボード一要素分となる構造体。このデータがFireStoreに保存されることで、
/// チームメンバーにも通知が届く。
struct NotifyFrame: Identifiable, Equatable, Hashable, Codable {
    var id: UUID = .init()
    var type: NotificationType
    var message: String
    var imageURL: URL?
    var exitTime: CGFloat
}

struct NotifyItem {
    
}

extension NotifyFrame {
    static func == (lhs: NotifyFrame, rhs: NotifyFrame) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
            return hasher.combine(id)
    }
}
