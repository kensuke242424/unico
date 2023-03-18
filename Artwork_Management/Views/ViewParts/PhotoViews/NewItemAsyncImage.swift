//
//  NewItemAsyncImage.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/18.
//
/// NOTE: 画像をclipShapeしても、切り取られた画像部分のタップ判定は残るみたい
/// 画像本体のタップ判定は無効化して、ZStackで上から同じフレームのViewを重ね、
/// そちら側にジェスチャー判定を任せている

import SwiftUI

struct NewItemAsyncImage: View {

    let imageURL: URL?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        if let imageURL = imageURL {
            
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.white).opacity(0.01)
                    .frame(width: width, height: height)
                AsyncImage(url: imageURL) { itemImage in
                    itemImage
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        ProgressView()
                        Color.black.opacity(0.2)
                    }
                }
                .frame(width: width, height: height)
                .allowsHitTesting(false)
            }

        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.gray)
                .frame(width: width, height: height)
                .overlay {
                    VStack(spacing: 20) {
                        Image(systemName: "cube.transparent.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .foregroundColor(.white)
                        Text("No Image.")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(0.7)
                    }
                }
        }
    }
}

struct NewItemAsyncImage_Previews: PreviewProvider {
    
    static var contentHeight: CGFloat = 220
    
    static var previews: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
                Spacer()
                HStack(spacing: -25) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.red)
                        .frame(width: size.width / 2, height: contentHeight * 0.8)
                        .overlay(Text("アイテム詳細"))
                        .zIndex(1)
                    
                    NewItemAsyncImage(imageURL: nil,
                                      width: size.width / 2,
                                      height: size.height)
                }
                Spacer()
            }
            .frame(width: size.width)
            .ignoresSafeArea()
        }
        .frame(height: contentHeight)
    }
}


