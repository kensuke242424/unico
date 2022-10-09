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
    @State private var leftTagIndex = 0
    @State private var rightTagIndex = 0
    @State private var sideTagOpacity = 0.0

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
                    .onChange(of: currentIndex) { newValue in
                        print(newValue)
                        self.leftTagIndex = newValue - 1
                        self.rightTagIndex = newValue + 1
                    }
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

                // NOTE: タグサイドバー内で、現在選択しているタグの前後の値をインフォメーションします。
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .opacity(0.2)
                        .frame(width: UIScreen.main.bounds.width - 20, height: 40)
                        .shadow(color: .black, radius: 4, x: 3, y: 3)
                        .overlay {
                            HStack {

                                Text("aaaa")

                                Spacer()

                                Text("aaaa")
                            }
                            .padding(.horizontal)

                        } // overlay(サイドタグ情報)
                        .opacity(sideTagOpacity)
                        .animation(.easeIn(duration: 0.2), value: sideTagOpacity)
                } // overlay サイドタグバーのフレーム

                // NOTE: サイドタグバー両端のタグインフォメーションのopacityを管理しています
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
