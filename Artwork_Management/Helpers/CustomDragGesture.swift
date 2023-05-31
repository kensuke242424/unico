//
//  CustomDragGesture.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/05/31.
//

import SwiftUI

struct CustomDragGesture: ViewModifier {

    @Binding var active: Bool
    @Binding var transition: CGSize
    @Binding var initial: CGSize

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(DragGesture()
                .onChanged {
                    if active {
                        transition = CGSize(
                            width: initial.width + $0.translation.width,
                            height: initial.height + $0.translation.height
                        )
                    }
                }
                .onEnded{ _ in
                    if active {
                        initial = transition
                    }
                }
            )
    }
}

extension View {
    func customDragGesture(active: Binding<Bool>, transition: Binding<CGSize>, initial: Binding<CGSize>) -> some View {
        self.modifier(CustomDragGesture(active: active, transition: transition, initial: initial))
    }
}
