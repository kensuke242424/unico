//
//  ItemStockControlView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct ItemStockView: View {

    @StateObject var itemVM: ItemViewModel

    @State private var searchItemText = ""
    @State private var isPresentedNewItem = false

    var body: some View {

        NavigationView {

            VStack {
                HStack {
                    TextField("　　　　　キーワード検索", text: $searchItemText)
                        .textFieldStyle(.roundedBorder)

                    Button {

                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 20)
                            .shadow(radius: 3, x: 1, y: 1)

                    } // Button
                } // HStack(検索ボタン)
                .padding()
                ItemShowBlock(itemWidth: 180,
                              itemHeight: 200,
                              itemSpase: 20,
                              itemNameTag: "アイテム")

            } // VStack
            .navigationTitle("ItemStock")
            .padding(.top)
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//
//                    Button {
//                        isPresentedNewItem.toggle()
//                    } label: {
//                        Image(systemName: "rectangle.stack.fill.badge.plus")
//                    }
//                }
//            } // toolbar
//
//            .sheet(isPresented: $isPresentedNewItem) {
//                NewItemView(itemVM: itemVM)
//            } // sheet
        } // NavigationView
    } // body
} // View

struct ItemStockControlView_Previews: PreviewProvider {
    static var previews: some View {
        ItemStockView(itemVM: ItemViewModel())
    }
}
