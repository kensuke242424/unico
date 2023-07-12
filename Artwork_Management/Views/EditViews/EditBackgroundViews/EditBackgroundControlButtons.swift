//
//  EditBackgroundControlButtons.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/07/12.
//

import SwiftUI

/// 背景編集時に用いるトグルボタン。背景確認モードの切り替え、ダークモードの切り替えを管理する。
struct EditBackgroundControlButtons: View {

    @EnvironmentObject var backgroundVM: BackgroundViewModel
    @AppStorage("applicationDarkMode") var applicationDarkMode: Bool = true

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                BlurView(style: .systemThickMaterial)
                    .frame(width: 90, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .opacity(0.8)

                VStack(spacing: 20) {
                    VStack {
                        Text("背景を確認").font(.footnote).offset(x: 15)
                        Toggle("", isOn: $backgroundVM.checkModeToggle)
                    }
                    VStack {
                        Text("ダークモード").font(.footnote).offset(x: 15)
                        Toggle("", isOn: $applicationDarkMode)
                    }
                }
                .frame(width: 80)
                .padding(.trailing, 30)
                .onChange(of: backgroundVM.checkModeToggle) { newValue in
                    if newValue {
                        withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                            backgroundVM.checkMode = true
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                            backgroundVM.checkMode = false
                        }
                    }
                }
            }
        }
    }
}
