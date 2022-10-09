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
    @State private var currentIndex = 0
    @State private var sideTagOpacity = 0.7

    let itemPadding: CGFloat = 80

    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {

        NavigationView {

            VStack {
                HStack {
                    TextField("　　　　　キーワード検索", text: $searchItemText)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        // Todo: 検索アクション
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

                GeometryReader { bodyView in

                    LazyHStack(spacing: itemPadding) {

                        ForEach(itemVM.tags.indices, id: \.self) {index in

                            Text(itemVM.tags[index].tagName)
                                .frame(width: bodyView.size.width * 0.7, height: 40)
                                .font(.system(size: 20, weight: .bold))
                                .padding(.leading, index == 0 ? bodyView.size.width * 0.1 : 0)

                        } // ForEach
                    } // LazyHStack
                    .padding()
                    .offset(x: self.dragOffset)
                    .offset(x: -CGFloat(self.currentIndex) * (bodyView.size.width * 0.7 + itemPadding))

                    .gesture(
                        DragGesture()
                            .updating(self.$dragOffset, body: { (value, state, _) in

                                // 移動幅（width）のみ更新する
                                state = value.translation.width
                            })
                            .onEnded({ value in
                                var newIndex = self.currentIndex

                                // ドラッグ幅からページングを判定
                                // 今回は画面幅x0.3としているが、操作感に応じてカスタマイズする必要がある
                                if abs(value.translation.width) > bodyView.size.width * 0.2 {
                                    newIndex = value.translation.width > 0 ? self.currentIndex - 1 : self.currentIndex + 1
                                }
                                if newIndex < 0 {
                                    newIndex = 0
                                } else if newIndex > (itemVM.tags.count - 1) {
                                    newIndex = itemVM.tags.count - 1
                                }
                                self.currentIndex = newIndex
                            }) // .onEnded
                    ) // .gesture
                    // 減衰ばねモデル、それぞれの値は操作感に応じて変更する
                    .animation(.interpolatingSpring(mass: 0.4,
                                                    stiffness: 100,
                                                    damping: 80,
                                                    initialVelocity: 0.1),
                               value: dragOffset)
                } // Geometry
                .frame(height: 60) // Geometry範囲のflame

                // NOTE: サイドタグバーの枠フレームを表示します。
                .overlay {
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(lineWidth: 1)
                        .opacity(0.4)
                        .frame(width: UIScreen.main.bounds.width + 10, height: 40)
                        .shadow(color: .black, radius: 4, x: 3, y: 3)

                    // NOTE: タグサイドバー枠内で、現在選択しているタグの前後の値をインフォメーションします。
                        .overlay {
                            HStack {
                                if currentIndex - 1 >= 0 {
                                    HStack {
                                        Text("<")
                                        Text("\(itemVM.tags[currentIndex - 1].tagName)")
                                            .frame(width: 50)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()

                                if currentIndex + 1 < itemVM.tags.count {
                                    HStack {
                                        Text("\(itemVM.tags[currentIndex + 1].tagName)")
                                            .frame(width: 50)
                                            .lineLimit(1)
                                        Text(">")
                                    }
                                }
                            } // HStack
                            .padding(.horizontal, 20)
                            .opacity(sideTagOpacity)

                        } // overlay(サイドタグ情報)
                        .animation(.easeIn(duration: 0.2), value: sideTagOpacity)
                } // overlay サイドタグバーのフレーム

                // NOTE: サイドタグバー両端のタグインフォメーションopacityを、ドラッグ位置を監視して管理しています。
                .onChange(of: dragOffset) { newValue in
                    if newValue == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.sideTagOpacity = 0.7
                        }
                    } else {
                        self.sideTagOpacity = 0.0
                    }
                } // onChange

                Divider()

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
