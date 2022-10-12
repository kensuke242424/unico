//
//  BasketItems.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/12.
//

import SwiftUI

enum HalfSheetScroll {
    case main
    case additional
}

struct BasketItemsSheet: View {

    let basketItems: [Item]?
    let halfSheetScroll: HalfSheetScroll

    private let listLimit: Int = 3

    var body: some View {

        switch halfSheetScroll {

        case .main:

            if let basketItems = basketItems {
                ForEach(0 ..< basketItems.count, id: \.self) { index in
                    if listLimit > index {
                        BasketItemRow(item: basketItems[index])
                    } // if
                } // ForEach
                .padding()
                .frame(width: UIScreen.main.bounds.width, height: 120)

            } else {
                Text("かごの中にアイテムはありません")
                    .foregroundColor(.gray)
                    .frame(height: 100)
            }

        case .additional:

            if let basketItems = basketItems {
                ForEach(listLimit ..< basketItems.count, id: \.self) { index in
                    BasketItemRow(item: basketItems[index])
                } // ForEach
                .padding()
                .frame(width: UIScreen.main.bounds.width, height: 120)

            } else {
                Spacer()
                    .frame(width: UIScreen.main.bounds.width,
                           height: 10)
            }

        } // switch
    } // body
} // View

struct BasketItemRow: View {

    let item: Item

    var body: some View {

        VStack {
            Divider()
                .background(.gray)

            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)

                Spacer()

                VStack(alignment: .trailing, spacing: 30) {
                    Text("\(item.name)")
                        .font(.title3.bold())
                        .lineLimit(1)

                    HStack(alignment: .bottom, spacing: 30) {

                        HStack(alignment: .bottom) {
                            Text("¥")
                            Text(String(item.price))
                                .font(.title3)
                                .fontWeight(.heavy)
                            Spacer()
                        }


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
                    .offset(y: 8)
                } // VStack
            } // HStack
        } // VStack(全体)
    } // body
} // view

struct BasketItems_Previews: PreviewProvider {
    static var previews: some View {
        BasketItemsSheet(basketItems:
            [
                Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "",
                     price: 1800, sales: 88000, inventory: 200, createTime: Date(), updateTime: Date()),
                Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
                     price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date()),
                Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "", price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date())
            ],
                    halfSheetScroll: .main
        )
    }
}
