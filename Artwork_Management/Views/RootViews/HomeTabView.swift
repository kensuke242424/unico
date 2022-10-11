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
                         state: $basketState)

        } // ZStack
        .navigationBarBackButtonHidden()

        // Todo: 買い物かごシート
        .resizableSheet($basketState, id: "A") {builder in
            builder.content { _ in
                VStack {
                    GrabBar().opacity(0.7)
                    HStack {
                        Text("カート内のアイテム")
                            .font(.headline)
                            .fontWeight(.black)
                        Spacer()
                        Button(
                            action: { commerceState = .medium },
                            label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("全て削除")
                                        .font(.callout)
                                }
                            }
                        ) // Button
                    } // HStack
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)

                    Divider()
                        .background(.black)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 20)

                    BasketItems(basketItems: $rootItemVM.items)

                    Spacer(minLength: 0).frame(height: 110)
                } // VStack
            } // builder.content
            .sheetBackground { _ in
                Color.white
            }
            .background { _ in
                EmptyView()
            }
        } // .resizableSheet

        // Todo: 決済シート
        .resizableSheet($commerceState, id: "B") {builder in
            builder.content { _ in
                VStack {
                    HStack {
                        Spacer(minLength: 0)
                        Button(
                            action: { commerceState = .hidden },
                            label: {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                        )
                        .frame(width: 40, height: 40)
                    }
                    .padding()
                    Spacer(minLength: 0).frame(height: 30)
                }
            }
            .supportedState([.hidden, .medium])
            .sheetBackground { _ in
                Color.white
            }
            .background { _ in
                EmptyView()
            }
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
