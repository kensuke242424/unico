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

    struct InputHomeTab {
        var tabIndex = 0
        var itemsInfomationOpacity: CGFloat = 0.0
        var basketInfomationOpacity: CGFloat = 0.0
        var isShowItemDetail: Bool = false
        var isPresentedNewItem: Bool = false
        var isShowSearchField: Bool = false
        var doCommerce: Bool = false
        var basketState: ResizableSheetState = .hidden
        var commerceState: ResizableSheetState = .hidden
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

                ItemStockView(itemVM: rootItemVM,
                              itemsInfomationOpacity: $input.itemsInfomationOpacity,
                              basketInfomationOpacity: $input.basketInfomationOpacity,
                              isShowSearchField: $input.isShowSearchField,
                              doCommerce: $input.doCommerce,
                              basketState: $input.basketState,
                              commerceState: $input.commerceState)
                    .tabItem {
                        Image(systemName: "shippingbox.fill")
                        Text("inventory")
                    }
                    .tag(1)

                ManageView(itemVM: rootItemVM, isPresentedEditItem: $input.isPresentedNewItem)
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

            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 30)
                    .overlay {
                        Text("アイテム情報が更新されました。")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .opacity(input.itemsInfomationOpacity)
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 30)
                    .overlay {
                        Text(input.doCommerce ? "カート内の処理が確定しました。" : "カート内がリセットされました。")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .opacity(input.basketInfomationOpacity)
                Spacer()
            }
            .offset(y: 80)
            .animation(.easeIn(duration: 0.2), value: input.itemsInfomationOpacity)
            .animation(.easeIn(duration: 0.2), value: input.basketInfomationOpacity)

            // Todo: 各タブごとにオプションが変わるボタン
            UsefulButton(tabIndex: $input.tabIndex,
                         isPresentedNewItem: $input.isPresentedNewItem,
                         isShowSearchField: $input.isShowSearchField,
                         basketState: $input.basketState,
                         commerceState: $input.commerceState)

        } // ZStack
        .navigationBarBackButtonHidden()
        .onChange(of: input.tabIndex) { newTabIndex in

            // ストック画面でのみ、"ALL"タグを追加
            if newTabIndex == 1 {
                rootItemVM.tags.insert(Tag(tagName: "ALL", tagColor: .gray), at: 0)
            } else {
                rootItemVM.tags.removeAll(where: {$0.tagName == "ALL"})
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
