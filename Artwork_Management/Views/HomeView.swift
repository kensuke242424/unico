//
//  HomeView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct HomeView: View {

    @State private var tabIndex = 0

    var body: some View {

        TabView(selection: $tabIndex) {

            LibraryView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            ItemStockView()
                .tabItem {
                    Image(systemName: "shippingbox.fill")
                    Text("inventory")
                }

            SalesView()
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Manage")
                }

            AccountView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Account")
                }.badge("!")

        } // TabViewここまで

    } // body
} // View

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .previewDevice("iPhone 14 Pro")
                .previewDisplayName("iPhone 14 Pro")
            HomeView()
                .previewDevice("iPhone 12 Pro Max")
                .previewDisplayName("My iPhone 12 ProMax")
        }
    }
}
