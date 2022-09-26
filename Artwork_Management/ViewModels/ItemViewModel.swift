//
//  ItemViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import Foundation

class ItemViewModel: ObservableObject {

    @Published var ItemsList: [Item] = [

        Item(tag: "Album", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: ""),
        Item(tag: "Album", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: ""),
        Item(tag: "Album", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: ""),
        Item(tag: "Album", name: "Album4", detail: "Album4のアイテム紹介テキストです。", photo: ""),
        Item(tag: "Album", name: "Album5", detail: "Album5のアイテム紹介テキストです。", photo: "")

    ]

}
