//
//  ItemCardRow.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/11.
//

import SwiftUI

struct ItemCardRow: View {

    @Environment(\.colorScheme) var colorScheme
    @StateObject var itemVM: ItemViewModel
    @Binding var inputStock: InputStock
    @Binding var cartResults: CartResults
    let itemRow: Item

    let itemWidth: CGFloat = 165
    let itemHeight: CGFloat = 210

    @State private var cardCount: Int =  0
    @State private var soldOpacity: CGFloat = 0.0
    @State private var countUpDisable: Bool = false
    @State private var itemSold: Bool = false

    var body: some View {

        VStack {
            // NOTE: アイテムカードの色(ダークモードを判定してopacityをスイッチ)
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .frame(width: itemWidth, height: itemHeight)
                .opacity(colorScheme == .dark ? 0.3 : 0.3)
                .overlay(alignment: .topTrailing) {
                    Button {

                        guard let newActionIndex = itemVM.items.firstIndex(where: { $0 == itemRow }) else {
                            print("アクションIndexの取得に失敗しました")
                            return
                        }
                        inputStock.actionRowIndex = newActionIndex
                        print("actionRowIndex: \(inputStock.actionRowIndex)")
                            // アイテム詳細表示
                        inputStock.isShowItemDetail.toggle()
                        print("ItemStockView_アイテム詳細ボタンタップ: \(inputStock.isShowItemDetail)")

                    } label: {
                        Image(systemName: "info.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 23, height: 23)
                            .foregroundColor(.customDarkGray1)
                            .opacity(0.6)
                    } // Button
                } // .overlay

                // NOTE: アイテムカードのフレーム
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 0.2)
                        .shadow(radius: 3, x: 4, y: 4)
                        .shadow(radius: 3, x: 4, y: 4)
                        .shadow(radius: 3, x: 4, y: 4)
                        .shadow(radius: 3, x: 4, y: 4)
                        .shadow(radius: 3, x: 1, y: 1)
                        .shadow(radius: 3, x: 1, y: 1)
                        .shadow(radius: 4)
                        .shadow(radius: 4)
                        .foregroundColor(.customDarkGray1)
                        .frame(width: itemWidth, height: itemHeight)
                } // overlay

                // NOTE: アイテムカードの内容
                .overlay {
                    VStack {

                    ShowItemPhoto(photo: itemRow.photo, size: itemWidth - 50)

                        Text(itemRow.name)
                            .foregroundColor(.black)
                            .font(.caption)
                            .padding(.horizontal, 5)
                            .padding(.top, 5)
                            .frame(width: itemWidth * 0.9)
                            .lineLimit(1)

                        Spacer()

                        HStack(alignment: .bottom) {
                            Text("¥")
                                .foregroundColor(.black)
                            Text(String(itemRow.price))
                                .font(.title3)
                                .fontWeight(.heavy)
                                .foregroundColor(.black)
                            Spacer()

                            Button {
                                // 取引かごに追加するボタン
                                // タップするたびに、値段合計、個数、カート内アイテム要素にプラスする
                                guard let newActionIndex = itemVM.items.firstIndex(where: { $0 == itemRow }) else {
                                    print("アクションIndexの取得に失敗しました")
                                    return
                                }
                                inputStock.actionRowIndex = newActionIndex
                                cartResults.resultItemAmount += 1

                                // カート内に対象アイテムがなければ、カートに要素を新規追加
                                if cartResults.resultCartItems.filter({ $0 == itemRow }) == [] {
                                    cartResults.resultCartItems.append(itemRow)
                                }

                                print("resultPrice: \(cartResults.resultPrice)円")
                                print("resultItemAmount: \(cartResults.resultItemAmount)個")

                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.customDarkGray1)
                                    .opacity(countUpDisable ? 0.2 : 1.0)
                            } // Button
                            .offset(x: 5, y: 5)
                            .disabled(countUpDisable)
                        } // HStack
                    } // VStack
                    .padding()
                } // overlay

                .overlay(alignment: .topLeading) {
                    if cardCount > 0 {
                        Text("\(cardCount)").font(.title.bold())
                            .foregroundColor(.black)
                        .shadow(color: .white, radius: 1)
                        .shadow(color: .white, radius: 1)
                        .shadow(color: .white, radius: 1)
                        .offset(y: -15)
                    }
                }

                .overlay(alignment: .topLeading) {
//                    if itemSold {
                        Group {
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(lineWidth: 6)
                                .frame(width: 80, height: 30)
                            Text("SOLD OUT")
                                .font(.footnote)
                                .fontWeight(.black)
                        }
                        .foregroundColor(.customSoldOutTagColor)
                        .offset(x: -12, y: -3)
                        .shadow(radius: 3, x: 5, y: 5)
                        .opacity(soldOpacity)
                        .rotationEffect(Angle(degrees: -30.0))
                        .scaleEffect(itemSold ? 1.0 : 1.9)
                        .animation(Animation.default, value: itemSold)
//                    } // if
                } // .overlay

        } // VStack
        .onChange(of: cartResults.resultItemAmount) { [before = cartResults.resultItemAmount] after in
            if before < after {
                if itemRow == itemVM.items[inputStock.actionRowIndex] {
                    cardCount += 1
                }
            }
            if before > after {
                if itemRow == itemVM.items[inputStock.actionRowIndex] {
                    cardCount -= 1
                }
            }
        } // .onChange

        .onChange(of: cartResults.resultCartItems) { _ in
            if cartResults.resultCartItems == [] { cardCount = 0 }
        }

        .onChange(of: cardCount) { newCardCount in
            if newCardCount == itemRow.inventory {
                if itemRow == itemVM.items[inputStock.actionRowIndex] {
                    countUpDisable = true
                }
            } else {
                if itemRow == itemVM.items[inputStock.actionRowIndex] {
                    countUpDisable = false
                }
            }
        }

        .onChange(of: itemRow.inventory) {newInventory in
            itemSold = newInventory == 0 ? true : false
            soldOpacity = newInventory == 0 ? 1.0 : 0.0
            print("onChange_itemSold: \(itemSold)")
        }

        .onAppear {
            itemSold = itemRow.inventory == 0 ? true : false
            soldOpacity = itemRow.inventory == 0 ? 1.0 : 0.0
            print("onAppear_itemSold: \(itemSold)")
        }

    } // body
} // View

struct ItemCardRow_Previews: PreviewProvider {
    static var previews: some View {

        ItemCardRow(itemVM: ItemViewModel(),
                    inputStock: .constant(InputStock()),
                    cartResults: .constant(CartResults()),
                    itemRow: TestItem().testItem)
        .previewLayout(.sizeThatFits)
    }
}
