//
//  CompareTeam.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/19.
//

import Foundation

/// チームデータの更新前と更新後の比較値を使いたい時に用いるモデル。
/// Firestoreへのコーダブル保存を可能にするため、Codableに準拠。
struct CompareTeam: Codable, Equatable {
    let id: String
    var createTime = Date()
    let before: Team
    let after: Team
}
