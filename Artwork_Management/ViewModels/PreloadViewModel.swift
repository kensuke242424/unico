//
//  PreloadViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

class PreloadViewModel: ObservableObject {
    
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Published var itemVM: ItemViewModel?

    /// 背景画像のプリロード発火を管理するプロパティ
    /// 実際のロードを受け持つSDWebImageはビュー側で定義する
    @Published var preloadBackground = false
    
    @ViewBuilder
    func userCircleIcon(width: CGFloat, height: CGFloat) -> some View  {
        SDWebImageCircleIcon(imageURL: userVM.user?.iconURL,
                             width   : width,
                             height  : height)
    }

    /// チーム背景変更時に、
    /// SDWebImageにキャッシュを作るための画像URLプリロードメソッド
    func startPreloadBackground() {
        self.preloadBackground = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.preloadBackground = false
        }
    }
}
