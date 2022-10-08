//
//  HomeView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct HomeTabView: View {

    @StateObject var rootItemVM = ItemViewModel()

    @State private var tabIndex = 0
    @State private var isShowItemDetail = false
    @State private var isPresentedEditItem = false

    var body: some View {

        ZStack {
            TabView(selection: $tabIndex) {

                LibraryView(itemVM: rootItemVM, isShowItemDetail: $isShowItemDetail)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                ItemStockView(itemVM: rootItemVM)
                    .tabItem {
                        Image(systemName: "shippingbox.fill")
                        Text("inventory")
                    }
                    .tag(1)

                SalesManageView(itemVM: rootItemVM, isPresentedEditItem: $isPresentedEditItem)
                    .tabItem {
                        Image(systemName: "chart.xyaxis.line")
                        Text("Manage")
                    }
                    .tag(2)

                SystemView(itemVM: rootItemVM)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("System")
                    }
                    .badge("!")
                    .tag(3)

            } // TabViewここまで

            // Todo: 各タブごとにオプションが変わるボタン
            UsefulButton(tabIndex: $tabIndex, isPresentedEditItem: $isPresentedEditItem)

        } // ZStack
        .navigationBarBackButtonHidden()
    } // body
} // View

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
            HomeTabView()

    }
}
