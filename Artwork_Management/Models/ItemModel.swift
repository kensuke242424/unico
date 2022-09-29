//
//  ItemModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import Foundation

struct Item: Identifiable {

    let id = UUID()
    let tag: String
    let name: String
    let detail: String
    let photo: String
    let price: Int
    let sales: Int
    let inventory: Int
    let createAt: Date
    let updateAt: Date
}
