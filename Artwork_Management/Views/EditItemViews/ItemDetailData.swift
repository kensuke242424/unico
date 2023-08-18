//
//  ItemDetailContents.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import SwiftUI

struct ItemDetailData: View {

    let item: Item

//    var createTime: String {
//        if let createTime = item.createTime {
//            let formatter = DateFormatter()
//            formatter.setTemplate(.date, .jaJP)
//            return formatter.string(from: createTime.dateValue())
//        } else {
//            return "???"
//        }
//    }
//    var updateTime: String {
//        if let updateTime = item.updateTime {
//            let formatter = DateFormatter()
//            formatter.setTemplate(.date, .jaJP)
//            return formatter.string(from: updateTime.dateValue())
//        } else {
//            return "???"
//        }
//    }

    var body: some View {

        VStack(alignment: .listRowSeparatorLeading, spacing: 8) {

            Text("タグ　　　:　　 \(item.tag)")
                .frame(width: getRect().width * 0.6)
                .padding(.bottom, 12)
            Text("在庫　　　:　　 \(item.inventory) 個")
            Text(item.price != 0 ? "価格　　　:　　 ¥ \(item.price)" : "価格　　　:　　   -")
            Text(item.sales != 0 ? "総売上　　:　　 ¥ \(item.sales)" : "総売上　　:　　   -")
                .padding(.bottom, 12)

            // NOTE: 下記二つの要素にはTimestampによる登録日が記述されます
            Text("登録日　　:　　 \(item.createTime.toStringWithCurrentLocale())")
            Text("最終更新　:　　 \(item.updateTime.toStringWithCurrentLocale())")

        } // VStack
        .font(.callout)
        .fontWeight(.light)
        .foregroundColor(.white)
        .tracking(1)
        .lineLimit(1)
    } // body
} // View

struct ItemDetailData_Previews: PreviewProvider {
    static var previews: some View {

        ZStack {
            Color.black
                .opacity(0.7)
                .frame(width: 300, height: 300)

            ItemDetailData(item: sampleItems.first!)

        } // ZStack
    } // body
} // View
