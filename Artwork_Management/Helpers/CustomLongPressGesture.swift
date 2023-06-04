//
//  CustomonLongPressGesture.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/04.
//

import SwiftUI

/// Homeパーツのロングタップステートに用いるジェスチャー
struct CustomLongPressGesture: ViewModifier {

    @Binding var pressing: Bool
    @Binding var backState: Bool
    @Binding var perform: Bool

    func body(content: Content) -> some View {
        content
            .onLongPressGesture(
                pressing: { pressing in
                    if pressing {
                        if perform { return }

                        withAnimation(.easeIn(duration: 0.5)) {
                            self.backState = true
                        }
                        withAnimation(.easeIn(duration: 0.8)) {
                            self.pressing = true

                        }
                    } else {
                        withAnimation {
                            self.pressing = false
                            self.backState = false
                        }
                    }
                },
                perform: {
                    hapticErrorNotification()
                    withAnimation(.spring(response: 0.7, blendDuration: 1)) {
                        self.perform = true
                    }
            })
    }
}

extension View {
    func customLongPressGesture(pressing: Binding<Bool>, backState: Binding<Bool>, perform: Binding<Bool>) -> some View {
        self.modifier(CustomLongPressGesture(pressing: pressing, backState: backState, perform: perform))
    }
}

