//
//  CustomMagnificationGesture.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/05/31.
//

import SwiftUI

struct CustomMagnificationGesture: ViewModifier {

    @Binding var active: Bool
    @Binding var transition: CGFloat
    @Binding var initial: CGFloat

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(MagnificationGesture()
                .onChanged { transition = $0 }
                .onEnded{ _ in initial = transition }
            )
    }
}

extension View {
    func customMagnificationGesture(active: Binding<Bool>, transition: Binding<CGFloat>, initial: Binding<CGFloat>) -> some View {
        self.modifier(CustomMagnificationGesture(active: active, transition: transition, initial: initial))
    }
}
