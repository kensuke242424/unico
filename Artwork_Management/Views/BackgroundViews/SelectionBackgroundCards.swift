//
//  SelectionBackgroundCards.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/07/12.
//

import SwiftUI

/// 背景選択に用いるカード状で並べられた背景画像ビュー
struct SelectionBackgroundCards: View {

    @EnvironmentObject var backgroundVM: BackgroundViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Binding var showPicker: Bool

    /// 背景写真カードのサイズ。iPhoneSE以下のサイズの場合、返却するサイズ値を小さくする。
    var imageCardSize: CGSize {
        let defaultHeight: CGFloat = 220
        let defaultWidth: CGFloat = 110
        return CGSize(width: userDeviseSize == .medium ? defaultWidth : defaultWidth * 0.8,
                      height: userDeviseSize == .medium ? defaultHeight: defaultHeight * 0.8)
    }
    /// 背景写真カードのスクロールビューサイズ。iPhoneSE以下のサイズの場合、返却するサイズ値を小さくする。
    var cardsScrollViewHeight: CGFloat {
        let defaultScrollHeight: CGFloat = 280
        return userDeviseSize == .medium ? defaultScrollHeight : defaultScrollHeight * 0.8
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            LazyHStack(spacing: 30) {
                Spacer().frame(width: 10)

                let currentIndex = userVM.currentJoinsIndex ?? 0

                if backgroundVM.selectCategory == .original {

                    ForEach(userVM.user?.myBackgrounds ??
                            backgroundVM.pickMyBackgroundsAtSignUp, id: \.self) { background in
                        BackgroundCardView(background)
                            /// オリジナル背景画像のみ、削除が可能
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    // オリジナル背景削除
                                    backgroundVM.deleteTarget = background
                                    backgroundVM.showDeleteAlert.toggle()
                                }
                            }
                            .alert("確認", isPresented: $backgroundVM.showDeleteAlert) {
                                Button("削除", role: .destructive) {
                                    // 一瞬ずらさないとアラートが瞬間だけ再表示されてしまう🧐
                                    guard let deleteTargetImage = backgroundVM.deleteTarget else { return }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        backgroundVM.deleteBackground(path: background.imagePath)
                                        userVM.deleteMyBackground(deleteTargetImage)
                                        if backgroundVM.selectBackground == background {
                                            backgroundVM.selectBackground = nil
                                        }
                                    }
                                }
                                .foregroundColor(.red)
                            } message: {
                                Text("背景を削除しますか？")
                            } // alert
                    }
                    ShowPickerCardView()
                } else {
                    ForEach(backgroundVM.categoryBackgrounds, id: \.self) { background in
                        BackgroundCardView(background)
                    }
                }
                Spacer().frame(width: 40)
            } // LazyHStack
            .frame(height: cardsScrollViewHeight)
        } // ScrollView
    }
    @ViewBuilder
    func ShowPickerCardView() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.gray.gradient)
            .frame(width: imageCardSize.width,
                   height: imageCardSize.height)
            .opacity(0.7)
            .overlay {
                Button {
                    // 写真キャプチャ
                    showPicker.toggle()
                } label: {
                    Image(systemName: "photo.artframe")
                        .resizable().scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 22)
                        .padding(18)
                        .background(
                            Circle()
                                .fill(.blue.gradient)
                                .shadow(radius: 5, x: 2, y: 2)
                        )
                }
            }
    }
    @ViewBuilder
    func BackgroundCardView(_ background: Background) -> some View {
        SDWebImageToItem(imageURL: background.imageURL,
                         width: imageCardSize.width,
                       height: imageCardSize.height)
        .shadow(radius: 5, x: 2, y: 2)
        .shadow(radius: 5, x: 2, y: 2)
        .shadow(radius: 5, x: 2, y: 2)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        /// タップ範囲調整のため、本体の画像タップ判定はfalseにしてこちらで処理する
        .overlay {
            Rectangle()
                .frame(width: imageCardSize.width,
                       height: imageCardSize.height)
                .opacity(0.01)
                .onTapGesture {
                    withAnimation(.spring(response: 0.5)) {
                        backgroundVM.selectBackground = background
                    }
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 1)
                .fill(.gray.gradient)
        }
        .scaleEffect(backgroundVM.selectBackground == background ? 1.15 : 1.0)
        // 選択中の背景に付くバッジ
        .overlay(alignment: .topTrailing) {
            Image(systemName: "circlebadge.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.green)
                .frame(width: userDeviseSize == .small ? 15 : 20,
                       height: userDeviseSize == .small ? 15 : 20)
                .padding(1)
                .background(Circle().fill(.white.gradient))
                .scaleEffect(backgroundVM.selectBackground == background ? 1.0 : 1.15)
                .opacity(backgroundVM.selectBackground == background ? 1.0 : 0.0)
                .offset(x: userDeviseSize == .small ? 10 : 15,
                        y: userDeviseSize == .small ? -15 : -25)
        }
    }

}

