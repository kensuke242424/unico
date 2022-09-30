//
//  SalesView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct SalesManageView: View {

    @StateObject var itemVM = ItemViewModel()

    // NOTE: isShowItemDetail ⇨ リスト内のアイテム詳細を表示するトリガー
    // NOTE: listIndex ⇨ リストの一要素Indexを、アイテム詳細画面表示時に渡します
    @State private var isShowItemDetail = false
    @State private var listIndex = 0

    // NOTE: アイテムごとのタグカラーをもとに、売上ゲージ色を決定します

    var body: some View {

        NavigationView {

            ZStack {

                ScrollView(.vertical) {

                    VStack(alignment: .leading) {
                        // タグの要素数の分リストを作成
                        ForEach(itemVM.tags, id: \.self) { tag in

                            // タグ
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
                        } // ForEach tag
                    } // VStack
                    .padding(.leading)
                    .navigationTitle("Sales")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button("売り上げ(上り順)", action: {})
                                Button("売り上げ(下り順)", action: {})
                                Button("最終更新日", action: {})
                                Button("追加日", action: {})
                            } label: {
                                Image(systemName: "list.bullet.indent")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                        }
                    }

                    .navigationBarTitleDisplayMode(.inline)

                } // ScrollView

                if isShowItemDetail {
                    ShowsItemDetail(item: itemVM.items, index: $listIndex,
                                    isShowitemDetail: $isShowItemDetail
                    )

                } // if isShowItemDetail
            } // ZStack

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
} // View

struct SalesView_Previews: PreviewProvider {
    static var previews: some View {
        SalesManageView()
    }
}
