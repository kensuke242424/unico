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

enum UpDownOrder: CaseIterable {
    case up, down

    var text: String {
        switch self {
        case .up: return "昇順"
        case .down: return "降り順"
        }
    }

    var icon: Image {
        switch self {
        case .up: return Image(systemName: "arrow.up.square.fill")
        case .down: return Image(systemName: "arrow.down.app.fill")
        }
    }
}

enum ItemsSortType: CaseIterable {
    case name, updateTime, createTime, sales

    var text: String {
        switch self {
        case .name: return "名前"
        case .createTime: return "追加日"
        case .updateTime: return "更新日"
        case .sales: return "売り上げ"
        }
    }
}

var sampleItems: [Item] =
[
    Item(tag: "goods",
             teamID: "",
             name: "サンプル１",
             author: "ユニコ太郎",
             detail: "ここにアイテムの詳細メモが入ります。",
             photoURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/unico-cc222.appspot.com/o/sample%2Fgoods_sample6.jpg?alt=media&token=0f1ff906-46de-47d4-97f9-18011439e13c&_gl=1*1dexvqy*_ga*Njc5ODMwMzQzLjE2NzY5Nzg1MDE.*_ga_CW55HF8NVT*MTY4NjM4NTk5Ny42Mi4xLjE2ODYzODYxNDQuMC4wLjA."),
             photoPath: nil,
             favorite: false,
             cost: 1000,
             price: 2800,
             amount: 0,
             sales: 28000,
             inventory: 50,
             totalAmount: 0,
             totalInventory: 0),

    Item(tag: "goods",
             teamID: "",
             name: "サンプル２",
             author: "ユニコ太郎",
             detail: "ここにアイテムの詳細メモが入ります。",
         photoURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/unico-cc222.appspot.com/o/sample%2Fgoods_sample5.jpg?alt=media&token=1a44c529-0530-472f-a685-2f5d30c9486c&_gl=1*wbr9no*_ga*Njc5ODMwMzQzLjE2NzY5Nzg1MDE.*_ga_CW55HF8NVT*MTY4NjM4NTk5Ny42Mi4xLjE2ODYzODYxMjguMC4wLjA."),
             photoPath: nil,
             favorite: false,
             cost: 1000,
             price: 2000,
             amount: 0,
             sales: 40000,
             inventory: 180,
             totalAmount: 20,
             totalInventory: 200),

    Item(tag: "goods",
             teamID: "",
             name: "サンプル３",
             author: "ユニコ太郎",
             detail: "ここにアイテムの詳細メモが入ります。",
         photoURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/unico-cc222.appspot.com/o/sample%2Fcloth_sample2.jpg?alt=media&token=33f82ceb-f40d-4719-b453-f4d4f131b936&_gl=1*907n73*_ga*Njc5ODMwMzQzLjE2NzY5Nzg1MDE.*_ga_CW55HF8NVT*MTY4NjM4NTk5Ny42Mi4xLjE2ODYzODYwNTkuMC4wLjA."),
             photoPath: nil,
             favorite: false,
             cost: 2000,
             price: 3500,
             amount: 0,
             sales: 35000,
             inventory: 90,
             totalAmount: 10,
             totalInventory: 100),
]
