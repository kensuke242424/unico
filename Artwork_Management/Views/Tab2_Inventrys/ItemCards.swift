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

    @Binding var inputHome: InputHome
    @Binding var inputStock: InputStock
    let selectFilterTag: String

    private let columnsV: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {

        // NOTE: タグインデックス「0」 && searthItemTextが 「tags.first」 or  ""
        if inputStock.filterTagIndex == 0 &&
            inputStock.searchItemNameText == itemVM.tags.first!.tagName ||
            inputStock.searchItemNameText == "" {

            LazyVGrid(columns: columnsV, spacing: 20) {
                ForEach(itemVM.items) { item in

                    ItemCardRow(itemVM: itemVM,
                                inputHome: $inputHome,
                                inputStock: $inputStock,
                                itemRow: item)
                }
            }
            .padding(.horizontal, 10)
            Spacer().frame(height: 200)

        // NOTE: itemVM.items.「item.name」「item.tag」の中に一つでも検索条件が当てはまったら
        } else if itemVM.items.contains(where: { $0.name.contains(inputStock.searchItemNameText) }) ||
                    itemVM.items.contains(where: { $0.tag.contains(selectFilterTag) }) {

            LazyVGrid(columns: columnsV, spacing: 20) {
                ForEach(itemVM.items) { item in

                    if item.name.contains(inputStock.searchItemNameText) ||
                        item.tag.contains(inputStock.searchItemNameText) ||
                        item.tag.contains(selectFilterTag) {
                        ItemCardRow(itemVM: itemVM,
                                    inputHome: $inputHome,
                                    inputStock: $inputStock,
                                    itemRow: item)
                    }
                }
            }
            .padding(.horizontal, 10)
            Spacer().frame(height: 200)

        } else {
            Text(inputStock.filterTagIndex == 0 ? "検索に該当するアイテムはありません" : "タグに該当するアイテムはありません")
                .font(.subheadline)
                .foregroundColor(.white).opacity(0.6)
                .frame(height: 200)
            Spacer().frame(height: 300)
        }

    } // body
} // View

// ✅カスタムView: StockViewのアイテム表示要素から、最近更新したアイテムをピックアップするレイアウトです。
struct UpdateTimeSortCards: View {

    @StateObject var itemVM: ItemViewModel

    @Binding var inputHome: InputHome
    @Binding var inputStock: InputStock

    // アイテムのディテールを指定します。
    let columnsH: [GridItem] = Array(repeating: .init(.flexible()), count: 1)

    var body: some View {

        ScrollView(.horizontal) {
            LazyHGrid(rows: columnsH, spacing: 20) {
                ForEach(itemVM.items) { item in

                    ItemCardRow(itemVM: itemVM,
                                inputHome: $inputHome,
                                inputStock: $inputStock,
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
                                     inputHome: .constant(InputHome()),
                                     inputStock: .constant(InputStock()))
             } // ScrollView

            Divider()
                .background(.gray)
                .padding()

            TagTitle(title: "アイテム", font: .title)
            // ✅カスタムView: アイテムを表示します。(縦スクロール)
            TagSortCards(itemVM: ItemViewModel(),
                         inputHome: .constant(InputHome()),
                         inputStock: .constant(InputStock()),
                         selectFilterTag: "Album")
        } // ScrollView (アイテムロケーション)
    }
} // TagCards_Previews
