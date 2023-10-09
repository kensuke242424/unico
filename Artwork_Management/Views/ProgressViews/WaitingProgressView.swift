//
//  SavingProgressView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/20.
//

import SwiftUI

/// 何らかの処理中であることをユーザーに伝え、操作を待ってもらうために表示するマスクビュー。
struct WaitingProgressView: View {
    let text: String

    var body: some View {
        VStack(spacing: 20) {
            
            Text(text)
                .foregroundColor(.white)
                .tracking(3)
                .padding()

            LoadingIndicatorView(isLoading: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Rectangle()
                .fill(.black.opacity(0.6))
                .ignoresSafeArea()
        }
    }
}

struct SavingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingProgressView(text: "保存しています...")
    }
}
