//
//  ViewExtension.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/03.
//

import SwiftUI

extension View {

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
}
