//
//  SalesItemDetailView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/30.
//

import SwiftUI

struct SalesItemDetailView: View {

    let name: String
    let sales: Int
    let price: Int
    let inventory: Int
    let photo: String
    let size = UIScreen.main.bounds

    var body: some View {
        Rectangle()
            .frame(width: size.width / 1.3, height: size.height / 2)
            .opacity(0.6)

            .overlay {

                VStack(spacing: 10) {
                    Text(name)
                        .fontWeight(.black)
                        .foregroundColor(.white)

                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 170, height: 170)
                        .foregroundColor(.yellow)

                    HStack {
                        Text("　アイテム情報")
                            .fontWeight(.medium)
                            .foregroundColor(.white)

                        Button {
                            // アイテム編集画面
                        } label: {
                            Image(systemName: "highlighter")
                                .foregroundColor(.yellow)
                        }

                    }

                    Text("ーーーーーーーーーーーーー")
                        .foregroundColor(.white)

                    // NOTE: アイテムの情報が格納羅列されたカスタムViewです
                    SalesItemDetail(sales: sales, price: price, inventory: inventory)

                    Text("ーーーーーーーーーーーーー")
                        .foregroundColor(.white)

                } // VStack
            } // overlay
    } // body
} // View

struct SalesItemDetail: View {

    let sales: Int
    let price: Int
    let inventory: Int

    var body: some View {


        VStack(alignment: .listRowSeparatorLeading, spacing: 20) {

            HStack {

                Text("在庫残り　:　　")
                Text("\(inventory) 個")

            } // HStack

            HStack {

                Text("価格　　　:　　")
                Text("\(price) 円")

            } // HStack

            HStack {

                Text("総売上　　:　　")
                Text("\(sales) 円")

            } // HStack
        } // VStack
        .fontWeight(.light)
        .foregroundColor(.white)

    } // body
} // View

struct SalesItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SalesItemDetailView(name: "Album1", sales: 220000, price: 1800, inventory: 290, photo: "")
    }
}
