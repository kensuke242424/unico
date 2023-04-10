//
//  CustomToggleButton.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/04/10.
//

import SwiftUI

/// 通常のトグルボタンはアニメーションが効かないため、withAnimation適用版のトグルボタンを作った
struct CustomToggleButton: View {
    @Binding var isOn: Bool
    var body: some View {

        ZStack {
            Capsule()
                .fill(isOn ? .green : .gray)
                .frame(width: 50, height: 30)

            Circle()
                .fill(.white)
                .frame(height: 27)
                .shadow(radius: 1, x: 1, y: 1)
                .shadow(radius: 1, x: 1, y: 1)
                .offset(x: isOn ? 10 : -10)
                .onTapGesture {
                    withAnimation {
                        isOn.toggle()
                    }
                }
        }
    }
}

struct CustomToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomToggleButton(isOn: .constant(true))
    }
}
