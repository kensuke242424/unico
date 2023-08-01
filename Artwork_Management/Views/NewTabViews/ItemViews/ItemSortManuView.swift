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

    let menuWidth: CGFloat = 220
    let menuHeight: CGFloat = 350
    let buttonSize: CGFloat = 60
    let userColor: ThemeColor

    /// View properties
    @State private var isOpen: Bool = false
    @Namespace private var animation

    var body: some View {

        Color.clear
            .allowsHitTesting(true)
            .onTapGesture {
                print("タップを検知")
            }
            .overlay(alignment: .bottomTrailing) {
                if isOpen {
                    userColor.color2.opacity(0.8)
                        .background(BlurView(style: .systemUltraThinMaterial))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .matchedGeometryEffect(id: "MENU", in: animation)
                        .transition(.scale)
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
}

struct SortItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemSortManuView(userColor: .gray)
    }
}
