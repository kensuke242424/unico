//
//  ItemDetailContents.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import SwiftUI

struct ItemDetailContents: View {

    let sales: Int
    let price: Int
    let inventory: Int
    let createAt: Date
    let updateAt: Date

    var body: some View {

        VStack(alignment: .listRowSeparatorLeading, spacing: 8) {

            Text("在庫残り　:　　 \(inventory) 個")
            Text("価格　　　:　　 \(price) 円")
            Text("総売上　　:　　 \(sales) 円")
                .padding(.bottom, 12)

            // NOTE: 下記二つの要素にはTimestampによる登録日が記述されます
            Text("登録日　　:　　 2022. 8.30")
            Text("最終更新　:　　 2022. 9.24")

        } // VStack
        .fontWeight(.light)
        .foregroundColor(.white)
        .tracking(1)
    } // body
} // View

struct ItemDetailContents_Previews: PreviewProvider {
    static var previews: some View {

        ZStack {
            Color.black
                .opacity(0.7)
                .frame(width: 300, height: 300)

            ItemDetailContents(sales: 82000,
                               price: 1900,
                               inventory: 57,
                               createAt: Date(),
                               updateAt: Date()
            )

        } // ZStack
    } // body
} // View
