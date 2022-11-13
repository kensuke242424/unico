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
    @Binding var inputHome: InputHome
    @Binding var inputStock: InputStock
    let itemRow: Item

    private let itemWidth: CGFloat = UIScreen.main.bounds.width / 2 - 30
    private let itemHeight: CGFloat = UIScreen.main.bounds.height / 4

    @State private var cardCount: Int =  0
    @State private var itemSold: Bool = false

    var body: some View {

        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.white)
            .frame(width: itemWidth, height: itemHeight)
            .opacity(colorScheme == .dark ? 0.3 : 0.3)
            .overlay(alignment: .topTrailing) {
                Button {

                    guard let newActionIndex = itemVM.items.firstIndex(where: { $0.id == itemRow.id }) else {
                        print("アクションIndexの取得に失敗しました")
                        return
                    }
                    inputHome.actionItemIndex = newActionIndex
                    withAnimation(.easeIn(duration: 0.15)) {
                        inputHome.isShowItemDetail.toggle()
                    }

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

                    ShowItemPhoto(photo: itemRow.photo, size: itemWidth - 45)

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
                        Text(itemRow.price != 0 ? String(itemRow.price) : "-")
                            .font(.title3)
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                        Spacer()

                        Button {
                            // 取引かごに追加するボタン
                            // タップするたびに、値段合計、個数、カート内アイテム要素にプラスする
                            guard let newActionIndex = itemVM.items.firstIndex(where: { $0.id == itemRow.id }) else {
                                print("アクションIndexの取得に失敗しました")
                                return
                            }

                            inputHome.actionItemIndex = newActionIndex
                            itemVM.items[newActionIndex].amount += 1
                            inputStock.resultCartAmount += 1
                            inputStock.resultCartPrice += itemRow.price

                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.customDarkGray1)
                                .opacity(itemRow.inventory == itemRow.amount ? 0.2 : 1.0)
                        } // Button
                        .offset(x: 5, y: 5)
                        .disabled(itemRow.inventory == 0 || itemRow.amount == itemRow.inventory ? true : false)
                    } // HStack
                } // VStack
                .padding()
            } // overlay

            .overlay(alignment: .topLeading) {
                if itemRow.amount > 0 {
                    Text("\(itemRow.amount)").font(.title.bold())
                        .foregroundColor(.black)
                        .shadow(color: .white, radius: 1)
                        .shadow(color: .white, radius: 1)
                        .shadow(color: .white, radius: 1)
                        .offset(y: -15)
                }
            }

            .overlay(alignment: .topLeading) {
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
                .opacity(itemRow.inventory == 0 ? 1.0 : 0.0)
                .rotationEffect(Angle(degrees: -30.0))
                .scaleEffect(itemRow.inventory == 0 ? 1.0 : 1.9)
            } // .overlay

    } // body
} // View

struct ItemCardRow_Previews: PreviewProvider {
    static var previews: some View {

        ItemCardRow(itemVM: ItemViewModel(),
                    inputHome: .constant(InputHome()),
                    inputStock: .constant(InputStock()),
                    itemRow: TestItem().testItem)
        .previewLayout(.sizeThatFits)
    }
}
