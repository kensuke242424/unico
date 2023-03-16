//
//  HomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

struct NewHomeView: View {
    
    @State private var inputTime = InputTime()
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
                TimeView(size)
                
            } // VStack
            .frame(width: size.width, height: size.height)
        }
        .ignoresSafeArea()
    }
    
    // 🕛時刻のレイアウト
    // HStack+Spacerを入れておかないと秒数によって微妙に時計が動いてしまう🤔
    func TimeView(_ size: CGSize) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                
                Text(inputTime.time)
                    .italic()
                    .tracking(8)
                    .font(.title2.bold())
                    .padding(.bottom)
                    .opacity(0.8)
                
                Text(inputTime.week)
                    .italic()
                    .tracking(5)
                    .font(.title3)
                    .opacity(0.8)
                
                Text(inputTime.dateStyle)
                    .font(.title3)
                    .italic()
                    .tracking(5)
                    .padding(.leading)
                    .opacity(0.8)
            } // VStack
            .onReceive(inputTime.timer) { _ in
                inputTime.nowDate = Date()
            }
            Spacer()
        } // HStack
        .frame(maxWidth: .infinity)
        .shadow(radius: 4, x: 3, y: 3)
        .shadow(radius: 4, x: 3, y: 3)
        .padding(.trailing, size.width / 2)
        .padding(.leading, 15)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NewHomeView()
            .background {
                Image("background_1")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
    }
}
