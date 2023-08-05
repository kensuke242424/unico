//
//  CompareItem.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/05.
//

import Foundation

/// カート処理時の通知作成において用いられるモデル。
/// 処理前と処理後のアイテムデータ比較を目的とする。
struct CompareItem: Codable {
    let before: Item
    let after: Item
}
