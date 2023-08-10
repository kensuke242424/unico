//
//  WebImageTypesIcon.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/11.
//

import SwiftUI
import SDWebImageSwiftUI

enum IconShowType {
    case item, user, team

    var symbol: String {
        switch self {
        case .item:
            return "shippingbox.fill"
        case .user:
            return "person.fill"
        case .team:
            return "cube.transparent.fill"
        }
    }
}
/// SDWebImageを用いた画像アイコンビュー。
/// 引数でアイコンの使用タイプを選択して渡す。
struct WebImageTypesIcon: View {

    let imageURL: URL?
    let size: CGFloat
    let type: IconShowType
    let shape: AnyShape

    var body: some View {
        if let imageURL = imageURL {

            ZStack {
                Color.white.opacity(0.01)
                    .frame(width: size, height: size)
                WebImage(url: imageURL)
                    .resizable()
                    .placeholder {
                        ZStack {
                            Color.black.opacity(0.4)
                                .frame(width: size, height: size)
                            ProgressView()
                        }
                    }
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(shape)
                    .allowsHitTesting(false)
            }

        } else {
            Color.userGray2
            .frame(width: size, height: size)
            .overlay {
                VStack(spacing: 20) {
                    Image(systemName: type.symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.45)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
}

struct WebImageTypesIcon_Previews: PreviewProvider {
    static var previews: some View {
        WebImageTypesIcon(imageURL: nil,
                          size: 180,
                          type: .item,
                          shape: AnyShape(Circle()))
        .clipShape(Circle()) // ビューの外でシェイプを指定
    }
}
