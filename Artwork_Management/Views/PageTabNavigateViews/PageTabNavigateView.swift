//
//  PageTabNavigateView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/02/24.
//

import SwiftUI

struct PageTabNavigateView: View {
    
    @State private var selection: Int = 0
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                
                Text("page1")
                    .tag(0)
                Text("Page2")
                    .tag(1)
                Text("Page3")
                    .tag(2)
            }
            .tabViewStyle(.page)
        }
        .background(Color.gray)
    }
}

struct PageTabNavigateView_Previews: PreviewProvider {
    static var previews: some View {
        PageTabNavigateView()
    }
}
