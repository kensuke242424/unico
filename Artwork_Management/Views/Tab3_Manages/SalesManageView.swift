//
//  SalesView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct SalesManageView: View {

    // NOTE: アイテム、タグのテストデータです
    @State private var items: [Item] =
    [
        Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "", price: 1800, sales: 88000, inventory: 200, createAt: Date(), updateAt: Date()),
        Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
             price: 2800, sales: 230000, inventory: 420, createAt: Date(), updateAt: Date()),
        Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "",
             price: 3200, sales: 360000, inventory: 402, createAt: Date(), updateAt: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single1", detail: "Single1のアイテム紹介テキストです。", photo: "",
             price: 1100, sales: 182000, inventory: 199, createAt: Date(), updateAt: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single2", detail: "Single2のアイテム紹介テキストです。", photo: "",
             price: 1310, sales: 105000, inventory: 43, createAt: Date(), updateAt: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single3", detail: "Single3のアイテム紹介テキストです。", photo: "",
             price: 1470, sales: 185000, inventory: 97, createAt: Date(), updateAt: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ1", detail: "グッズ1のアイテム紹介テキストです。", photo: "",
             price: 2300, sales: 329000, inventory: 88, createAt: Date(), updateAt: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ2", detail: "グッズ2のアイテム紹介テキストです。", photo: "",
             price: 3300, sales: 199200, inventory: 105, createAt: Date(), updateAt: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ3", detail: "グッズ3のアイテム紹介テキストです。", photo: "",
             price: 4000, sales: 520000, inventory: 97, createAt: Date(), updateAt: Date())
    ]
    var tags = ["Album", "Single", "Goods"]

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
                        ForEach(tags, id: \.self) { tag in

                            // タグ
                            Text("- \(tag) -")
                                .font(.largeTitle.bold())
                                .shadow(radius: 2, x: 4, y: 6)
                                .padding(.vertical)

                            // タグごとに分配してリスト表示
                            // enumerated ⇨ 要素とインデックス両方取得
                            ForEach(Array(items.enumerated()), id: \.offset) { offset, item in

                                if item.tag == tag {
                                    SalesItemListRow(item: item, listIndex: offset)
                                }
                            } // ForEach item
                        } // ForEach tag
                    } // VStack
                    .padding(.leading)
                    .navigationTitle("Sales")
                    .navigationBarTitleDisplayMode(.inline)

                } // ScrollView

                if isShowItemDetail {
                    ShowsItemDetail(item: items, index: $listIndex,
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
//                            self.tabIndex = 2

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
