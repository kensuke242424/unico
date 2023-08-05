//
//  CompareItem.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/05.
//

import Foundation

/// アイテムデータの更新前と更新後の比較値を使いたい時に用いるモデル。
/// Firestoreへのコーダブル保存を可能にするため、Codableに準拠。
struct CompareItem: Codable, Equatable {
    let before: Item
    let after: Item
}
