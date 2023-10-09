//
//  LoadingIndicatorView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/10/09.
//

import SwiftUI

/// ローディング中やセーブ中に表示されるプログレス画面で使われる
/// サークルアニメーションビュー。
struct LoadingIndicatorView: View {
    let isLoading: Bool
    @State private var isAnimating = false
    private let animation = Animation.linear(duration: 1).repeatForever(autoreverses: false)

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.6)
                .stroke(AngularGradient(gradient: Gradient(colors: [.gray, .white]), center: .center),
                        style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round,
                            dash: [0.1, 16],
                            dashPhase: 8))
                .frame(width: 48, height: 48)
                .rotationEffect(.degrees(self.isAnimating ? 360 : 0))
            // ②アニメーションの実装
                .onAppear() {
                    withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                        self.isAnimating = true
                    }
                }
                .onDisappear() {
                    self.isAnimating = false
                }
        }
    }
}

#Preview {
    LoadingIndicatorView(isLoading: true)
}
