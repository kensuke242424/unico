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

    @Binding var basketItems: [Item]?
    let halfSheetScroll: HalfSheetScroll

    private let listLimit: Int = 3

    var body: some View {

        // NOTE: 親View、ScrollResizableSheetの設定「.main」「.additional」
        //       .main ⇨ シート呼び出し時に表示される要素を設定します。
        //       .additional ⇨ シート内のスクロール全体に表示するアイテムを設定します。
        switch halfSheetScroll {

        case .main:

            // NOTE: アイテム取引かごシート表示時のアイテム表示数をプロパティ「listLimit」の値分で制限します。
            //       現在、シート呼び出し時の初期アイテム表示は3つまでとしています。以降の要素はスクロールにより表示します。
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
                if basketItems.count > listLimit {
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
            } else {
                Spacer()
                    .frame(width: UIScreen.main.bounds.width,
                           height: 10)
            } // if let
        } // switch
    } // body
} // View

// ✅ カスタムView: かご内の一要素分のレイアウト
struct BasketItemRow: View {

    let item: Item

    var body: some View {

        VStack {
            
            Divider()
                .background(.gray)

            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.customLightGray1)
                    .opacity(0.3)

                Spacer()

                VStack(alignment: .trailing, spacing: 30) {
                    Text("\(item.name)")
                        .foregroundColor(.black)
                        .opacity(0.8)
                        .font(.title3.bold())
                        .lineLimit(1)

                    HStack(alignment: .bottom, spacing: 30) {

                        HStack(alignment: .bottom) {
                            Text("¥")
                                .foregroundColor(.black)
                            Text(String(item.price))
                                .foregroundColor(.black)
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
                                .foregroundColor(.customlDarkPurple1)
                        }
                        Text("1")
                            .foregroundColor(.black)
                            .fontWeight(.black)
                        Button {
                            // マイナスボタン
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.customlDarkPurple1)
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
                .constant([
                Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "",
                     price: 1800, sales: 88000, inventory: 200, createTime: Date(), updateTime: Date()),
                Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
                     price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date()),
                Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "", price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date())
            ]),
                    halfSheetScroll: .main
        )
    }
}
