//
//  ItemModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Item: Identifiable, Equatable, Hashable, Codable {

    @DocumentID var id: String? = UUID().uuidString
    @ServerTimestamp var createTime: Timestamp?
    @ServerTimestamp var updateTime: Timestamp?
    var tag: String
    var teamID: String
    var name: String
    var author: String
    var detail: String
    var photoURL: URL?
    var photoPath: String?
    var favorite: Bool
    var cost: Int
    var price: Int
    var amount: Int
    var sales: Int
    var inventory: Int
    var totalAmount: Int
    var totalInventory: Int
}

//Text(item.tag != "" ?
//          "タグ　　　:　　 \(item.tag)" :
//          "タグ　　　:　　 未グループ")
//    .padding(.bottom, 12)
//
//Text("在庫　　　:　　 \(item.inventory) 個")
//
//Text(item.price != 0 ?
//     "価格　　　:　　 ¥ \(item.price)" :
//     "価格　　　:　　   -")
//    .padding(.bottom, 12)
//
//Text(item.sales != 0 ?
//     "総売上　　:　　 ¥ \(item.sales)" :
//     "総売上　　:　　   -")
//
//Text(item.totalAmount != 0 ?
//     "総売個数　:　　 \(item.totalAmount) 個" :
//     "総売個数　:　　   -")
//
//Text(item.totalInventory != 0 ?
//     "総在庫数　:　　 \(item.totalInventory) 個":
//     "総仕入れ　:　　   -")
//    .padding(.bottom, 12)
//
//Text("登録日　　:　　 \(asTimesString(item.createTime))")
//Text("最終更新　:　　 \(asTimesString(item.updateTime))")

extension Item {
    func description() -> String {
        
        var descriptions: String {
"""
名前　　: \(self.name)
タグ　　: \(self.tag)
在庫　　: \(self.inventory)
価格　　: \(self.price)
総売個数: \(self.totalAmount)
総仕入れ: \(self.totalInventory)

登録日　: \(String(describing: self.createTime))
更新日　: \(String(describing: self.updateTime))

"""
        }
        return descriptions
    }
}

struct ItemImageData: Codable {
    var image: Data
}

enum Mode {
    case dark
    case light
}

var testItem: [Item] =
[
    Item(tag: "Clothes",
             teamID: "",
             name: "cloth_sample2",
             author: "Anonymous User",
             detail: "文がいくつか集まり、かつ、まとまった内容を表すもの。内容のうえで前の文と密接な関係をもつと考えられる文は、そのまま続いて書き継がれ、前の文と隔たりが意識されたとき、次の文は行を改めて書かれる。すなわち、段落がつけられるということであり、これは、書き手がまとまった内容を段落ごとにまとめようとするからである。この、一つの段落にまとめられる、いくつかの文の集まりを一文章というが、よりあいまいに、いくつかの文をまとめて取り上げるときにそれを文章と称したり、文と同意義としたりすることもあるなど文章はことばの単位として厳密なものでないことが多い。。",
             photoURL: nil,
             photoPath: nil,
             favorite: false,
             cost: 1000,
             price: 2800,
             amount: 0,
             sales: 128000,
             inventory: 2,
             totalAmount: 120,
             totalInventory: 200),
]
