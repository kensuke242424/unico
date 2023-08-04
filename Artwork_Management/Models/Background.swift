//
//  Background.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/09.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Firebaseに保存するサンプル背景画像
struct Background: Codable, Hashable {
    @DocumentID var id: String? = UUID().uuidString
    var createTime: Date = Date()
    var category: String
    var imageName: String
    var imageURL: URL?
    var imagePath: String?
}

/// 背景選択時のカテゴリタグに使用
struct CategoryTag: Identifiable, Equatable {
    var id = UUID()
    var name: String
}

/// 初期値として用いる背景データのサンプル。
let sampleBackground = Background(
    category: "music",
    imageName: "music_1",
    imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/unico-cc222.appspot.com/o/SampleBackgrounds%2Fmusic%2Fmusic_1_2023-07-30%2012%3A31%3A33%20%2B0000.jpeg?alt=media&token=a7c7ea84-2a68-4459-acf9-06fa583b6639"),
    imagePath: "gs://unico-cc222.appspot.com/SampleBackgrounds/music/music_1_2023-07-30 12:31:33 +0000.jpeg"
)
