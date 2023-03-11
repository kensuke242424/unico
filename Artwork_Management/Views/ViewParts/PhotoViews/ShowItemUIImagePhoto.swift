//
//  ShowItemPhoto.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/28.
//

import SwiftUI

struct ShowItemUIImagePhoto: View {

    let photoImage: UIImage?
    let size: CGFloat

    var body: some View {
        if let photoImage = photoImage {
            // NOTE: 画像をclipShapeしても、切り取られた画像部分のタップ判定は残るみたい
            //       画像本体のタップ判定は無効化して、ZStackで上から同じフレームのViewを重ね、そちら側にジェスチャー判定を任せている
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.white).opacity(0.1)
                    .frame(width: size, height: size)
                Image(uiImage: photoImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .allowsHitTesting(false)
                    .shadow(radius: 4, x: 4, y: 4)
            }

        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.gray)
                .frame(width: size, height: size)
                .shadow(radius: 4, x: 5, y: 5)
                .overlay {
                    Text("No Image.")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(0.5)
                }
        }
    }
}
