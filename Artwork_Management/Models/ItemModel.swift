//
//  ItemModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Item: Identifiable, Equatable, Hashable, Codable {

    @DocumentID var id: String? = UUID().uuidString
    @ServerTimestamp var createTime: Timestamp?
    @ServerTimestamp var updateTime: Timestamp?
    var tag: String
    var tagColor: UsedColor
    var name: String
    var detail: String
    var photoURL: URL?
    var photoPath: String?
    var cost: Int
    var price: Int
    var amount: Int
    var sales: Int
    var inventory: Int
    var totalAmount: Int
    var totalInventory: Int
}

enum Mode {
    case dark
    case light
}

struct TestItem {

    var testItem: Item = Item(tag: "Clothes",
                              tagColor: .red,
                              name: "カッターシャツ(白)",
                              detail: "シャツ(白)のアイテム紹介テキストです。",
                              photoURL: nil,
                              photoPath: nil,
                              cost: 1000,
                              price: 2800,
                              amount: 0,
                              sales: 128000,
                              inventory: 2,
                              totalAmount: 120,
                              totalInventory: 200)
}
