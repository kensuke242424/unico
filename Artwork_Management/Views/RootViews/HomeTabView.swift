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
    @State private var isShowItemDetail: Bool = false
    @State private var isPresentedNewItem: Bool = false
    @State private var isShowSearchField: Bool = false
    @State var basketState: ResizableSheetState = .hidden
    @State var commerceState: ResizableSheetState = .hidden

    var body: some View {

        ZStack {

            TabView(selection: $tabIndex) {

                LibraryView(itemVM: rootItemVM, isShowItemDetail: $isShowItemDetail)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                ItemStockView(itemVM: rootItemVM,
                              isShowSearchField: $isShowSearchField,
                              basketState: $basketState,
                              commerceState: $commerceState)
                    .tabItem {
                        Image(systemName: "shippingbox.fill")
                        Text("inventory")
                    }
                    .tag(1)

                ManageView(itemVM: rootItemVM, isPresentedEditItem: $isPresentedNewItem)
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
                         isShowSearchField: $isShowSearchField,
                         basketState: $basketState,
                         commerceState: $commerceState)

        } // ZStack
        .navigationBarBackButtonHidden()
        .onChange(of: tabIndex) { newTabIndex in

            // ストック画面でのみ、"ALL"タグを追加
            if newTabIndex == 1 {
                rootItemVM.tags.insert(Tag(tagName: "ALL", tagColor: .gray), at: 0)
                print(rootItemVM.tags)
            } else {
                rootItemVM.tags.removeAll(where: {$0.tagName == "ALL"})
                print(rootItemVM.tags)
            }
        }
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
