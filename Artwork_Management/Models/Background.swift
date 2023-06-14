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
