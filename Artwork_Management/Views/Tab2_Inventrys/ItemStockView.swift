//
//  ItemStockControlView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct ItemStockView: View {

    @StateObject var itemVM: ItemViewModel

    var columnsH: [GridItem] = Array(repeating: .init(.flexible(),
                                                      spacing: 0), count: 1)

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
                .padding(.horizontal)

                // Todo: タグを横並べにスクロールし、中央に来たタグを検知してフィルタリング
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .opacity(0.2)
                        .frame(width: UIScreen.main.bounds.width - 20, height: 40)
                        .shadow(color: .black, radius: 4, x: 3, y: 3)
                        .overlay {
                            ScrollView(.horizontal, showsIndicators: false) {

                                LazyHGrid(rows: columnsH, spacing: 130) {

                                    Text("全て")

                                    ForEach(itemVM.tags) {tag in

                                        Text(tag.tagName)

                                    } // ForEachここまで
                                } // LazyHGridここまで
                                .padding()
                            } // ScrollViewここまで
                        } // overlay

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
