//
//  SortItemView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/01.
//

import SwiftUI

/// アイテムの並び替えメニュー。
/// 画面の右下に位置し、ボタンタップによりメニューが開く。
struct ItemSortManuView: View {

    let menuWidth: CGFloat = 300
    let menuHeight: CGFloat = 490
    let buttonSize: CGFloat = 60
    let userColor: ThemeColor

    /// View properties
    @State private var isOpen: Bool = false
    @Namespace private var animation

    @StateObject var itemVM: ItemViewModel

    var body: some View {

        Color.clear
            .allowsHitTesting(true)
            .overlay(alignment: .bottomTrailing) {
                if isOpen {

                    userColor.color2.opacity(0.8)
                        .transition(.scale)
                        .background(BlurView(style: .systemUltraThinMaterial))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay { SortMenu() }
                        .matchedGeometryEffect(id: "MENU", in: animation)
                        .frame(width: menuWidth, height: menuHeight)

                } else {
                    userColor.color2.opacity(0.8)
                        .background(BlurView(style: .systemUltraThinMaterial))
                        .clipShape(Circle())
                        .matchedGeometryEffect(id: "MENU", in: animation)
                        .transition(.scale)
                        .frame(width: buttonSize, height: buttonSize)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    withAnimation(.spring(response: 0.35)) {
                        isOpen.toggle()
                    }
                } label: {
                    ZStack {
                        Circle() // ダミー
                            .frame(width: buttonSize)
                            .foregroundColor(.clear)
                        Image(systemName: "text.line.first.and.arrowtriangle.forward")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.trailing)
            /// 選択されたソートタイプに合わせてアイテムを並び替え
            .onChange(of: itemVM.selectedSortType) { type in
                switch type {
                case .name:
                    withAnimation(.spring(response: 0.5)) { itemVM.nameSort() }
                case .createTime:
                    withAnimation(.spring(response: 0.5)) { itemVM.createTimeSort() }
                case .updateTime:
                    withAnimation(.spring(response: 0.5)) { itemVM.updateTimeSort() }
                case .sales:
                    withAnimation(.spring(response: 0.5)) { itemVM.updateTimeSort() }
                }
            }
            /// 昇り・降り順の切り替え
            .onChange(of: itemVM.selectedOder) { _ in
                withAnimation(.spring(response: 0.5)) { itemVM.upDownOderSort() }
            }
            /// 初期値として名前の順に並び替え
            .onAppear {
                itemVM.nameSort()
            }
    }
    @ViewBuilder
    func SortMenu() -> some View {
        VStack(alignment: .leading, spacing: 30) {

            VStack(alignment: .leading) {
                Text("並び替え").tracking(7).font(.title2)
                Divider().background(Color.white)
            }

            /// アイテムのソートタイプメニュー
            VStack(alignment: .leading, spacing: 25) {
                ForEach(ItemsSortType.allCases, id: \.self) { sort in
                    HStack(spacing: 20) {
                        Circle().stroke(lineWidth: 1)
                            .frame(width: 15, height: 15)
                            .overlay {
                                Circle()
                                    .frame(width: 8)
                                    .scaleEffect(itemVM.selectedSortType == sort ? 1 : 0)
                            }

                        Text(sort.text).tracking(3)
                    }
                    .onTapGesture {
                        withAnimation {
                            itemVM.selectedSortType = sort
                        }
                    }
                }
            }
            .offset(x: 20)

            Divider().background(Color.white)

            /// 昇順・降り順のメニュー
            HStack(spacing: 30) {
                ForEach(UpDownOrder.allCases, id: \.self) { order in
                    HStack(spacing: 20) {
                        Circle()
                            .stroke(lineWidth: 1)
                            .frame(width: 15, height: 15)
                            .overlay {
                                Circle()
                                    .frame(width: 8)
                                    .scaleEffect(itemVM.selectedOder == order ? 1 : 0)
                            }

                        Text(order.text).tracking(3)
                    }
                    .onTapGesture {
                        withAnimation {
                            itemVM.selectedOder = order
                        }
                    }
                }
            }

            Divider().background(Color.white)

            /// お気に入り絞り込みメニュー
            HStack(spacing: 20) {
                Circle().stroke(lineWidth: 1)
                    .frame(width: 15, height: 15)
                    .overlay {
                        Circle().frame(width: 8)
                            .scaleEffect(itemVM.filterFavorite ? 1 : 0)
                    }

                Text("お気に入りのみ表示").tracking(2)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.5)) {
                    itemVM.filterFavorite.toggle()
                }
            }

            Spacer()
        }
        .foregroundColor(.white)
        .padding(20)
        .padding(.top)
        .opacity(isOpen ? 1 : 0)
    }
}

struct SortItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemSortManuView(userColor: .gray,
                         itemVM: ItemViewModel()
        )
    }
}


