//
//  Version10.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/28.
//
// TODO: リリース直前に構築

import SwiftUI

struct Version10: View {
    let varsion: String
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.white)
        .customSystemBackground()
        .customBackButton()
        .customNavigationTitle(title: varsion)
    }
}

struct Version10_Previews: PreviewProvider {
    static var previews: some View {
        Version10(varsion: "var 1.0")
    }
}
