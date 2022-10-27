//
//  HomeView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI
import ResizableSheet

struct InputHome {
    var tabIndex = 0
    var itemsInfomationOpacity: CGFloat = 0.0
    var basketInfomationOpacity: CGFloat = 0.0
    var isShowItemDetail: Bool = false
    var isPresentedEditItem: Bool = false
    var isShowSearchField: Bool = false
    var doCommerce: Bool = false
    var cartState: ResizableSheetState = .hidden
    var commerceState: ResizableSheetState = .hidden
}

struct HomeTabView: View {

    @StateObject var rootItemVM = ItemViewModel()
    @State private var inputHome: InputHome = InputHome()

    var body: some View {

        ZStack {

            TabView(selection: $inputHome.tabIndex) {

                LibraryView(itemVM: rootItemVM, isShowItemDetail: $inputHome.isShowItemDetail)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                StockView(itemVM: rootItemVM, inputHome: $inputHome)
                    .tabItem {
                        Image(systemName: "shippingbox.fill")
                        Text("inventory")
                    }
                    .tag(1)

                ManageView(itemVM: rootItemVM, isPresentedEditItem: $inputHome.isPresentedEditItem)
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
                    .opacity(inputHome.itemsInfomationOpacity)
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 30)
                    .overlay {
                        Text(inputHome.doCommerce ? "カート内の処理が確定しました。" : "カート内がリセットされました。")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .opacity(inputHome.basketInfomationOpacity)
                Spacer()
            }
            .offset(y: 80)
            .animation(.easeIn(duration: 0.2), value: inputHome.itemsInfomationOpacity)
            .animation(.easeIn(duration: 0.2), value: inputHome.basketInfomationOpacity)

            // Todo: 各タブごとにオプションが変わるボタン
            UsefulButton(inputHome: $inputHome)

        } // ZStack
        .navigationBarBackButtonHidden()
        .onChange(of: inputHome.tabIndex) { newTabIndex in

            // ライブラリ画面、ストック画面でのみ、"ALL"タグを追加
            if newTabIndex == 0 || newTabIndex == 1 {
                if rootItemVM.tags.contains(where: {$0.tagName == "ALL"}) { return }
                rootItemVM.tags.insert(Tag(tagName: "ALL", tagColor: .gray), at: 0)
            }
            if newTabIndex == 2 || newTabIndex == 3 || inputHome.isPresentedEditItem {
                rootItemVM.tags.removeAll(where: {$0.tagName == "ALL"})
                print("ALLを削除")
            }
        } // .onChange

        .onAppear {
            if rootItemVM.tags.contains(where: {$0.tagName == "ALL"}) { return }
            rootItemVM.tags.insert(Tag(tagName: "ALL", tagColor: .gray), at: 0)
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
