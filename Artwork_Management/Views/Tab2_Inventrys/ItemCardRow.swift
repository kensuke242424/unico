//
//  ItemCardRow.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/11.
//

import SwiftUI

struct ItemCardRow: View {

    // ダークモードの判定
    @Environment(\.colorScheme) var colorScheme

    let item: Item
    let itemWidth: CGFloat
    let itemHeight: CGFloat

    var body: some View {
        // NOTE: アイテムカードの色(ダークモードを判定してopacityをスイッチ)
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.white)
            .frame(width: itemWidth, height: itemHeight)
            .opacity(colorScheme == .dark ? 0.2 : 1.0)
            .overlay(alignment: .topTrailing) {
                Button {
                    // アイテム詳細表示
                } label: {
                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 23)
                        .foregroundColor(.brown)

                } // Button
            }

            // NOTE: アイテムカードのフレーム
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 0.2)
                    .foregroundColor(.brown)
                    .shadow(radius: 1)
                    .shadow(radius: 4)
                    .shadow(radius: 4)
                    .shadow(radius: 4)
                    .frame(width: itemWidth, height: itemHeight)
            }

        // NOTE: アイテムカードの内容
            .overlay {
                VStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.gray)
                        .opacity(0.2)
                        .frame(width: itemWidth - 50, height: itemWidth - 50)
                        .padding(.bottom)

                    HStack {
                        Text(item.name)
                            .font(.headline)
                            .fontWeight(.heavy)
                            .padding(.horizontal, 5)
                            .frame(width: itemWidth * 0.9)
                            .lineLimit(1)
                        Spacer()
                    }

                    Spacer()

                    HStack(alignment: .bottom) {
                        Text("¥")
                        Text(String(item.price))
                            .font(.title3)
                            .fontWeight(.heavy)
                        Spacer()
                    }

                } // VStack
                .padding()
            } // overlay
    } // body
} // View

struct ItemCardRow_Previews: PreviewProvider {
    static var previews: some View {


            ItemCardRow(item: Item(tag: "Album",
                                   tagColor: "赤",
                                   name: "Album1",
                                   detail: "Album1のアイテム紹介テキストです。",
                                   photo: "",
                                   price: 1800,
                                   sales: 88000,
                                   inventory: 200,
                                   createTime: Date(),
                                   updateTime: Date()),
                        itemWidth: UIScreen.main.bounds.width * 0.45,
                        itemHeight: 240
            )
            .previewLayout(.sizeThatFits)
    }
}
