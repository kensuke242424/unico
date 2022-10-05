//
//  ItemViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import Foundation
import SwiftUI

class ItemViewModel: ObservableObject {

    // NOTE: アイテム、タグのテストデータです
     @Published var items: [Item] =
    [
        Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "", price: 1800, sales: 88000, inventory: 200, createTime: Date(), updateTime: Date()),
        Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
             price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date()),
        Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "",
             price: 3200, sales: 367000, inventory: 402, createTime: Date(), updateTime: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single1", detail: "Single1のアイテム紹介テキストです。", photo: "",
             price: 1100, sales: 182000, inventory: 199, createTime: Date(), updateTime: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single2", detail: "Single2のアイテム紹介テキストです。", photo: "",
             price: 1310, sales: 105000, inventory: 43, createTime: Date(), updateTime: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single3", detail: "Single3のアイテム紹介テキストです。", photo: "",
             price: 1470, sales: 185000, inventory: 97, createTime: Date(), updateTime: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ1", detail: "グッズ1のアイテム紹介テキストです。", photo: "",
             price: 2300, sales: 329000, inventory: 88, createTime: Date(), updateTime: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ2", detail: "グッズ2のアイテム紹介テキストです。", photo: "",
             price: 3300, sales: 199000, inventory: 105, createTime: Date(), updateTime: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ3", detail: "グッズ3のアイテム紹介テキストです。", photo: "",
             price: 4000, sales: 520000, inventory: 97, createTime: Date(), updateTime: Date())
    ]

    @Published var tags = ["Album", "Single", "Goods"]

    func castStringIntoColor(color: String) -> Color {
        switch color {
        case "赤":
            return .red
        case "青":
            return .blue
        case "黄":
            return .yellow
        case "緑":
            return .green
        default:
            return .gray
        }
    } // func castStringIntoColor

    func castColorIntoString(color: Color) -> String {

        switch color {
        case Color(.red):
            return "赤"
        case Color(.blue):
            return "青"
        case Color(.yellow):
            return "黄"
        case Color(.green):
            return "緑"
       default:
            return "灰"
        }
    } // func castColorIntoString

} // class
