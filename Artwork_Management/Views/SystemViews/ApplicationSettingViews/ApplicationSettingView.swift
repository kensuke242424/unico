//
//  ApplicationSettingView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/05/26.
//

import SwiftUI

struct ApplicationSettingView: View {
    @State private var toggle: Bool = false
    var body: some View {
        VStack {
            Toggle("ダークモード", isOn: $toggle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationTitle(title: "アプリ設定")
        .customSystemBackground()
        .customBackButton()
    }
}

struct ApplicationSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationSettingView()
    }
}
