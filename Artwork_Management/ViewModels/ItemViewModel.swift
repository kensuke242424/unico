//
//  ItemViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import Foundation

class ItemViewModel: ObservableObject {

    // NOTE: アイテム、タグのテストデータです
     @Published var items: [Item] =
    [
        Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "", price: 1800, sales: 88000, inventory: 200, createAt: Date(), updateAt: Date()),
        Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
             price: 2800, sales: 230000, inventory: 420, createAt: Date(), updateAt: Date()),
        Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "",
             price: 3200, sales: 360000, inventory: 402, createAt: Date(), updateAt: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single1", detail: "Single1のアイテム紹介テキストです。", photo: "",
             price: 1100, sales: 182000, inventory: 199, createAt: Date(), updateAt: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single2", detail: "Single2のアイテム紹介テキストです。", photo: "",
             price: 1310, sales: 105000, inventory: 43, createAt: Date(), updateAt: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single3", detail: "Single3のアイテム紹介テキストです。", photo: "",
             price: 1470, sales: 185000, inventory: 97, createAt: Date(), updateAt: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ1", detail: "グッズ1のアイテム紹介テキストです。", photo: "",
             price: 2300, sales: 329000, inventory: 88, createAt: Date(), updateAt: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ2", detail: "グッズ2のアイテム紹介テキストです。", photo: "",
             price: 3300, sales: 199200, inventory: 105, createAt: Date(), updateAt: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ3", detail: "グッズ3のアイテム紹介テキストです。", photo: "",
             price: 4000, sales: 520000, inventory: 97, createAt: Date(), updateAt: Date())
    ]

    @Published var tags = ["Album", "Single", "Goods"]
}
