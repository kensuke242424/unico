//
//  LibraryDetail.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import SwiftUI

struct LibraryListView: View {

    var columnsH: [GridItem] = Array(repeating: .init(.flexible(),
                                                      spacing: 0), count: 1)

    // アイテムのディテールを指定します。
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let itemSpase: CGFloat
    let itemNameTag: String
    let itemColor: Color

    @Binding var isShowItemDetail: Bool

    var body: some View {

        VStack {

            HStack {
                Text(itemNameTag)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.gray)
                    .shadow(radius: 2, x: 2, y: 2)
                    .padding()
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {

                LazyHGrid(rows: columnsH, spacing: itemSpase) {

                    ForEach(1...20, id: \.self) {value in

                        // 制作物やジャケットのイメージが入ります。仮で図形を表示させています。
                        RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                            .foregroundColor(itemColor)
                            .frame(width: itemWidth, height: itemHeight)
                            .shadow(radius: 7, x: 10, y: 6)
                            .overlay(
                                Text("\(itemNameTag)\(value)")
                                    .font(.title3)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.white)
                            )

                    } // ForEachここまで
                    .padding(.bottom)
                    .padding(.leading)

                } // LazyHStackここまで
            } // ScrollViewここまで
        }

    } // body
} // View

struct LibraryDetail_Previews: PreviewProvider {
    static var previews: some View {
        LibraryListView(itemWidth: 220,
                      itemHeight: 220,
                      itemSpase: 40,
                      itemNameTag: "Album",
                      itemColor: .gray,
                      isShowItemDetail: .constant(false))
    }
}
