//
//  ItemLibraryView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct LibraryView: View {

    var body: some View {

        VStack {
            ScrollView(.horizontal) {

                LazyHStack {
                    
                    ForEach(1...20, id: \.self) {value in
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 100, height: 100)
                    } // ForEachここまで


                } // LazyHStackここまで
            } // ScrollViewここまで

            ScrollView(.horizontal) {
                LazyHStack {


                    ForEach(1...20, id: \.self) {value in
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 100, height: 100)
                    } // ForEachここまで
                } // LazyHStackここまで
            }

            Text("ライブラリ画面")
                .font(.title)

            Text("(アイテムのコレクションライブラリ)")
                .padding()

        } // VStackここまで
    }
}

struct ItemLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
