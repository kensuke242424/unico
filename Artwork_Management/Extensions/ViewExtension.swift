//
//  ViewExtension.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/03.
//

import SwiftUI

extension View {

    /// ユーザーが使用しているデバイスのサイズ感を取得するメソッド。
    /// UIScreen.main.bounds.heightがiPhoneSEの縦幅（667）より小さい場合、.smallとする。
    /// それよりも大きい場合、.mediumとする。
    func getDeviseSize() -> DeviseSize {
        if UIScreen.main.bounds.height <= 667 {
            return .small
        } else {
            return .medium
        }
    }

    func getSafeArea() -> UIEdgeInsets {

        guard let screen =
                UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        return safeArea
    }

    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
    
    func customBackButton() -> some View {
        self.modifier(CustomBackButton())
    }

    func customNavigationTitle(title: String) -> some View {
        self.modifier(CustomNavigationTitle(title: title))
    }
    
    func customSystemBackground() -> some View {
        self
            .background {
                Color.userBlue1
                    .ignoresSafeArea()
            }
    }
}

/// ユーザーが使用しているデバイスのサイズを表す。
/// iPhoneSEの縦幅（667）より小さい場合、smallとする。
enum DeviseSize {
    case small, medium
}
