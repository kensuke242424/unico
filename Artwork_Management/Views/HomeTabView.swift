//
//  HomeView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct HomeTabView: View {

    @StateObject var rootItemVM = ItemViewModel()

    struct InputHomeTab {
        var tabIndex: Int = 0
        var isShowItemDetail: Bool = false
        var isPresentedEditItem: Bool = false

    }
    @State private var input: InputHomeTab = InputHomeTab()

    var body: some View {

        ZStack {
            TabView(selection: $input.tabIndex) {

                LibraryView(itemVM: rootItemVM, isShowItemDetail: $input.isShowItemDetail)
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

                ManageView(itemVM: rootItemVM, isPresentedEditItem: $input.isPresentedEditItem)
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
            UsefulButton(tabIndex: $input.tabIndex,
                         isPresentedEditItem: $input.isPresentedEditItem)

        } // ZStack
        .navigationBarBackButtonHidden()
    } // body
} // View

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()

    }
}
