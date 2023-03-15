//
//  Book.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

/// Bool Model

struct Book: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var title: String
    var imageName: String
    var author: String
    var rating: Int
    var bookViews: Int
}

var sampleBooks: [Book] =
[
    .init(title: "Departure", imageName: "cloth_sample1", author: "Rock climb", rating: 4, bookViews: 1055),
    .init(title: "BBB", imageName: "cloth_sample2", author: "human2", rating: 5, bookViews: 2038),
    .init(title: "CCC", imageName: "cloth_sample3", author: "human3", rating: 3, bookViews: 3455),
    .init(title: "DDD", imageName: "cloth_sample4", author: "human4", rating: 2, bookViews: 5100)
]

