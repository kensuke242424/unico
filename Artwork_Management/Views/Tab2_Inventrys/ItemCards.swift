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
struct TagSortCards: View {

    @Binding var searchItemNameText: String
    @Binding var actionRowIndex: Int
    @Binding var resultPrice: Int
    @Binding var resultItemAmount: Int
    @Binding var isShowItemDetail: Bool
    @Binding var resultBasketItems: [Item]

    // アイテムのディテールを指定します。
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let itemSpase: CGFloat
    let selectTag: String
    let items: [Item]
    @State var searchItems: [Item] = []

    let columnsV: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {

        LazyVGrid(columns: columnsV, spacing: itemSpase) {
            ForEach(Array(searchItemNameText == "ALL" || searchItemNameText == "" ?
                          items.enumerated() : searchItems.enumerated()),
                    id: \.offset) { offset, item in

                if selectTag == "ALL" || selectTag == "検索" {
                    ItemCardRow(isShowItemDetail: $isShowItemDetail,
                                actionRowIndex: $actionRowIndex,
                                resultPrice: $resultPrice,
                                resultItemAmount: $resultItemAmount,
                                resultBasketItems: $resultBasketItems,
                                rowIndex: offset,
                                item: item,
                                itemWidth: itemWidth,
                                itemHeight: itemHeight)

                } else if item.tag == selectTag {
                    ItemCardRow(isShowItemDetail: $isShowItemDetail,
                                actionRowIndex: $actionRowIndex,
                                resultPrice: $resultPrice,
                                resultItemAmount: $resultItemAmount,
                                resultBasketItems: $resultBasketItems,
                                rowIndex: offset,
                                item: item,
                                itemWidth: itemWidth,
                                itemHeight: itemHeight)
                }
            } // ForEach
        } // LazyVGrid
        .padding(.horizontal, 10)
        Spacer().frame(height: 200)
            .onChange(of: searchItemNameText) { newSearchText in
                if !searchItemNameText.isEmpty {
                    searchItems = items.filter({ $0.name.contains(newSearchText) })
                }
            }
    } // body
} // View

// ✅カスタムView: StockViewのアイテム表示要素から、最近更新したアイテムをピックアップするレイアウトです。
struct UpdateTimeSortCards: View {

    @Binding var isShowItemDetail: Bool
    @Binding var actionRowIndex: Int
    @Binding var resultPrice: Int
    @Binding var resultItemAmount: Int
    @Binding var resultBasketItems: [Item]

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
                                actionRowIndex: $actionRowIndex,
                                resultPrice: $resultPrice,
                                resultItemAmount: $resultItemAmount,
                                resultBasketItems: $resultBasketItems,
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
                 UpdateTimeSortCards(isShowItemDetail: .constant(false),
                                     actionRowIndex: .constant(0),
                                     resultPrice: .constant(12000),
                                     resultItemAmount: .constant(5),
                                     resultBasketItems: .constant([]),
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
            TagSortCards(searchItemNameText: .constant(""),
                         actionRowIndex: .constant(0),
                         resultPrice: .constant(12000),
                         resultItemAmount: .constant(5),
                         isShowItemDetail: .constant(false),
                         resultBasketItems: .constant([]),
                         itemWidth: UIScreen.main.bounds.width * 0.43,
                         itemHeight: 220,
                         itemSpase: 20,
                         selectTag: "Album",
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
                         ],
            searchItems: [])
        } // ScrollView (アイテムロケーション)
    }
} // TagCards_Previews
