//
//  SDWebImageBackground.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/07/11.
//

import SwiftUI
import SDWebImageSwiftUI

struct SDWebImageBackgroundView: View {

    let imageURL: URL?
    let width   : CGFloat
    let height  : CGFloat

    /// 2023/7/11現在、SDWebImage使用下での背景編集において、選択された背景の画像URLを受け取ることでプレビュー背景を更新する時に
    /// フェードアニメーションが反映されず、ぶつ切りで切り替わる状態（animation, transitionも試したが効果なし）。
    /// 一時的な対策として、親ビューから受け取ったURLを、if文によるスイッチングで二つのURLプロパティに振り分け、
    /// 擬似的にフェードを表現している。
    @State private var showImageSwitching: Bool = true
    @State private var imageURL1: URL?
    @State private var imageURL2: URL?

    var body: some View {

        if let imageURL = imageURL {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white).opacity(0.01)
                    .frame(width: width, height: height)

                if showImageSwitching, let imageURL1 {
                    SDWebImageBackground(url: imageURL1)

                } else if !showImageSwitching, let imageURL2 {
                    SDWebImageBackground(url: imageURL2)
                }
            }
            .onChange(of: imageURL) { newImageURL in
                if showImageSwitching {
                    withAnimation {
                        imageURL2 = newImageURL
                        showImageSwitching = false
                    }
                } else {
                    withAnimation {
                        imageURL1 = newImageURL
                        showImageSwitching = true
                    }
                }
            }
            .onAppear { imageURL1 = imageURL }

        } else {
            Text("No Image.")
                .font(.subheadline)
                .fontWeight(.bold)
                .opacity(0.7)
        }
    }

    @ViewBuilder
    private func SDWebImageBackground(url: URL) -> some View {
        WebImage(url: url)
            .resizable()
            .placeholder {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.black.opacity(0.4))
                        .frame(width: width, height: height)
                    ProgressView()
                }
            }
            .scaledToFill()
            .frame(width: width, height: height)
            .shadow(radius: 1, x: 2, y: 2)
            .shadow(radius: 1, x: 2, y: 2)
            .allowsHitTesting(false)
    }
}
