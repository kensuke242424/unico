//
//  ItemStockControlView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct ItemStockView: View {

    @StateObject var itemVM: ItemViewModel

    struct InputStock {
        var searchItemText: String = ""
        var isPresentedNewItem: Bool = false
    }

    @State private var input: InputStock = InputStock()

    var body: some View {

        NavigationView {

            VStack {
                HStack {
                    TextField("　　　　　キーワード検索", text: $input.searchItemText)
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
        } // NavigationView
    } // body
} // View

struct ItemStockControlView_Previews: PreviewProvider {
    static var previews: some View {
        ItemStockView(itemVM: ItemViewModel())
    }
}
