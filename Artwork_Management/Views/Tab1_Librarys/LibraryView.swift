//
//  ItemLibraryView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct LibraryView: View {

    @State var itemName = ""
    @Binding var isShowItemDetail: Bool

    var body: some View {

        NavigationView {

            ZStack {

                ScrollView(.vertical) {

                    VStack(spacing: 20) {

                        LibraryListView(itemWidth: 250, itemHeight: 250, itemSpase: 60, itemNameTag: "Album",
                                      itemColor: .gray, isShowItemDetail: $isShowItemDetail)

                        LibraryListView(itemWidth: 180, itemHeight: 180, itemSpase: 40, itemNameTag: "Single",
                                      itemColor: .yellow, isShowItemDetail: $isShowItemDetail)

                        LibraryListView(itemWidth: 350, itemHeight: 300, itemSpase: 5, itemNameTag: "Picture",
                                      itemColor: .red, isShowItemDetail: $isShowItemDetail)

                        LibraryListView(itemWidth: 200, itemHeight: 150, itemSpase: 20, itemNameTag: "Goods",
                                      itemColor: .blue, isShowItemDetail: $isShowItemDetail)


                    } // VStack
                } // ScrollView
            } // ZStack

            .overlay(
                LibraryDetailShow(itemName: "a")
                    .opacity(isShowItemDetail ? 0.6 : 0)
            )
        } // NavigationView
    } // body
} // View

struct ItemLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(isShowItemDetail: .constant(false))
    }
}
