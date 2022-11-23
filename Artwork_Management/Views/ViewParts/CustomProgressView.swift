//
//  ProgressView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/19.
//

import SwiftUI

struct CustomProgressView: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(colorScheme == ColorScheme.light ? .white : .black)
                .opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 30) {
                ProgressView()
                BounceAnimationView(text: "Loading...", startTime: 0.4)
            }
        }
    }
}

struct CustomProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CustomProgressView()
    }
}
