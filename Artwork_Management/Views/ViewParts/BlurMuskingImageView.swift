//
//  BlurMuskingImageView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/08.
//

import SwiftUI
import SDWebImageSwiftUI

/// 背景画像にブラーをマスキングするために用いるビュー
struct BlurMaskingImageView: View {

    var imageURL: URL?

    var body: some View {

        if let imageURL {
            WebImage(url: imageURL)
                .resizable()
                .scaledToFill()
//                .opacity(0.9)
                .blur(radius: 5, opaque: true)
        }
    }
}
