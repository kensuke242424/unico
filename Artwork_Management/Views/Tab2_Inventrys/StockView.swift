//
//  ItemStockControlView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI
import ResizableSheet

struct InputStock {
    var searchItemNameText: String = "ALL"
    var currentIndex: Int = 0
    var actionRowIndex: Int = 0
    var sideTagOpacity: CGFloat = 0.4
    var isShowItemDetail: Bool = false
    var mode: Mode = .dark
}

struct CartResults {
    var resultItemAmount: Int = 0
    var resultPrice: Int = 0
    var resultCartItems: [Item] = []
}

struct StockView: View {

    @Environment(\.colorScheme) var colorScheme
    @StateObject var itemVM: ItemViewModel
    @Binding var inputHome: InputHome

    @FocusState var searchFocused: SearchFocus?
    @GestureState private var dragOffset: CGFloat = 0

    @State private var inputStock: InputStock = InputStock()
    @State private var cartResults: CartResults = CartResults()

    var body: some View {
        NavigationView {

            ScrollViewReader { scrollProxy in
                ZStack {
                    VStack {
                        // NOTE: 検索ボックスの表示管理
                        if inputHome.isShowSearchField {
                            TextField("キーワード検索", text: $inputStock.searchItemNameText)
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
                            .offset(x: -CGFloat(inputStock.currentIndex) * (bodyView.size.width * 0.7 + sideBarTagItemPadding))

                            .gesture(
                                DragGesture()
                                    .updating(self.$dragOffset, body: { (value, state, _) in

                                        // 先頭・末尾ではスクロールする必要がないので、画面幅の1/5までドラッグで制御する
                                        if inputStock.currentIndex == 0, value.translation.width > 0 {
                                            state = value.translation.width / 5
                                        } else if inputStock.currentIndex == (itemVM.tags.count - 1), value.translation.width < 0 {
                                            state = value.translation.width / 5
                                        } else {
                                            state = value.translation.width
                                        }
                                    })
                                    .onEnded({ value in
                                        var newIndex = inputStock.currentIndex

                                        // ドラッグ幅からページングを判定
                                        // 今回は画面幅x0.3としているが、操作感に応じてカスタマイズする必要がある
                                        if abs(value.translation.width) > bodyView.size.width * 0.2 {
                                            newIndex = value.translation.width > 0 ? inputStock.currentIndex - 1 : inputStock.currentIndex + 1
                                        }
                                        if newIndex < 0 {
                                            newIndex = 0
                                        } else if newIndex > (itemVM.tags.count - 1) {
                                            newIndex = itemVM.tags.count - 1
                                        }
                                        inputStock.currentIndex = newIndex
                                        if inputStock.currentIndex != 0 {
                                            inputHome.isShowSearchField = false
                                        }
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
                            SideTagBarOverlay(inputStock: $inputStock,
                                              tags: $itemVM.tags)
                        } // overlay
                        .padding(.top)

                        // NOTE: サイドタグバー両端のタグインフォメーションopacityを、ドラッグ位置を監視して管理しています。
                        .onChange(of: dragOffset) { newValue in
                            if newValue == 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    inputStock.sideTagOpacity = 0.4
                                }
                            } else {
                                inputStock.sideTagOpacity = 0.0
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
                                                inputStock: $inputStock,
                                                commerceResults: $cartResults)
                            Divider()
                                .background(.gray)
                                .padding()

                            HStack(spacing: 50) {
                                Text(inputStock.currentIndex == 0 ?
                                         "- \(inputStock.searchItemNameText) -" :
                                        "-  \(itemVM.tags[inputStock.currentIndex].tagName) -")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .shadow(radius: 3, x: 4, y: 6)
                                .lineLimit(1)
                                .opacity(0.8)

                                if !inputStock.searchItemNameText.isEmpty,
                                   inputStock.searchItemNameText != "ALL" {
                                    Button {
                                        inputStock.searchItemNameText = "ALL"
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
                                         inputStock: $inputStock,
                                         cartResults: $cartResults,
                                         selectFilterTag: itemVM.tags[inputStock.currentIndex].tagName)
                        } // ScrollView (アイテムロケーション)

                    } // VStack
                    // NOTE: アイテム詳細ボタンをタップすると、詳細画面が発火します。
                    if inputStock.isShowItemDetail {
                        ShowsItemDetail(itemVM: itemVM,
                                        item: itemVM.items[inputStock.actionRowIndex],
                                        itemIndex: inputStock.actionRowIndex,
                                        isShowitemDetail: $inputStock.isShowItemDetail)
                    } // if isShowItemDetail
                } // ZStack

                // NOTE: バスケット内にアイテムが追加された時点で、ハーフモーダルを表示します。
                .onChange(of: cartResults.resultCartItems) { [before = cartResults.resultCartItems] after in

                    if before.count == 0 {
                        inputHome.commerceState = .medium
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            inputHome.cartState = .medium
                        }
                    }
                    if after == [] {
                        inputHome.commerceState = .hidden
                        inputHome.cartState = .hidden
                        inputHome.basketInfomationOpacity = 0.7
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                            inputHome.basketInfomationOpacity = 0.0
                        }
                    }
                }

                // NOTE: アイテム情報の更新が入った時、カート内にアイテムがあればリセットします。
                .onChange(of: itemVM.items) { _ in

                    cartResults.resultCartItems = []
                    cartResults.resultItemAmount = 0
                    cartResults.resultPrice = 0

                    inputHome.itemsInfomationOpacity = 0.7
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                        inputHome.itemsInfomationOpacity = 0.0
                    }
                } // .onChange

                // NOTE: 入力フィールドの表示に合わせて、フォーカスを切り替えます。
                // NOTE: 入力フィールド表示時に、指定の位置まで自動フォーカスします。
                .onChange(of: inputHome.isShowSearchField) { newValue in

                    searchFocused = newValue ? .check : nil
                    if newValue == true {
                        if inputStock.searchItemNameText == "ALL" {
                            inputStock.searchItemNameText = ""
                            itemVM.tags[0].tagName = "検索"
                        }
                    }
                    if newValue == false {
                        if inputStock.searchItemNameText == "" {
                            inputStock.searchItemNameText = "ALL"
                            itemVM.tags[0].tagName = "ALL"
                        }
                    }

                    if newValue {
                        withAnimation(.easeIn(duration: 2.0)) {
                            scrollProxy.scrollTo("search", anchor: .top)
                            }
                        withAnimation(.easeIn(duration: 0.3)) {
                            inputStock.currentIndex = 0 // タグを「All」に更新
                        }
                    } // if
                } // .onChange

                .onChange(of: searchFocused) { newFocus in
                    if newFocus == nil {
                        inputHome.isShowSearchField = false
                    }
                } // .onChange

            } // ScrollViewReader

            .background(LinearGradient(gradient: Gradient(colors: [.customDarkGray1,
                                                                   .customLightGray1]),
                                       startPoint: .top, endPoint: .bottom))
            // アイテム取引かごのシート画面
            .resizableSheet($inputHome.cartState, id: "A") { builder in
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
                                    cartResults.resultCartItems = []
                                    cartResults.resultPrice = 0
                                    cartResults.resultItemAmount = 0
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
                                CartItemsSheet(
                                    itemVM: itemVM,
                                    cartResults: $cartResults,
                                    inputStock: $inputStock,
                                    inputHome: $inputHome,
                                    halfSheetScroll: .main)
                            },
                            additional: {
                                CartItemsSheet(
                                    itemVM: itemVM,
                                    cartResults: $cartResults,
                                    inputStock: $inputStock,
                                    inputHome: $inputHome,
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
            .resizableSheet($inputHome.commerceState, id: "B") {builder in
                builder.content { _ in

                    CommerceSheet(inputHome: $inputHome,
                                  commerceResults: $cartResults)

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

            .animation(.easeIn(duration: 0.2), value: inputHome.isShowSearchField)
            .navigationTitle("Stock")
            .navigationBarTitleDisplayMode(.inline)
        } // NavigationView
        .onTapGesture { searchFocused = nil }

        // NOTE: ディスプレイのカラーモードを検知し、enumを切り替えます。
        .onChange(of: colorScheme) { _ in
            switch colorScheme {
            case .light: inputStock.mode = .light
            case .dark: inputStock.mode = .dark
            default:
                fatalError()
            } // switch
            print("ディスプレイモード: \(inputStock.mode)")
        } // .onChange
    } // body
} // View

// ✅カスタムView: サイドタグバーのフレーム、選択タグの前後要素のインフォメーションを表示するオーバーレイviewです。
struct SideTagBarOverlay: View {

    @Binding var inputStock: InputStock
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
                    if inputStock.currentIndex - 1 >= 0 {
                        HStack {
                            Text("<")
                            Text("\(tags[inputStock.currentIndex - 1].tagName)")
                                .frame(width: 50)
                                .lineLimit(1)
                        } // HStack
                        .onTapGesture { inputStock.currentIndex -= 1 }
                    }

                    Spacer()

                    if inputStock.currentIndex + 1 < tags.count {
                        HStack {
                            Text("\(tags[inputStock.currentIndex + 1].tagName)")
                                .frame(width: 50)
                                .lineLimit(1)
                            Text(">")
                        } // HStack
                        .onTapGesture { inputStock.currentIndex += 1 }
                    }
                } // HStack
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .opacity(inputStock.sideTagOpacity)
                .animation(.easeIn(duration: 0.1), value: inputStock.currentIndex)

            } // overlay(サイドタグ情報)
            .animation(.easeIn(duration: 0.2), value: inputStock.sideTagOpacity)
    }
} // カスタムView

struct StockView_Previews: PreviewProvider {
    static var previews: some View {
        var windowScene: UIWindowScene? {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene
        }
        var resizableSheetCenter: ResizableSheetCenter? {
            windowScene.flatMap(ResizableSheetCenter.resolve(for:))
        }

        return StockView(itemVM: ItemViewModel(),
                             inputHome: .constant(InputHome())
        )
        .environment(\.resizableSheetCenter, resizableSheetCenter)
    }
} // View_Previews
