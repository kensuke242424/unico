//
//  HomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

struct NewHomeView: View {
    var body: some View {
        VStack {
            Text("Homeタブです。")
        }
        .navigationTitle("ホーム画面")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NewHomeView()
    }
}
