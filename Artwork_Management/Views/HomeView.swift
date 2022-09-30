//
//  HomeView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct HomeView: View {

    @State var isShowItemDetail = false
    @State private var tabIndex = 0

    var body: some View {

        TabView(selection: $tabIndex) {

            LibraryView(isShowItemDetail: $isShowItemDetail)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)

            ItemStockView()
                .tabItem {
                    Image(systemName: "shippingbox.fill")
                    Text("inventory")
                }
                .tag(1)

            SalesManageView(tabIndex: $tabIndex)
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Manage")
                }
                .tag(2)

            SystemView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("System")
                }
                .badge("!")
                .tag(3)

        } // TabViewここまで
    } // body
} // View

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {

        HomeView()
    }
}
