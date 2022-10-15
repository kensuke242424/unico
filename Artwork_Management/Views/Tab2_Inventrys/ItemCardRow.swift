//
//  ItemCardRow.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/11.
//

import SwiftUI

struct ItemCardRow: View {

    // ダークモードの判定に用いる
    @Environment(\.colorScheme) var colorScheme

    @Binding var isShowItemDetail: Bool
    @Binding var actionRowIndex: Int
    @Binding var resultPrice: Int
    @Binding var resultItemAmount: Int
    @Binding var resultBasketItems: [Item]

    let rowIndex: Int

    let item: Item
    let itemWidth: CGFloat
    let itemHeight: CGFloat

    var body: some View {
        // NOTE: アイテムカードの色(ダークモードを判定してopacityをスイッチ)
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.white)
            .frame(width: itemWidth, height: itemHeight)
            .opacity(colorScheme == .dark ? 0.3 : 0.3)
            .overlay(alignment: .topTrailing) {
                Button {
                    print("rowIndex: \(rowIndex)")
                    actionRowIndex = rowIndex
                    // アイテム詳細表示
                    self.isShowItemDetail.toggle()
                    print("ItemStockView_アイテム詳細ボタンタップ: \(isShowItemDetail)")
                } label: {
                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 23)
                        .foregroundColor(.customDarkGray1)
                        .opacity(0.6)
                } // Button
            } // .overlay

            // NOTE: アイテムカードのフレーム
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 0.2)
                    .shadow(radius: 3, x: 4, y: 4)
                    .shadow(radius: 3, x: 4, y: 4)
                    .shadow(radius: 3, x: 4, y: 4)
                    .shadow(radius: 3, x: 4, y: 4)
                    .shadow(radius: 3, x: 1, y: 1)
                    .shadow(radius: 3, x: 1, y: 1)
                    .shadow(radius: 4)
                    .shadow(radius: 4)
                    .foregroundColor(.customDarkGray1)
                    .frame(width: itemWidth, height: itemHeight)
            } // overlay

            // NOTE: アイテムカードの内容
            .overlay {
                VStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.white)
                        .opacity(0.5)
                        .frame(width: itemWidth - 50, height: itemWidth - 50)

                    Text(item.name)
                        .foregroundColor(.black)
                        .font(.callout)
                        .fontWeight(.heavy)
                        .padding(.horizontal, 5)
                        .padding(.top, 5)
                        .frame(width: itemWidth * 0.9)
                        .lineLimit(1)

                    Spacer()

                    HStack(alignment: .bottom) {
                        Text("¥")
                            .foregroundColor(.black)
                        Text(String(item.price))
                            .font(.title3)
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                        Spacer()

                        Button {
                            // 取引かごに追加するボタン
                            // タップするたびに、値段合計、個数、カート内アイテム要素にプラスする
                            resultPrice += item.price
                            actionRowIndex = rowIndex
                            print("ItemCardRow_+ボタンタップ rowIndex(\(rowIndex))")
                            print("ItemCardRow_+ボタンタップ actionRowIndex(\(actionRowIndex))")

                            // カート内に対象アイテムがなければ、カートに要素を新規追加
                            if resultBasketItems.filter({ $0 == item }) == [] {
                                resultBasketItems.append(item)
                            }
                            resultItemAmount += 1

                            print("resultPrice: \(resultPrice)円")
                            print("resultItemAmount: \(resultItemAmount)個")

                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.customDarkGray1)
                        } // Button
                        .offset(x: 5, y: 5)
                    } // HStack
                } // VStack
                .padding()
            } // overlay

    } // body
} // View

struct ItemCardRow_Previews: PreviewProvider {
    static var previews: some View {

        ItemCardRow(isShowItemDetail: .constant(false),
                    actionRowIndex: .constant(0),
                    resultPrice: .constant(12000),
                    resultItemAmount: .constant(3),
                    resultBasketItems: .constant([]),
                    rowIndex: 0,
                    item: Item(tag: "Album",
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
