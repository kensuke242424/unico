//
//  customNavigationTitle.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/05/22.
//

import SwiftUI

struct CustomNavigationTitle: ViewModifier {

    let title: String

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
    }
}
