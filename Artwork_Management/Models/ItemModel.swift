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
    var name: String
    var author: String
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

var testItem: [Item] =
[
    Item(tag: "Clothes",
         name: "cloth_sample2",
         author: "Anonymous User",
         detail: "文がいくつか集まり、かつ、まとまった内容を表すもの。内容のうえで前の文と密接な関係をもつと考えられる文は、そのまま続いて書き継がれ、前の文と隔たりが意識されたとき、次の文は行を改めて書かれる。すなわち、段落がつけられるということであり、これは、書き手がまとまった内容を段落ごとにまとめようとするからである。この、一つの段落にまとめられる、いくつかの文の集まりを一文章というが、よりあいまいに、いくつかの文をまとめて取り上げるときにそれを文章と称したり、文と同意義としたりすることもあるなど文章はことばの単位として厳密なものでないことが多い。。",
         photoURL: nil,
         photoPath: nil,
         cost: 1000,
         price: 2800,
         amount: 0,
         sales: 128000,
         inventory: 2,
         totalAmount: 120,
         totalInventory: 200),
    
    Item(tag: "Clothes",
         name: "cloth_sample3",
         author: "Anonymous User",
         detail: "文がいくつか集まり、かつ、まとまった内容を表すもの。内容のうえで前の文と密接な関係をもつと考えられる文は、そのまま続いて書き継がれ、前の文と隔たりが意識されたとき、次の文は行を改めて書かれる。すなわち、段落がつけられるということであり、これは、書き手がまとまった内容を段落ごとにまとめようとするからである。この、一つの段落にまとめられる、いくつかの文の集まりを一文章というが、よりあいまいに、いくつかの文をまとめて取り上げるときにそれを文章と称したり、文と同意義としたりすることもあるなど文章はことばの単位として厳密なものでないことが多い。",
         photoURL: nil,
         photoPath: nil,
         cost: 700,
         price: 2800,
         amount: 0,
         sales: 128000,
         inventory: 2,
         totalAmount: 120,
         totalInventory: 200),
    
]
