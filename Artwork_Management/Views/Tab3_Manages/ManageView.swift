//
//  SalesView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

// NOTE: アイテムのソートタイプを管理します
enum SortType {
    case salesUp
    case salesDown
    case updateAtUp
    case createAtUp
    case start
}

// NOTE: アイテムのタググループ有無を管理します
enum TagGroup {
    case on // swiftlint:disable:this identifier_name
    case off
}

struct ManageView: View {

    @StateObject var itemVM: ItemViewModel

    // NOTE: 新規アイテム追加Viewの発現を管理します
    @Binding var isPresentedEditItem: Bool

    struct InputManage {
        // NOTE: リスト内のアイテム詳細を表示するトリガーです
        var isShowItemDetail = false
        // NOTE: リストの一要素Indexを、アイテム詳細画面表示時に渡します
        var listIndex = 0
        // NOTE: タググループ表示の切り替えに用います
        var tagGroup: TagGroup = .on
        // NOTE: アイテムのソート処理の切り替えに用います
        var sortType: SortType = .start
    }

    @State private var input: InputManage = InputManage()

    var body: some View {

        NavigationView {
            ZStack {
                ScrollView(.vertical) {

                    VStack(alignment: .leading) {

                        // NOTE: タグ表示の「ON」「OFF」で表示を切り替えます
                        switch input.tagGroup {

                        case .on:
                            // タグの要素数の分リストを作成
                            ForEach(itemVM.tags) { tag in

                                Text("- \(tag.tagName) -")
                                    .font(.largeTitle.bold())
                                    .shadow(radius: 2, x: 4, y: 6)
                                    .padding(.vertical)

                                // タグごとに分配してリスト表示
                                // enumerated ⇨ 要素とインデックス両方取得
                                ForEach(Array(itemVM.items.enumerated()), id: \.offset) { offset, item in

                                    if item.tag == tag.tagName {
                                        salesItemListRow(item: item, listIndex: offset)
                                    }
                                } // ForEach item
                            } // case .groupOn

                        case .off:

                            Text("- 全てのアイテム -")
                                .font(.largeTitle.bold())
                                .shadow(radius: 2, x: 4, y: 6)
                                .padding(.vertical)

                            ForEach(Array(itemVM.items.enumerated()), id: \.offset) { offset, item in

                                salesItemListRow(item: item, listIndex: offset)

                            } // case .groupOff
                        } // switch tagGroup
                    } // VStack
                    .padding(.leading)

                } // ScrollView

                if input.isShowItemDetail {
                    ShowsItemDetail(itemVM: itemVM,
                                    item: itemVM.items[input.listIndex],
                                    itemIndex: input.listIndex,
                                    isShowitemDetail: $input.isShowItemDetail
                    )
                } // if isShowItemDetail

            } // ZStack
            .navigationTitle("Sales")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Menu("タググループ") {

                            Button {
                                input.tagGroup = .on
                            } label: {
                                if input.tagGroup == .on {
                                    Text("ON   　　　　　 ✔︎")
                                } else {
                                    Text("ON")
                                }
                            } // ON

                            Button {
                                input.tagGroup = .off
                            } label: {
                                if input.tagGroup == .off {
                                    Text("OFF   　　　　　 ✔︎")
                                } else {
                                    Text("OFF")
                                }
                            } // OFF
                        } // タググループオプション

                        Menu("並び替え") {
                            Button {
                                self.input.sortType = .salesUp
                                itemVM.items = itemVM.itemsSort(sort: input.sortType, items: itemVM.items)
                            } label: {
                                if input.sortType == .salesUp {
                                    Text("売り上げ(↑)　　 ✔︎")
                                } else {
                                    Text("売り上げ(↑)")
                                }
                            }
                            Button {
                                self.input.sortType = .salesDown
                                itemVM.items = itemVM.itemsSort(sort: input.sortType, items: itemVM.items)
                            } label: {
                                if input.sortType == .salesDown {
                                    Text("売り上げ(↓)　　 ✔︎")
                                } else {
                                    Text("売り上げ(↓)")
                                }
                            }
                            Button {
                                self.input.sortType = .updateAtUp
                                itemVM.items = itemVM.itemsSort(sort: input.sortType, items: itemVM.items)
                            } label: {
                                if input.sortType == .updateAtUp {
                                    Text("最終更新日　　　✔︎")
                                } else {
                                    Text("最終更新日")
                                }
                            }
                            Button {
                                self.input.sortType = .createAtUp
                                itemVM.items = itemVM.itemsSort(sort: input.sortType, items: itemVM.items)
                            } label: {
                                if input.sortType == .createAtUp {
                                    Text("追加日　　　✔︎")
                                } else {
                                    Text("追加日")
                                }
                            }
                        } // 並び替えオプション

                    } label: {
                        Image(systemName: "list.bullet.indent")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                }
            } // .toolbar
            .sheet(isPresented: $isPresentedEditItem) {
                EditItemView(itemVM: itemVM,
                                isPresentedEditItem: $isPresentedEditItem,
                                itemIndex: 0,
                                passItemData: nil,
                                editItemStatus: .create)
            } // sheet(新規アイテム)

            .navigationBarTitleDisplayMode(.inline)
        } // NavigationView
    } // body

    @ViewBuilder
    func salesItemListRow(item: Item, listIndex: Int) -> some View {

        VStack(alignment: .leading, spacing: 20) {

            HStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray)
                    .frame(width: 70, height: 70)
                    .shadow(radius: 4, x: 5, y: 5)
                    .overlay {
                        Text("No Image.")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 20) {
                        Text("\(item.sales)円")
                            .font(.subheadline.bold())

                        Button {
                            self.input.listIndex = listIndex
                            print("listIndex: \(listIndex)")

                            input.isShowItemDetail.toggle()
                            print("isShowItemDetail: \(input.isShowItemDetail)")

                        } label: {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.gray)

                        } // Button
                    } // HStack

                    // NOTE: ラインの外枠を透明フレームで置いておくことで、
                    // ラインが端まで行ってもレイアウトが崩れない
                    switch item.tagColor {
                    case "赤":
                        IndicatorRow(salesValue: item.sales, tagColor: .red)
                    case "青":
                        IndicatorRow(salesValue: item.sales, tagColor: .blue)
                    case "黄":
                        IndicatorRow(salesValue: item.sales, tagColor: .yellow)
                    case "緑":
                        IndicatorRow(salesValue: item.sales, tagColor: .green)
                    default:
                        IndicatorRow(salesValue: item.sales, tagColor: .gray)
                    }

                    Text(item.name)
                        .font(.caption.bold())
                        .foregroundColor(.gray)

                } // VStack
                Spacer()
            } // HStack
        } // VStack
        .padding(.top)
    } // リストレイアウト
} // View

struct SalesView_Previews: PreviewProvider {
    static var previews: some View {
        ManageView(itemVM: ItemViewModel(), isPresentedEditItem: .constant(false))
    }
}
