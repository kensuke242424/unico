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
    @State private var isOpen: Bool = true
    @Namespace private var animation

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
                        Circle()
                            .frame(width: buttonSize)
                            .foregroundColor(.clear)
                        Image(systemName: "text.line.first.and.arrowtriangle.forward")
                            .foregroundColor(.white)
                    }

                }
            }
            .padding(.trailing)
    }
    @ViewBuilder
    func SortMenu() -> some View {
        let sortTypes: [String] = ["名前", "追加日", "更新日", "売り上げ"]
        let orderTypes: [String] = ["昇順", "降り順"]
        VStack(alignment: .leading, spacing: 30) {

            VStack(alignment: .leading) {
                Text("並び替え").tracking(7).font(.title2)
                Divider().background(Color.white)
            }

            VStack(alignment: .leading, spacing: 30) {
                ForEach(sortTypes, id: \.self) { sortType in
                    HStack(spacing: 20) {
                        Circle()
                            .stroke(lineWidth: 1)
                            .frame(width: 15, height: 15)
                            .overlay { Circle().frame(width: 10) }

                        Text("\(sortType)")
                    }
                }
            }
            .tracking(3)
            .offset(x: 20)

            Divider().background(Color.white)

            HStack(spacing: 30) {
                ForEach(orderTypes, id: \.self) { orderType in
                    HStack(spacing: 20) {
                        Circle()
                            .stroke(lineWidth: 1)
                            .frame(width: 15, height: 15)
                            .overlay { Circle().frame(width: 10) }

                        Text("\(orderType)").tracking(3)
                    }
                }
            }

            Divider().background(Color.white)

            HStack(spacing: 20) {
                Circle()
                    .stroke(lineWidth: 1)
                    .frame(width: 15, height: 15)
                    .overlay { Circle().frame(width: 10) }

                Text("お気に入りのみ表示").tracking(2)
            }

            Spacer()
        }
        .foregroundColor(.white)
        .padding(20)
        .padding(.top)
        .opacity(isOpen ? 1 : 0)
    }
    @ViewBuilder
    func CustomDivider(_ color: Color) -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(color)
            .opacity(0.4)
    }
}

struct SortItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemSortManuView(userColor: .gray)
    }
}
