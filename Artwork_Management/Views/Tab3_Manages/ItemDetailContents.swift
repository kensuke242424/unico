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
            .padding(.bottom, 12)

            // NOTE: こちらにはTimestampによる登録日が記述されます
            HStack {
                Text("登録日　　:　　")
                Text("2022. 8.30")

            } // HStack

            // NOTE: こちらにはTimestampによる最終更新日が記述されます
            HStack {
                Text("更新日　　:　　")
                Text("2022. 9.24")

            } // HStack
        } // VStack
        .fontWeight(.light)
        .foregroundColor(.white)

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
