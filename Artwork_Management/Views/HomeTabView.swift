//
//  HomeView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct HomeTabView: View {

    @State private var tabIndex = 0
    @State private var isShowItemDetail = false

    var body: some View {

        ZStack {
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

                SalesManageView()
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

            UsefulButtonView()
//            Button {
//                //
//            } label: {
//                Circle()
//                    .foregroundColor(.white)
//                    .frame(width: 78)
//                    .blur(radius: 2)
//                    .shadow(radius: 5, x:7, y: 15)
//                    .overlay {
//                        Image(systemName: "shippingbox.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 40, height: 40)
//                            .shadow(radius: 10, x: 3, y: 5)
//                            .overlay(alignment: .topTrailing) {
//                                Image(systemName: "plus.circle.fill")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 20, height: 20)
//                                    .offset(x: 10, y: -10)
//                            }
//                    } // overlay
//            } // Button
//            .offset(x: UIScreen.main.bounds.width / 3 - 5,
//                    y: UIScreen.main.bounds.height / 3 - 20)
        } // ZStack
        .navigationBarBackButtonHidden()
    } // body
} // View

struct UsefulButtonView: View {
    var body: some View {
        Button {
            //
        } label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 78)
                .blur(radius: 2)
                .shadow(radius: 5, x: 7, y: 15)
                .overlay {
                    Image(systemName: "shippingbox.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .shadow(radius: 10, x: 3, y: 5)
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .offset(x: 10, y: -10)
                        }
                } // overlay
        } // Button
        .offset(x: UIScreen.main.bounds.width / 3 - 5,
                y: UIScreen.main.bounds.height / 3 - 20)
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
            HomeTabView()

    }
}
