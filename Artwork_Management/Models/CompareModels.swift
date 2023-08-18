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
    let id: String
    var createTime = Date()
    let before: Item
    let after: Item
//    var cancel: Bool? // 取り消しが実行されるとtrue
}

/// ユーザーデータの更新前と更新後の比較値を使いたい時に用いるモデル。
/// Firestoreへのコーダブル保存を可能にするため、Codableに準拠。
struct CompareUser: Codable, Equatable {
    let id: String
    var createTime = Date()
    let before: User
    let after: User
//    var cancel: Bool? // 取り消しが実行されるとtrue
}

/// チームデータの更新前と更新後の比較値を使いたい時に用いるモデル。
/// Firestoreへのコーダブル保存を可能にするため、Codableに準拠。
struct CompareTeam: Codable, Equatable {
    let id: String
    var createTime = Date()
    let before: Team
    let after: Team
//    var cancel: Bool? // 取り消しが実行されるとtrue
}
