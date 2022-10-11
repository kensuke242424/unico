//
//  HomeView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI
import ResizableSheet

struct HomeTabView: View {

    @StateObject var rootItemVM = ItemViewModel()

    @State private var tabIndex = 0
    @State private var isShowItemDetail = false
    @State private var isPresentedNewItem = false
    @State var state: ResizableSheetState = .hidden

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

                SalesManageView(itemVM: rootItemVM, isPresentedNewItem: $isPresentedNewItem)
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
            UsefulButton(tabIndex: $tabIndex,
                         isPresentedNewItem: $isPresentedNewItem,
                         state: $state)

        } // ZStack
        .navigationBarBackButtonHidden()
        // NOTE: パッケージResizable_Sheetを用いたハーフモーダル
        .resizableSheet($state) {builder in
            builder.content { _ in
                VStack {
                    HStack {
                        Spacer(minLength: 0)
                        Button(
                            action: { state = .hidden },
                            label: {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                        )
                        .frame(width: 40, height: 40)
                    }
                    .padding()
                    Spacer(minLength: 0).frame(height: 300)
                }
            }
            .sheetBackground { _ in
                Color.white
            }
            .background { _ in

                EmptyView()
            }
//                .supportedState([.medium, .hidden])
        } // .resizableSheet

    } // body
} // View

struct HomeTabView_Previews: PreviewProvider {

    static var previews: some View {

        var windowScene: UIWindowScene? {
                    let scenes = UIApplication.shared.connectedScenes
                    let windowScene = scenes.first as? UIWindowScene
                    return windowScene
                }
        var resizableSheetCenter: ResizableSheetCenter? {
                   windowScene.flatMap(ResizableSheetCenter.resolve(for:))
               }

            return HomeTabView()
            .environment(\.resizableSheetCenter, resizableSheetCenter)

    }
}
