//
//  ItemStockList.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import SwiftUI

// ✅カスタムView: StockViewのタグからピックアップされたカードのレイアウトです。
struct TagSortCards: View {

    @StateObject var itemVM: ItemViewModel

    @Binding var inputStock: InputStock
    @Binding var commerceResults: CommerceResults
    let selectFilterTag: String

    @State var searchItems: [Item] = []

    private let columnsV: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {

        LazyVGrid(columns: columnsV, spacing: 20) {
            ForEach(inputStock.searchItemNameText == "ALL" || inputStock.searchItemNameText == "" ?
                    itemVM.items : searchItems) { item in

                if selectFilterTag == "ALL" || selectFilterTag == "検索" {
                    ItemCardRow(itemVM: itemVM,
                                inputStock: $inputStock,
                                commerceResults: $commerceResults,
                                item: item)

                } else if item.tag == selectFilterTag {
                    ItemCardRow(itemVM: itemVM,
                                inputStock: $inputStock,
                                commerceResults: $commerceResults,
                                item: item)
                }
            } // ForEach
        } // LazyVGrid
        .padding(.horizontal, 10)
        Spacer().frame(height: 200)
            .onChange(of: inputStock.searchItemNameText) { newSearchText in
                if !inputStock.searchItemNameText.isEmpty {
                    searchItems = itemVM.items.filter({ $0.name.contains(newSearchText) })
                }
            }
    } // body
} // View

// ✅カスタムView: StockViewのアイテム表示要素から、最近更新したアイテムをピックアップするレイアウトです。
struct UpdateTimeSortCards: View {

    @StateObject var itemVM: ItemViewModel

    @Binding var inputStock: InputStock
    @Binding var commerceResults: CommerceResults

    // アイテムのディテールを指定します。
    let columnsH: [GridItem] = Array(repeating: .init(.flexible()), count: 1)

    var body: some View {

        ScrollView(.horizontal) {
            LazyHGrid(rows: columnsH, spacing: 20) {
                ForEach(itemVM.items) { item in

                    ItemCardRow(itemVM: itemVM,
                                inputStock: $inputStock,
                                commerceResults: $commerceResults,
                                item: item)

                } // ForEach
            } // LazyHGrid
            .padding()
        }
        .frame(height: 246)
    } // body
} // View
//
//struct TagCards_Previews: PreviewProvider {
//    static var previews: some View {
//        ScrollView {
//            TagTitle(title: "最近更新したアイテム", font: .title3)
//                .padding(.vertical)
//             // ✅カスタムView: 最近更新したアイテムをHStack表示します。(横スクロール)
//             ScrollView(.horizontal) {
//                 UpdateTimeSortCards(itemVM: ItemViewModel(),
//                                     isShowItemDetail: .constant(false),
//                                     actionRowIndex: .constant(0),
//                                     resultPrice: .constant(12000),
//                                                                                     commerceResults: .constant(5),
//                                     resultBasketItems: .constant([]),
//                                     itemWidth: 160,
//                                     itemHeight: 220,
//                                     itemSpase: 20,
//                                     itemNameTag: "アイテム",
//                                     items: [
//
//                                    // NOTE: テストデータ
//                                    Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "",
//                                         price: 1800, sales: 88000, inventory: 200, createTime: Date(), updateTime: Date()),
//                                    Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
//                                         price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date()),
//                                    Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "",
//                                         price: 3200, sales: 367000, inventory: 402, createTime: Date(), updateTime: Date()),
//                                    Item(tag: "Single", tagColor: "青", name: "Single1", detail: "Single1のアイテム紹介テキストです。", photo: "",
//                                         price: 1100, sales: 182000, inventory: 199, createTime: Date(), updateTime: Date())
//                                 ])
//             } // ScrollView
//
//            Divider()
//                .background(.gray)
//                .padding()
//
//            TagTitle(title: "アイテム", font: .title)
//            // ✅カスタムView: アイテムを表示します。(縦スクロール)
//            TagSortCards(itemVM: ItemViewModel(),
//                         searchItemNameText: .constant(""),
//                         actionRowIndex: .constant(0),
//                         resultPrice: .constant(12000),
//                         resultItemAmount: .constant(5),
//                         isShowItemDetail: .constant(false),
//                         resultBasketItems: .constant([]),
//                         itemWidth: UIScreen.main.bounds.width * 0.43,
//                         itemHeight: 220,
//                         itemSpase: 20,
//                         selectTag: "Album",
//                         items: [
//                            // NOTE: テストデータ
//                            Item(tag: "Album", tagColor: "赤", name: "Album1ddddddddddd", detail: "Album1のアイテム紹介テキストです。", photo: "",
//                                 price: 1800, sales: 88000, inventory: 200, createTime: Date(), updateTime: Date()),
//                            Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
//                                 price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date()),
//                            Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "",
//                                 price: 3200, sales: 367000, inventory: 402, createTime: Date(), updateTime: Date()),
//                            Item(tag: "Single", tagColor: "青", name: "Single1", detail: "Single1のアイテム紹介テキストです。", photo: "",
//                                 price: 1100, sales: 182000, inventory: 199, createTime: Date(), updateTime: Date()),
//                            Item(tag: "Single", tagColor: "青", name: "Single2", detail: "Single2のアイテム紹介テキストです。", photo: "",
//                                 price: 1310, sales: 105000, inventory: 43, createTime: Date(), updateTime: Date()),
//                            Item(tag: "Single", tagColor: "青", name: "Single3", detail: "Single3のアイテム紹介テキストです。", photo: "",
//                                 price: 1470, sales: 185000, inventory: 97, createTime: Date(), updateTime: Date()),
//                            Item(tag: "Goods", tagColor: "黄", name: "グッズ1", detail: "グッズ1のアイテム紹介テキストです。", photo: "",
//                                 price: 2300, sales: 329000, inventory: 88, createTime: Date(), updateTime: Date()),
//                            Item(tag: "Goods", tagColor: "黄", name: "グッズ2", detail: "グッズ2のアイテム紹介テキストです。", photo: "",
//                                 price: 3300, sales: 199000, inventory: 105, createTime: Date(), updateTime: Date()),
//                            Item(tag: "Goods", tagColor: "黄", name: "グッズ3", detail: "グッズ3のアイテム紹介テキストです。", photo: "",
//                                 price: 4000, sales: 520000, inventory: 97, createTime: Date(), updateTime: Date())
//                         ],
//            searchItems: [])
//        } // ScrollView (アイテムロケーション)
//    }
//} // TagCards_Previews
