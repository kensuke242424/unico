//
//  ItemStockControlView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI
import ResizableSheet

struct ItemStockView: View {

    @Environment(\.colorScheme) var colorScheme

    @StateObject var itemVM: ItemViewModel
    @Binding var itemsInfomationOpacity: CGFloat
    @Binding var basketInfomationOpacity: CGFloat
    @Binding var isShowSearchField: Bool
    @Binding var isPresentedEditItem: Bool
    @Binding var doCommerce: Bool
    @Binding var basketState: ResizableSheetState
    @Binding var commerceState: ResizableSheetState

    @FocusState var searchFocused: SearchFocus?
    @GestureState private var dragOffset: CGFloat = 0

    struct InputStock {

        var searchItemNameText: String = "ALL"
        var currentIndex: Int = 0
        var actionRowIndex: Int = 0
        var resultPrice: Int = 0
        var resultItemAmount: Int = 0
        var resultBasketItems: [Item] = []
        var sideTagOpacity: CGFloat = 0.4
        var isShowItemDetail: Bool = false
        var isShowUpdateDataInfomation: Bool = false
        var isShowUpdateBasketInfomation: Bool = false
        var mode: Mode = .dark
    }
    @State private var input: InputStock = InputStock()

    var body: some View {
        NavigationView {

            ScrollViewReader { scrollProxy in
                ZStack {
                    VStack {
                        // NOTE: 検索ボックスの表示管理
                        if isShowSearchField {
                            TextField("キーワード検索", text: $input.searchItemNameText)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .focused($searchFocused, equals: .check)
                                .padding(.horizontal)
                        }

                        // NOTE: Geometryを用いたサイドタグセレクトバー
                        GeometryReader { bodyView in

                            let sideBarTagItemPadding: CGFloat = 80

                            LazyHStack(spacing: sideBarTagItemPadding) {

                                ForEach(itemVM.tags.indices, id: \.self) {index in

                                    Text(itemVM.tags[index].tagName)
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .bold))
                                        .frame(width: bodyView.size.width * 0.7, height: 40)
                                        .padding(.leading, index == 0 ? bodyView.size.width * 0.1 : 0)

                                } // ForEach
                            } // LazyHStack
                            .padding()
                            .offset(x: self.dragOffset)
                            .offset(x: -CGFloat(input.currentIndex) * (bodyView.size.width * 0.7 + sideBarTagItemPadding))

                            .gesture(
                                DragGesture()
                                    .updating(self.$dragOffset, body: { (value, state, _) in

                                        // 先頭・末尾ではスクロールする必要がないので、画面幅の1/5までドラッグで制御する
                                        if input.currentIndex == 0, value.translation.width > 0 {
                                            state = value.translation.width / 5
                                        } else if input.currentIndex == (itemVM.tags.count - 1), value.translation.width < 0 {
                                            state = value.translation.width / 5
                                        } else {
                                            state = value.translation.width
                                        }
                                    })
                                    .onEnded({ value in
                                        var newIndex = input.currentIndex

                                        // ドラッグ幅からページングを判定
                                        // 今回は画面幅x0.3としているが、操作感に応じてカスタマイズする必要がある
                                        if abs(value.translation.width) > bodyView.size.width * 0.2 {
                                            newIndex = value.translation.width > 0 ? input.currentIndex - 1 : input.currentIndex + 1
                                        }
                                        if newIndex < 0 {
                                            newIndex = 0
                                        } else if newIndex > (itemVM.tags.count - 1) {
                                            newIndex = itemVM.tags.count - 1
                                        }
                                        input.currentIndex = newIndex
                                        if input.currentIndex != 0 { isShowSearchField = false }
                                    }) // .onEnded
                            ) // .gesture
                            // 減衰ばねモデル、それぞれの値は操作感に応じて変更する
                            .animation(.interpolatingSpring(mass: 0.4,
                                                            stiffness: 100,
                                                            damping: 80,
                                                            initialVelocity: 0.1),
                                       value: dragOffset)
                        } // Geometry
                        .frame(height: 40) // Geometry範囲のflame

                        // NOTE: サイドタグバーの枠フレームおよび、前後のタグインフォメーションを表示します。
                        .overlay {
                            SideTagBarOverlay(currentIndex: $input.currentIndex,
                                              sideTagOpacity: $input.sideTagOpacity,
                                              tags: $itemVM.tags)
                        } // overlay
                        .padding(.top)

                        // NOTE: サイドタグバー両端のタグインフォメーションopacityを、ドラッグ位置を監視して管理しています。
                        .onChange(of: dragOffset) { newValue in
                            if newValue == 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    input.sideTagOpacity = 0.4
                                }
                            } else {
                                input.sideTagOpacity = 0.0
                            }
                        } // onChange

                        // NOTE: アイテム要素全体のロケーション
                        ScrollView {
                            TagTitle(title: "最近更新したアイテム", font: .title3)
                                .foregroundColor(.white)
                                .opacity(0.8)
                                .padding(.top)

                            Divider()
                                .background(.gray)
                                .padding()
                            // ✅カスタムView: 最近更新したアイテムをHStack表示します。(横スクロール)
                            UpdateTimeSortCards(itemVM: itemVM,
                                                isShowItemDetail: $input.isShowItemDetail,
                                                actionRowIndex: $input.actionRowIndex,
                                                resultPrice: $input.resultPrice,
                                                resultItemAmount: $input.resultItemAmount,
                                                resultBasketItems: $input.resultBasketItems,
                                                itemWidth: UIScreen.main.bounds.width * 0.41,
                                                itemHeight: 205,
                                                itemSpase: 20,
                                                itemNameTag: "アイテム",
                                                items: itemVM.items)
                            Divider()
                                .background(.gray)
                                .padding()

                            HStack(spacing: 50) {
                                Text(input.currentIndex == 0 ?
                                         "- \(input.searchItemNameText) -" :
                                        "-  \(itemVM.tags[input.currentIndex].tagName) -")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .shadow(radius: 3, x: 4, y: 6)
                                .lineLimit(1)
                                .opacity(0.8)

                                if !input.searchItemNameText.isEmpty,
                                   input.searchItemNameText != "ALL" {
                                    Button {
                                        input.searchItemNameText = "ALL"
                                        itemVM.tags[0].tagName = "ALL"
                                    } label: {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.gray)
                                            .frame(width: 40)
                                            .overlay {
                                                Image(systemName: "trash.fill")
                                                    .foregroundColor(.white)
                                            }
                                    } // Button
                                    .opacity(0.3)
                                }
                                Spacer()
                            } // HStack
                            .id("search")
                            .padding()

                            // ✅カスタムView: アイテムを表示します。(縦スクロール)
                            TagSortCards(itemVM: itemVM,
                                         searchItemNameText: $input.searchItemNameText,
                                         actionRowIndex: $input.actionRowIndex,
                                         resultPrice: $input.resultPrice,
                                         resultItemAmount: $input.resultItemAmount,
                                         isShowItemDetail: $input.isShowItemDetail,
                                         resultBasketItems: $input.resultBasketItems,
                                         itemWidth: UIScreen.main.bounds.width * 0.43,
                                         itemHeight: 210,
                                         itemSpase: 20,
                                         selectTag: itemVM.tags[input.currentIndex].tagName,
                                         items: itemVM.items)
                        } // ScrollView (アイテムロケーション)

                    } // VStack
                    // NOTE: アイテム詳細ボタンをタップすると、詳細画面が発火します。
                    if input.isShowItemDetail {
                        ShowsItemDetail(itemVM: itemVM,
                                        item: itemVM.items[input.actionRowIndex],
                                        itemIndex: input.actionRowIndex,
                                        isShowitemDetail: $input.isShowItemDetail)
                    } // if isShowItemDetail
                } // ZStack

                // NOTE: バスケット内にアイテムが追加された時点で、ハーフモーダルを表示します。
                .onChange(of: input.resultBasketItems) { [before = input.resultBasketItems] after in

                    if before.count == 0 {
                        commerceState = .medium
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            basketState = .medium
                        }
                    }
                    if after == [] {
                        commerceState = .hidden
                        basketState = .hidden
                        basketInfomationOpacity = 0.7
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                            basketInfomationOpacity = 0.0
                        }
                    }
                }

                // NOTE: アイテム情報の更新が入った時、カート内にアイテムがあればリセットします。
                .onChange(of: itemVM.items) { _ in

                    input.resultBasketItems = []
                    input.resultItemAmount = 0
                    input.resultPrice = 0

                    itemsInfomationOpacity = 0.7
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                        itemsInfomationOpacity = 0.0
                    }
                } // .onChange

                // NOTE: 入力フィールドの表示に合わせて、フォーカスを切り替えます。
                // NOTE: 入力フィールド表示時に、指定の位置まで自動フォーカスします。
                .onChange(of: isShowSearchField) { newValue in

                    searchFocused = newValue ? .check : nil
                    if newValue == true {
                        if input.searchItemNameText == "ALL" {
                            input.searchItemNameText = ""
                            itemVM.tags[0].tagName = "検索"
                        }
                    }
                    if newValue == false {
                        if input.searchItemNameText == "" {
                            input.searchItemNameText = "ALL"
                            itemVM.tags[0].tagName = "ALL"
                        }
                    }

                    if newValue {
                        withAnimation(.easeIn(duration: 2.0)) {
                            scrollProxy.scrollTo("search", anchor: .top)
                            }
                        withAnimation(.easeIn(duration: 0.3)) {
                            input.currentIndex = 0 // タグを「All」に更新
                        }
                    } // if
                } // .onChange

                .onChange(of: searchFocused) { newFocus in
                    if newFocus == nil {
                        isShowSearchField = false
                    }
                } // .onChange

            } // ScrollViewReader

            .background(LinearGradient(gradient: Gradient(colors: [.customDarkGray1,
                                                                   .customLightGray1]),
                                       startPoint: .top, endPoint: .bottom))
            // アイテム取引かごのシート画面
            .resizableSheet($basketState, id: "A") { builder in
                builder.content { context in

                    VStack {
                        Spacer(minLength: 0)
                        GrabBar()
                            .foregroundColor(.black)
                        Spacer(minLength: 0)

                        HStack(alignment: .bottom) {
                            Text("カート内のアイテム")
                                .foregroundColor(.black)
                                .font(.headline)
                                .fontWeight(.black)
                                .opacity(0.6)
                            Spacer()
                            Button(
                                action: {
                                    input.resultBasketItems = []
                                    input.resultPrice = 0
                                    input.resultItemAmount = 0
                                },
                                label: {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text("全て削除")
                                            .font(.callout)
                                    }
                                    .foregroundColor(.red)
                                }
                            ) // Button
                        } // HStack
                        .padding(.horizontal, 20)

                        Spacer(minLength: 8)

                        ResizableScrollView(
                            context: context,
                            main: {
                                BasketItemsSheet(
                                    itemVM: itemVM,
                                    basketItems: $input.resultBasketItems,
                                    resultItemAmount: $input.resultItemAmount,
                                    resultPrice: $input.resultPrice,
                                    actionRowIndex: $input.actionRowIndex,
                                    doCommerce: $doCommerce,
                                    halfSheetScroll: .main)
                            },
                            additional: {
                                BasketItemsSheet(
                                    itemVM: itemVM,
                                    basketItems: $input.resultBasketItems,
                                    resultItemAmount: $input.resultItemAmount,
                                    resultPrice: $input.resultPrice,
                                    actionRowIndex: $input.actionRowIndex,
                                    doCommerce: $doCommerce,
                                    halfSheetScroll: .additional)

                                Spacer()
                                    .frame(height: 100)
                            }
                        )
                        Spacer()
                            .frame(height: 80)
                    } // VStack
                } // builder.content
                .sheetBackground { _ in
                    LinearGradient(gradient: Gradient(colors: [.white, .customLightGray1]),
                                   startPoint: .leading, endPoint: .trailing)
                    .opacity(0.95)
                    .blur(radius: 1)
                }
                .background { _ in
                    EmptyView()
                }
            } // .resizableSheet

            // 決済リザルトのシート画面
            .resizableSheet($commerceState, id: "B") {builder in
                builder.content { _ in

                    CommerceSheet(commerceState: $commerceState,
                                  basketState: $basketState,
                                  resultPrice: $input.resultPrice,
                                  resultItemAmount: $input.resultItemAmount,
                                  resultBasketItems: $input.resultBasketItems,
                                  doCommerce: $doCommerce)

                } // builder.content
                .supportedState([.medium])
                .sheetBackground { _ in
                    LinearGradient(gradient: Gradient(colors: [.white, .customLightGray1]),
                                   startPoint: .leading, endPoint: .trailing)
                    .opacity(0.95)
                }
                .background { _ in
                    EmptyView()
                }
            } // .resizableSheet

            .animation(.easeIn(duration: 0.2), value: isShowSearchField)
            .navigationTitle("Stock")
            .navigationBarTitleDisplayMode(.inline)
        } // NavigationView
        .onTapGesture { searchFocused = nil }

        // NOTE: ディスプレイのカラーモードを検知し、enumを切り替えます。
        .onChange(of: colorScheme) { _ in
            switch colorScheme {
            case .light: input.mode = .light
            case .dark: input.mode = .dark
            default:
                fatalError()
            } // switch
            print("ディスプレイモード: \(input.mode)")
        } // .onChange
    } // body
} // View

// ✅カスタムView: サイドタグバーのフレーム、選択タグの前後要素のインフォメーションを表示するオーバーレイviewです。
struct SideTagBarOverlay: View {

    @Binding var currentIndex: Int
    @Binding var sideTagOpacity: CGFloat
    @Binding var tags: [Tag]

    var body: some View {
        RoundedRectangle(cornerRadius: 0)
            .stroke(lineWidth: 0.2)
            .opacity(0.5)
            .frame(width: UIScreen.main.bounds.width + 10, height: 40)
            .shadow(color: .black, radius: 3, x: 0, y: 0)
            .shadow(color: .black, radius: 3, x: 0, y: 0)

        // NOTE: タグサイドバー枠内で、現在選択しているタグの前後の値をインフォメーションします。
            .overlay {
                HStack {
                    if currentIndex - 1 >= 0 {
                        HStack {
                            Text("<")
                            Text("\(tags[currentIndex - 1].tagName)")
                                .frame(width: 50)
                                .lineLimit(1)
                        } // HStack
                        .onTapGesture { self.currentIndex -= 1 }
                    }

                    Spacer()

                    if currentIndex + 1 < tags.count {
                        HStack {
                            Text("\(tags[currentIndex + 1].tagName)")
                                .frame(width: 50)
                                .lineLimit(1)
                            Text(">")
                        } // HStack
                        .onTapGesture { currentIndex += 1 }
                    }
                } // HStack
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .opacity(sideTagOpacity)
                .animation(.easeIn(duration: 0.1), value: currentIndex)

            } // overlay(サイドタグ情報)
            .animation(.easeIn(duration: 0.2), value: sideTagOpacity)
    }
} // カスタムView

struct ItemStockView_Previews: PreviewProvider {
    static var previews: some View {
        var windowScene: UIWindowScene? {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene
        }
        var resizableSheetCenter: ResizableSheetCenter? {
            windowScene.flatMap(ResizableSheetCenter.resolve(for:))
        }

        return ItemStockView(itemVM: ItemViewModel(),
                             itemsInfomationOpacity: .constant(0.0),
                             basketInfomationOpacity: .constant(0.0),
                             isShowSearchField: .constant(false),
                             isPresentedEditItem: .constant(false),
                             doCommerce: .constant(false),
                             basketState: .constant(.hidden),
                             commerceState: .constant(.hidden))
        .environment(\.resizableSheetCenter, resizableSheetCenter)
    }
} // View_Previews
