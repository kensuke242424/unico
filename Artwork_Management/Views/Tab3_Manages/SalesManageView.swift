//
//  SalesView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

enum SortType {
    case salesUp
    case salesDown
    case updateAtUp
    case createAtUp
}

enum TagGroup {
    case groupOn
    case groupOff
}

struct SalesManageView: View {

    @StateObject var itemVM = ItemViewModel()

    // NOTE: isShowItemDetail ⇨ リスト内のアイテム詳細を表示するトリガー
    // NOTE: listIndex ⇨ リストの一要素Indexを、アイテム詳細画面表示時に渡します
    @State private var isShowItemDetail = false
    @State private var listIndex = 0

    // NOTE: タググループ表示の切り替えに用います
    @State private var tagGroup: TagGroup = .groupOn



    // NOTE: アイテムごとのタグカラーをもとに、売上ゲージ色を決定します

    var body: some View {

        NavigationView {
            ZStack {
                ScrollView(.vertical) {

                    VStack(alignment: .leading) {

                        // NOTE: タグ表示の「ON」「OFF」で表示を切り替えます
                        switch tagGroup {

                        case .groupOn:
                            // タグの要素数の分リストを作成
                            ForEach(itemVM.tags, id: \.self) { tag in

                                Text("- \(tag) -")
                                    .font(.largeTitle.bold())
                                    .shadow(radius: 2, x: 4, y: 6)
                                    .padding(.vertical)

                                // タグごとに分配してリスト表示
                                // enumerated ⇨ 要素とインデックス両方取得
                                ForEach(Array(itemVM.items.enumerated()), id: \.offset) { offset, item in

                                    if item.tag == tag {
                                        SalesItemListRow(item: item, listIndex: offset)
                                    }
                                } // ForEach item
                            } // case .groupOn

                        case .groupOff:

                            Text("- 全てのアイテム -")
                                .font(.largeTitle.bold())
                                .shadow(radius: 2, x: 4, y: 6)
                                .padding(.vertical)

                            ForEach(Array(itemVM.items.enumerated()), id: \.offset) { offset, item in

                                    SalesItemListRow(item: item, listIndex: offset)

                            } // case .groupOff
                        } // switch tagGroup
                    } // VStack

                    .padding(.leading)

                } // ScrollView

                if isShowItemDetail {
                    ShowsItemDetail(item: itemVM.items, index: $listIndex,
                                    isShowitemDetail: $isShowItemDetail
                    )
                } // if isShowItemDetail

            } // ZStack
            .navigationTitle("Sales")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Menu("タググループ") {

                            Button {
                                tagGroup = .groupOn
                            } label: {
                                if tagGroup == .groupOn {
                                    Text("ON   　　　　　 ✔︎")
                                } else {
                                    Text("ON")
                                }
                            } // ON

                            Button {
                                tagGroup = .groupOff
                            } label: {
                                if tagGroup == .groupOff {
                                    Text("OFF   　　　　　 ✔︎")
                                } else {
                                    Text("OFF")
                                }
                            } // OFF
                        } // タググループオプション

                        Menu("並び替え") {
                            Button("売り上げ(↑)", action: {
                                itemVM.items = itemsSort(sortType: .salesUp, items: itemVM.items)
                            })
                            Button("売り上げ(↓)", action: {
                                itemVM.items = itemsSort(sortType: .salesDown, items: itemVM.items)
                            })
                            Button("最終更新日- 後日実装 -", action: {
                                itemVM.items = itemsSort(sortType: .updateAtUp, items: itemVM.items)
                            })
                            Button("追加日- 後日実装 -", action: {
                                itemVM.items = itemsSort(sortType: .createAtUp, items: itemVM.items)
                            })
                        } // 並び替えオプション

                    } label: {
                        Image(systemName: "list.bullet.indent")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                }
            } // .toolbar
            .navigationBarTitleDisplayMode(.inline)
        } // NavigationView
    } // body

    @ViewBuilder
    func SalesItemListRow(item: Item, listIndex: Int) -> some View {

        VStack(alignment: .leading, spacing: 20) {

            HStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray)
                    .frame(width: 70,height: 70)
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
                            self.listIndex = listIndex
                            print("listIndex: \(listIndex)")

                            isShowItemDetail.toggle()
                            print("isShowItemDetail: \(isShowItemDetail)")

                        } label: {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.gray)

                        } // Button
                    } // HStack

                    // NOTE: ラインの外枠を透明フレームで置いておくことで、
                    // ラインが端まで行ってもレイアウトが崩れない
                    switch item.tagColor {
                    case "赤":
                        IndicatorView(salesValue: item.sales, tagColor: .red)
                    case "青":
                        IndicatorView(salesValue: item.sales, tagColor: .blue)
                    case "黄":
                        IndicatorView(salesValue: item.sales, tagColor: .yellow)
                    default:
                        IndicatorView(salesValue: item.sales, tagColor: .gray)
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

    // ✅ NOTE: アイテム配列を各項目に沿ってソートするメソッド
    func itemsSort(sortType: SortType, items: [Item]) -> [Item] {

        // NOTE: 更新可能な値として格納しています
        var varItems = items

        switch sortType {

        case .salesUp:
            varItems.sort { $0.sales > $1.sales }
        case .salesDown:
            varItems.sort { $0.sales < $1.sales }
        case .createAtUp:
            print("createAtUp ⇨ Timestampが格納され次第、実装します。")
        case .updateAtUp:
            print("updateAtUp ⇨ Timestampが格納され次第、実装します。")
        }

        return varItems
    } // func itemsSort

} // View

struct SalesView_Previews: PreviewProvider {
    static var previews: some View {
        SalesManageView()
    }
}
