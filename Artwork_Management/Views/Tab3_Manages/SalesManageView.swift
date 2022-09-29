//
//  SalesView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct SalesManageView: View {

    @State var items: [Item] =
    [
        Item(tag: "Album", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "", price: 1800, sales: 88000, inventory: 200, createAt: Date(), updateAt: Date()),
        Item(tag: "Album", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
             price: 2800, sales: 230000, inventory: 420, createAt: Date(), updateAt: Date()),
        Item(tag: "Single", name: "Single1", detail: "Single1のアイテム紹介テキストです。", photo: "",
             price: 1100, sales: 182000, inventory: 199, createAt: Date(), updateAt: Date()),
        Item(tag: "Single", name: "Single2", detail: "Single2のアイテム紹介テキストです。", photo: "",
             price: 1310, sales: 105000, inventory: 43, createAt: Date(), updateAt: Date()),
        Item(tag: "Goods", name: "グッズ1", detail: "グッズ1のアイテム紹介テキストです。", photo: "",
             price: 2300, sales: 329000, inventory: 88, createAt: Date(), updateAt: Date()),
        Item(tag: "Goods", name: "グッズ2", detail: "グッズ2のアイテム紹介テキストです。", photo: "",
             price: 4000, sales: 520000, inventory: 97, createAt: Date(), updateAt: Date())
    ]

    var tags = ["Album", "Single", "Goods"]

    var body: some View {

        NavigationView {

            ScrollView(.vertical, showsIndicators: false) {

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
                .padding()
                .navigationTitle("Sales")
                .navigationBarTitleDisplayMode(.inline)

            } // ScrollView
        } // NavigationView
    } // body

    @ViewBuilder
    func ContactsForItem(item: Item) -> some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray)
                    .frame(width: 100,height: 100)
                    .shadow(radius: 4, x: 5, y: 5)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 20) {
                        Text(item.name)
                            .font(.title3.bold())


                        Button {

                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                        }

                    }


                    Text("\(item.sales)円")
                        .font(.title.bold())
                        .underline(color: .gray)

                    HStack(spacing: 20) {
                        Text("価格 \(item.price)")
                            .fontWeight(.light)
                        Text("在庫 \(item.inventory)")
                            .fontWeight(.light)

                    } // HStack
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
