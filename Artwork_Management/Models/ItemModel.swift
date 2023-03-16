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

var testItem: [Item] =
[
    Item(tag: "Clothes",
         tagColor: .red,
         name: "cloth_sample2",
         detail: "文がいくつか集まり、かつ、まとまった内容を表すもの。内容のうえで前の文と密接な関係をもつと考えられる文は、そのまま続いて書き継がれ、前の文と隔たりが意識されたとき、次の文は行を改めて書かれる。すなわち、段落がつけられるということであり、これは、書き手がまとまった内容を段落ごとにまとめようとするからである。この、一つの段落にまとめられる、いくつかの文の集まりを一文章というが、よりあいまいに、いくつかの文をまとめて取り上げるときにそれを文章と称したり、文と同意義としたりすることもあるなど文章はことばの単位として厳密なものでないことが多い。これに対して、時枝誠記(ときえだもとき)は、文章を語・文と並ぶ文法上の単位として考えるべきことを主張し、表現者が一つの統一体ととらえた、完結した言語表現を文章と定義した。これによれば、一編の小説は一つの文章であり、のちに続編が書き継がれた場合には、この続編をもあわせたものが一つの文章ということになる。俳句、和歌の一句・一首は、いずれも一つの文章であり、これをまとめた句集・歌集は、編纂(へんさん)者の完結した思想があることにおいて、それぞれ一つの文章ということになる。",
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
         tagColor: .red,
         name: "cloth_sample3",
         detail: "文がいくつか集まり、かつ、まとまった内容を表すもの。内容のうえで前の文と密接な関係をもつと考えられる文は、そのまま続いて書き継がれ、前の文と隔たりが意識されたとき、次の文は行を改めて書かれる。すなわち、段落がつけられるということであり、これは、書き手がまとまった内容を段落ごとにまとめようとするからである。この、一つの段落にまとめられる、いくつかの文の集まりを一文章というが、よりあいまいに、いくつかの文をまとめて取り上げるときにそれを文章と称したり、文と同意義としたりすることもあるなど文章はことばの単位として厳密なものでないことが多い。これに対して、時枝誠記(ときえだもとき)は、文章を語・文と並ぶ文法上の単位として考えるべきことを主張し、表現者が一つの統一体ととらえた、完結した言語表現を文章と定義した。これによれば、一編の小説は一つの文章であり、のちに続編が書き継がれた場合には、この続編をもあわせたものが一つの文章ということになる。俳句、和歌の一句・一首は、いずれも一つの文章であり、これをまとめた句集・歌集は、編纂(へんさん)者の完結した思想があることにおいて、それぞれ一つの文章ということになる。",
         photoURL: nil,
         photoPath: nil,
         cost: 1000,
         price: 2800,
         amount: 0,
         sales: 128000,
         inventory: 2,
         totalAmount: 120,
         totalInventory: 200),
    
]
