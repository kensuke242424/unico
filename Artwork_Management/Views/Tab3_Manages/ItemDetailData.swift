//
//  ItemDetailContents.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import SwiftUI

struct ItemDetailData: View {

    let item: Item

    var body: some View {

        VStack(alignment: .listRowSeparatorLeading, spacing: 8) {

            Text("タグ　　　:　　 \(item.tag)")
                .padding(.bottom, 12)
            Text("在庫　　　:　　 \(item.inventory) 個")
            Text("価格　　　:　　 ¥ \(item.price)")
            Text("総売上　　:　　 ¥ \(item.sales)")
                .padding(.bottom, 12)

            // NOTE: 下記二つの要素にはTimestampによる登録日が記述されます
            Text("登録日　　:　　 2022. 8.30")
            Text("最終更新　:　　 2022. 9.24")

        } // VStack
        .font(.callout)
        .fontWeight(.light)
        .foregroundColor(.white)
        .tracking(1)
    } // body
} // View

struct ItemDetailData_Previews: PreviewProvider {
    static var previews: some View {

        ZStack {
            Color.black
                .opacity(0.7)
                .frame(width: 300, height: 300)

            ItemDetailData(item: TestItem().testItem)

        } // ZStack
    } // body
} // View
