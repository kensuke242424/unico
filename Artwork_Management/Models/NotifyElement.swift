//
//  BoardFrame.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI

/// 通知ボード一要素分となる構造体。
struct NotifyElement: Identifiable, Equatable, Hashable, Codable {
    var id: UUID = .init()
    var notifyType: TeamNotificationType
    var message: String
    var imageURL: URL?
    var exitTime: CGFloat
}

/// 通知のセットタイプを管理する列挙体。
/// ・local -> 自身にのみ通知
/// ・grobal -> チーム内のメンバー全員に通知
enum SetType: Codable {
    case local, global
}

/// 通知の削除タイプを管理する列挙体。
/// ・local -> 自身の通知データのみ削除
/// ・grobal -> チーム内のメンバー全員の通知データを削除
enum RemoveType: Codable {
    case local, global
}

extension NotifyElement {
    static func == (lhs: NotifyElement, rhs: NotifyElement) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
            return hasher.combine(id)
    }
}
