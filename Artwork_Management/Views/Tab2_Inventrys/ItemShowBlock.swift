//
//  ItemStockList.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import SwiftUI

struct ItemShowBlock: View {

    var columnsV: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    // アイテムのディテールを指定します。
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let itemSpase: CGFloat
    let itemNameTag: String

    var body: some View {

        ScrollView {
            LazyVGrid(columns: columnsV, spacing: itemSpase) {
                ForEach(1...20, id: \.self) { value in

                    RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                        .foregroundColor(Color.gray)
                        .frame(width: itemWidth, height: itemHeight)
                        .shadow(radius: 7, x: 10, y: 6)
                        .overlay(
                            Text("\(itemNameTag)\(value)")
                                .font(.title3)
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                        )
                }
            }
        }
    }
}

struct ItemStockList_Previews: PreviewProvider {
    static var previews: some View {
        ItemShowBlock(itemWidth: 180,
                      itemHeight: 100,
                      itemSpase: 20,
                      itemNameTag: "Album")
    }
}
