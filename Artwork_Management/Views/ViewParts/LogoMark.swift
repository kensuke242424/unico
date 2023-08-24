//
//  LogoMark.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2023/01/13.
//

import SwiftUI

struct LogoMark: View {
    var body: some View {

        VStack {
            Image("unico_logo_a4")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white.opacity(0.7))
                .opacity(0.9)
                .frame(width: 200, height: 200)
                .padding()
        } // VStack
    } // body
} // View

struct LargeLogoMark: View {
    var body: some View {

        VStack {
            Image("unico_logo_a4")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white.opacity(0.7))
                .opacity(0.9)
                .frame(width: 300, height: 300)
                .padding()
        } // VStack
    } // body
} // View

struct LogoMark_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.userBlue1
            LogoMark()
        }
    }
}
