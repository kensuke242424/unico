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

            Image(systemName: "cube.transparent")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white.opacity(0.7))
                .opacity(0.7)
                .frame(width: 150, height: 150)
                .padding()

            Text("unico")
                .tracking(25)
                .font(.title3)
                .foregroundColor(.white.opacity(0.6))
                .opacity(0.6)
                .fontWeight(.heavy)
                .offset(x: 10)
        } // VStack
    } // body
} // View

struct LargeLogoMark: View {
    var body: some View {

        VStack {

            Image(systemName: "cube.transparent")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white.opacity(0.7))
                .opacity(0.7)
                .frame(width: 150, height: 150)
                .padding()

            Text("unico")
                .tracking(25)
                .font(.title3)
                .foregroundColor(.white.opacity(0.6))
                .opacity(0.6)
                .fontWeight(.heavy)
                .offset(x: 10)
        } // VStack
    } // body
} // View

struct LogoMark_Previews: PreviewProvider {
    static var previews: some View {
        LogoMark()
    }
}
