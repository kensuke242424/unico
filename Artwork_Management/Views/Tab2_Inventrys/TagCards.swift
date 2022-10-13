//
//  ItemStockList.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import SwiftUI

enum ShowItemSize {
    case mini
    case medium
}

// ✅カスタムView: StockViewのタグからピックアップされたカードのレイアウトです。
struct TagCards: View {

    @Binding var isShowItemDetail: Bool
    @Binding var listIndex: Int

    // アイテムのディテールを指定します。
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let itemSpase: CGFloat
    let itemNameTag: String
    let items: [Item]

    let columnsV: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {

        LazyVGrid(columns: columnsV, spacing: itemSpase) {
            ForEach(Array(items.enumerated()), id: \.offset) { offset, item in

                ItemCardRow(isShowItemDetail: $isShowItemDetail,
                            listIndex: $listIndex,
                            rowIndex: offset,
                            item: item,
                            itemWidth: itemWidth,
                            itemHeight: itemHeight)
            } // ForEach
        } // LazyVGrid
        .padding(.horizontal, 10)
        Spacer().frame(height: 200)
    } // body
} // View

// ✅カスタムView: StockViewのアイテム表示要素から、最近更新したアイテムをピックアップするレイアウトです。
struct UpdateTimeCards: View {

    @Binding var isShowItemDetail: Bool
    @Binding var listIndex: Int

    // アイテムのディテールを指定します。
    let columnsH: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let itemSpase: CGFloat
    let itemNameTag: String
    let items: [Item]

    var body: some View {

        ScrollView(.horizontal) {
            LazyHGrid(rows: columnsH, spacing: itemSpase) {
                ForEach(Array(items.enumerated()), id: \.offset) { offset, item in

                    ItemCardRow(isShowItemDetail: $isShowItemDetail,
                                listIndex: $listIndex,
                                rowIndex: offset,
                                item: item,
                                itemWidth: itemWidth,
                                itemHeight: itemHeight)

                } // ForEach
            } // LazyHGrid
            .padding()
        }
        .frame(height: itemHeight)

    } // body
} // View

struct TagCards_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            TagTitle(title: "最近更新したアイテム", font: .title3)
                .padding(.vertical)
             // ✅カスタムView: 最近更新したアイテムをHStack表示します。(横スクロール)
             ScrollView(.horizontal) {
                 UpdateTimeCards(isShowItemDetail: .constant(false),
                                 listIndex: .constant(0),
                                 itemWidth: 160,
                                 itemHeight: 220,
                                 itemSpase: 20,
                                 itemNameTag: "アイテム",
                                 items: [

                                    // NOTE: テストデータ
                                    Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "",
                                         price: 1800, sales: 88000, inventory: 200, createTime: Date(), updateTime: Date()),
                                    Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
                                         price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date()),
                                    Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "",
                                         price: 3200, sales: 367000, inventory: 402, createTime: Date(), updateTime: Date()),
                                    Item(tag: "Single", tagColor: "青", name: "Single1", detail: "Single1のアイテム紹介テキストです。", photo: "",
                                         price: 1100, sales: 182000, inventory: 199, createTime: Date(), updateTime: Date())
                                 ])
             } // ScrollView
             .frame(height: 220)

            Divider()
                .background(.gray)
                .padding()

            TagTitle(title: "アイテム", font: .title)
            // ✅カスタムView: アイテムを表示します。(縦スクロール)
            TagCards(isShowItemDetail: .constant(false),
                     listIndex: .constant(0),
                     itemWidth: UIScreen.main.bounds.width * 0.43,
                     itemHeight: 220,
                     itemSpase: 20,
                     itemNameTag: "アイテム",
                     items: [
                        // NOTE: テストデータ
                        Item(tag: "Album", tagColor: "赤", name: "Album1ddddddddddd", detail: "Album1のアイテム紹介テキストです。", photo: "",
                             price: 1800, sales: 88000, inventory: 200, createTime: Date(), updateTime: Date()),
                        Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
                             price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date()),
                        Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "",
                             price: 3200, sales: 367000, inventory: 402, createTime: Date(), updateTime: Date()),
                        Item(tag: "Single", tagColor: "青", name: "Single1", detail: "Single1のアイテム紹介テキストです。", photo: "",
                             price: 1100, sales: 182000, inventory: 199, createTime: Date(), updateTime: Date()),
                        Item(tag: "Single", tagColor: "青", name: "Single2", detail: "Single2のアイテム紹介テキストです。", photo: "",
                             price: 1310, sales: 105000, inventory: 43, createTime: Date(), updateTime: Date()),
                        Item(tag: "Single", tagColor: "青", name: "Single3", detail: "Single3のアイテム紹介テキストです。", photo: "",
                             price: 1470, sales: 185000, inventory: 97, createTime: Date(), updateTime: Date()),
                        Item(tag: "Goods", tagColor: "黄", name: "グッズ1", detail: "グッズ1のアイテム紹介テキストです。", photo: "",
                             price: 2300, sales: 329000, inventory: 88, createTime: Date(), updateTime: Date()),
                        Item(tag: "Goods", tagColor: "黄", name: "グッズ2", detail: "グッズ2のアイテム紹介テキストです。", photo: "",
                             price: 3300, sales: 199000, inventory: 105, createTime: Date(), updateTime: Date()),
                        Item(tag: "Goods", tagColor: "黄", name: "グッズ3", detail: "グッズ3のアイテム紹介テキストです。", photo: "",
                             price: 4000, sales: 520000, inventory: 97, createTime: Date(), updateTime: Date())
                     ])
        } // ScrollView (アイテムロケーション)
    }
} // TagCards_Previews
