//
//  BasketItems.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/12.
//

import SwiftUI

struct BasketItems: View {

    @Binding var basketItems: [Item]

    var body: some View {

        VStack {
            ForEach(basketItems) { item in
                HStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 30) {
                        Text("\(item.name)")
                            .font(.title3.bold())
                            .lineLimit(1)

                        HStack(spacing: 60) {
                            Button {
                                // マイナスボタン
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                            }
                            Text("1")
                                .fontWeight(.black)
                            Button {
                                // マイナスボタン
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                            }
                        }


                    } // VStack
                } // HStack
            } // VStack
            .padding()
            .frame(width: UIScreen.main.bounds.width, height: 120)
            .border(.gray)
        }
    }
}

struct BasketItems_Previews: PreviewProvider {
    static var previews: some View {
        BasketItems(basketItems: .constant(
            [
                Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "",
                     price: 1800, sales: 88000, inventory: 200, createTime: Date(), updateTime: Date()),
                Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
                     price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date()),
                Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "", price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date())
            ])
        )
    }
}
