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
    @Binding var cartResults: CartResults
    let selectFilterTag: String

    private let columnsV: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {

        LazyVGrid(columns: columnsV, spacing: 20) {
            ForEach(itemVM.items) { item in

                if selectFilterTag == "ALL" || selectFilterTag == "検索" {
                    if inputStock.searchItemNameText == "ALL" || inputStock.searchItemNameText == "" {
                        ItemCardRow(itemVM: itemVM,
                                    inputStock: $inputStock,
                                    cartResults: $cartResults,
                                    itemRow: item)
                    } else {
                        if item.name.lowercased().contains(inputStock.searchItemNameText.lowercased()) {
                            ItemCardRow(itemVM: itemVM,
                                        inputStock: $inputStock,
                                        cartResults: $cartResults,
                                        itemRow: item)
                        }
                    }
                } else if item.tag == selectFilterTag {
                    ItemCardRow(itemVM: itemVM,
                                inputStock: $inputStock,
                                cartResults: $cartResults,
                                itemRow: item)
                }
            } // ForEach
        } // LazyVGrid
        .padding(.horizontal, 10)
        Spacer().frame(height: 200)
    } // body
} // View

// ✅カスタムView: StockViewのアイテム表示要素から、最近更新したアイテムをピックアップするレイアウトです。
struct UpdateTimeSortCards: View {

    @StateObject var itemVM: ItemViewModel

    @Binding var inputStock: InputStock
    @Binding var commerceResults: CartResults

    // アイテムのディテールを指定します。
    let columnsH: [GridItem] = Array(repeating: .init(.flexible()), count: 1)

    var body: some View {

        ScrollView(.horizontal) {
            LazyHGrid(rows: columnsH, spacing: 20) {
                ForEach(itemVM.items) { item in

                    ItemCardRow(itemVM: itemVM,
                                inputStock: $inputStock,
                                cartResults: $commerceResults,
                                itemRow: item)

                } // ForEach
            } // LazyHGrid
            .padding()
        }
        .frame(height: 246)
    } // body
} // View

struct TagCards_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            TagTitle(title: "最近更新したアイテム", font: .title3)
                .padding(.vertical)
             // ✅カスタムView: 最近更新したアイテムをHStack表示します。(横スクロール)
             ScrollView(.horizontal) {
                 UpdateTimeSortCards(itemVM: ItemViewModel(),
                                     inputStock: .constant(InputStock()),
                                     commerceResults: .constant(CartResults())
                 )
             } // ScrollView

            Divider()
                .background(.gray)
                .padding()

            TagTitle(title: "アイテム", font: .title)
            // ✅カスタムView: アイテムを表示します。(縦スクロール)
            TagSortCards(itemVM: ItemViewModel(),
                         inputStock: .constant(InputStock()),
                         cartResults: .constant(CartResults()),
                         selectFilterTag: "Album"
            )
        } // ScrollView (アイテムロケーション)
    }
} // TagCards_Previews
