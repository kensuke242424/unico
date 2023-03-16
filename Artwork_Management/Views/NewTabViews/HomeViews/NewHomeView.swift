//
//  HomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

struct NewHomeView: View {
    var body: some View {
        GeometryReader {
            let size = $0.size
            VStack {
                Text("")
            }
            .frame(width: size.width, height: size.height)
        }
        .ignoresSafeArea()
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NewHomeView()
    }
}
