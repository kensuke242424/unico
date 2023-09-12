//
//  SortItemView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/01.
//

import SwiftUI

/// アイテムの並び替えメニュー。非表示時はボタン型。
/// 画面の右下に位置し、ボタンタップによりメニューが開く。
struct ItemSortManuView: View {

    let menuWidth: CGFloat = 300
    let menuHeight: CGFloat = 490
    let buttonSize: CGFloat = 60
    let userColor: ThemeColor

    /// View properties
    @State private var isOpen: Bool = false
    @GestureState var dragOffset:CGSize = .zero
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
                        .shadow(radius: 2, x: 2, y: 2)
                        .offset(x: dragOffset.width, y: dragOffset.height)
                        .gesture(
                            DragGesture()
                                .updating(self.$dragOffset, body: { (value, state, _) in
                                    state = CGSize(width: value.translation.width / 3,
                                                   height: value.translation.height / 3)
                                })
                                .onEnded { value in
                                    if value.translation.height > 100 {
                                        withAnimation(.spring(response: 0.4, blendDuration: 1)) {
                                            isOpen = false
                                        }
                                    }
                                }
                        )
                        .animation(.interpolatingSpring(mass           : 0.8,
                                                        stiffness      : 100,
                                                        damping        : 80,
                                                        initialVelocity: 0.1),
                                                        value          : dragOffset)

                } else {
                    userColor.color2.opacity(0.8)
                        .transition(.scale)
                        .background(BlurView(style: .systemUltraThinMaterial))
                        .clipShape(Circle())
                        .matchedGeometryEffect(id: "MENU", in: animation)
                        .frame(width: buttonSize, height: buttonSize)
                        .shadow(radius: 2, x: 2, y: 2)
                }
            }
            /// ソートメニューの表示を管理するボタン
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
                        Image(systemName: isOpen ? "list.bullet.indent" : "list.triangle")
                            .font(isOpen ? .title2 : .title3)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding([.bottom, .trailing])
            /// 選択されたソートタイプに合わせてアイテムを並び替え
            .onChange(of: itemVM.selectedSortType) { type in
                withAnimation(.spring(response: 0.5)) {
                    itemVM.selectedTypesSort()
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
        VStack(alignment: .leading, spacing: 25) {

            VStack(alignment: .leading) {
                Text("並び替え").tracking(7).font(.title2)
                Divider().background(Color.white)
            }

            /// アイテムのソートタイプメニュー
            VStack(alignment: .leading, spacing: 15) {
                ForEach(ItemsSortType.allCases, id: \.self) { sort in
                    HStack(spacing: 20) {
                        Circle().stroke(lineWidth: 1)
                            .frame(width: 15, height: 15)
                            .overlay {
                                Circle()
                                    .frame(width: 8)
                                    .scaleEffect(itemVM.selectedSortType == sort ? 1 : 0.01)
                            }

                        Text(sort.text).tracking(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(5)
                    .background {
                        Capsule()
                            .foregroundColor(userColor.color1)
                            .opacity(itemVM.selectedSortType == sort ? 0.4 : 0.01)
                            .shadow(radius: 5, x: 2, y: 2)
                    }
                    .onTapGesture {
                        withAnimation {
                            itemVM.selectedSortType = sort
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

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
                                    // MEMO: スケール値0だとコンソールに警告が出るため、ほんの少し値を残してる
                                    .scaleEffect(itemVM.selectedOder == order ? 1 : 0.01)
                            }

                        Text(order.text).tracking(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(5)
                    .background {
                        Capsule(style: .continuous)
                            .foregroundColor(userColor.color1)
                            .opacity(itemVM.selectedOder == order ? 0.4 : 0.01)
                            .shadow(radius: 5, x: 2, y: 2)
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
                            .scaleEffect(itemVM.filteringFavorite ? 1 : 0.01)
                    }

                Text("お気に入りのみ表示").tracking(2)
            }
            .padding(7)
            .background {
                Capsule()
                    .foregroundColor(userColor.color1)
                    .opacity(itemVM.filteringFavorite ? 0.4 : 0.01)
                    .shadow(radius: 5, x: 2, y: 2)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.5)) {
                    itemVM.filteringFavorite.toggle()
                }
            }

            Spacer()
        }
        .foregroundColor(.white)
        .padding(20)
        .padding(.top)
    }
}

struct SortItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemSortManuView(userColor: .blue,
                         itemVM: ItemViewModel()
        )
    }
}


