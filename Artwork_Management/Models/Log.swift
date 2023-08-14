//
//  BoardFrame.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI

/// チームおよびユーザーが行った編集履歴のエレメントを管理する。
struct Log: Identifiable, Equatable, Hashable, Codable {
    var id: String
    var teamId: String
    var createTime: Date
    var editByIcon: URL?
    var type: LogType
    var read: Bool = false
    var canceledDatas: [Date] = []
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

extension Log {
    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
            return hasher.combine(id)
    }
}
