//
//  SalesView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct SalesManageView: View {

    @State private var items: [Item] =
    [
        Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "", price: 1800, sales: 88000, inventory: 200, createAt: Date(), updateAt: Date()),
        Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
             price: 2800, sales: 230000, inventory: 420, createAt: Date(), updateAt: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single1", detail: "Single1のアイテム紹介テキストです。", photo: "",
             price: 1100, sales: 182000, inventory: 199, createAt: Date(), updateAt: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single2", detail: "Single2のアイテム紹介テキストです。", photo: "",
             price: 1310, sales: 105000, inventory: 43, createAt: Date(), updateAt: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ1", detail: "グッズ1のアイテム紹介テキストです。", photo: "",
             price: 2300, sales: 329000, inventory: 88, createAt: Date(), updateAt: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ2", detail: "グッズ2のアイテム紹介テキストです。", photo: "",
             price: 4000, sales: 520000, inventory: 97, createAt: Date(), updateAt: Date())
    ]

    // NOTE: リスト内のアイテム詳細を表示するトリガー
    @State private var isShowItemDetail = false

    // NOTE: アイテムごとのタグカラーをもとに、売上ゲージ色を決定します
    var tags = ["Album", "Single", "Goods"]

    var body: some View {

        NavigationView {

            ZStack {
                ScrollView(.vertical) {

                    VStack(alignment: .leading) {
                        // タグの要素数の分リストを作成
                        ForEach(tags, id: \.self) { tag in

                            // タグ
                            Text(tag)
                                .font(.largeTitle.bold())
                                .shadow(radius: 2, x: 4, y: 10)
                                .padding(.vertical)

                            // タグごとに分配してリスト表示

                            ForEach(items) { item in

                                if item.tag == tag {
                                    ContactsForItem(item: item)
                                }
                            } // ForEach item
                        } // ForEach tag
                    } // VStack
                    .padding(.leading)
                    .navigationTitle("Sales")
                    .navigationBarTitleDisplayMode(.inline)

                } // ScrollView



            }

        } // NavigationView
    } // body

    @ViewBuilder
    func ContactsForItem(item: Item) -> some View {

        let size = UIScreen.main.bounds

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
                                isShowItemDetail.toggle()
                            print("isShowItemDetail: \(isShowItemDetail)")

                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)

                        } // Button
                    } // HStack


                    switch item.tagColor {
                    case "赤":

                        // NOTE: ラインの外枠を透明フレームで置いておくことで、ラインが端まで行ってもレイアウトが崩れない
                        Rectangle()
                            .frame(width: size.width - 150, height: 13)
                            .foregroundColor(.clear)
                            .overlay(alignment: .leading) {
                                Rectangle()
                                    .frame(width: CGFloat(item.sales) / 1000, height: 13)
                                    .foregroundColor(.red)
                                    .opacity(0.7)
                            } // case 赤

                    case "青":
                         Rectangle()
                            .frame(width: size.width - 150, height: 13)
                            .foregroundColor(.clear)
                            .overlay(alignment: .leading) {
                                Rectangle()
                                    .frame(width: CGFloat(item.sales) / 1000, height: 13)
                                    .foregroundColor(.blue)
                                    .opacity(0.7)
                            } // case 青

                    case "黄":
                         Rectangle()
                            .frame(width: size.width - 150, height: 13)
                            .foregroundColor(.clear)
                            .overlay(alignment: .leading) {
                                Rectangle()
                                    .frame(width: CGFloat(item.sales) / 1000, height: 13)
                                    .foregroundColor(.yellow)
                                    .opacity(0.7)
                            } // case 黄


                    default:
                        Rectangle()
                            .frame(height: 13)

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
