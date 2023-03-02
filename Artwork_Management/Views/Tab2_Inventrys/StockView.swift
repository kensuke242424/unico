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
    var filterTagIndex: Int = 0
    var resultCartAmount: Int = 0
    var resultCartPrice: Int = 0
    var mode: Mode = .dark
}

struct StockView: View {

    enum SearchFocus {
        case check
    }

    @Environment(\.colorScheme) var colorScheme
    @StateObject var teamVM: TeamViewModel
    @StateObject var userVM: UserViewModel
    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM: TagViewModel
    @Binding var inputHome: InputHome
    @Binding var inputImage: InputImage

    @FocusState var searchFocused: SearchFocus?
    @GestureState private var dragOffset: CGFloat = 0

    @State private var inputStock: InputStock = InputStock()

    var body: some View {

        NavigationView {
            ScrollViewReader { scrollProxy in
                ZStack {

                    GradientBackbround(color1: userVM.user!.userColor.color1,
                                       color2: userVM.user!.userColor.colorAccent)

                    VStack {

                        // NOTE: アイテム要素全体のロケーション
                        ScrollView {

                            Spacer().frame(height: 60)

                            TagTitle(title: "最近更新したアイテム", font: .title3)
                                .foregroundColor(.white)
                                .opacity(0.8)
                                .padding(.vertical)

                            Divider()
                                .background(.gray)
                                .padding(.horizontal)

                            // ✅カスタムView: 最近更新したアイテムをHStack表示します。(横スクロール)
                            UpdateTimeSortCards(itemVM: itemVM,
                                                inputHome: $inputHome,
                                                inputStock: $inputStock)

                            Divider()
                                .background(.gray)
                                .padding([.horizontal, .bottom])

                            Text(tagVM.tags[inputStock.filterTagIndex].tagName)
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .frame(width: 150, height: 40)
                                .padding()

                            // NOTE: サイドタグバーの枠フレームおよび、前後のタグインフォメーションを表示します。
                                .overlay {
                                    SideTagBarOverlay(inputStock: $inputStock,
                                                      tags: $tagVM.tags)
                                } // overlay
                                .id("search")

                            // NOTE: 検索ボックスの表示管理
                            if inputHome.isShowSearchField {
                                TextField("キーワード検索", text: $inputStock.searchItemNameText)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .focused($searchFocused, equals: .check)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                            }

                            HStack(spacing: 50) {
                                Text(inputStock.filterTagIndex == 0 ?
                                     "- \(inputStock.searchItemNameText) -" :
                                        "- \(tagVM.tags[inputStock.filterTagIndex].tagName) -")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .shadow(radius: 3, x: 4, y: 6)
                                .lineLimit(1)
                                .opacity(0.8)

                                if !inputStock.searchItemNameText.isEmpty, inputStock.searchItemNameText != "ALL" {
                                    Button {
                                        inputStock.searchItemNameText = inputHome.isShowSearchField ? "" : "ALL"
                                        tagVM.tags[0].tagName = inputHome.isShowSearchField ? "検索" : "ALL"
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
                            .padding([.leading, .vertical])

                            TagSortCards(itemVM: itemVM,
                                         tagVM: tagVM,
                                         inputHome: $inputHome,
                                         inputStock: $inputStock,
                                         selectFilterTag: tagVM.tags[inputStock.filterTagIndex].tagName)

                        } // ScrollView (アイテムロケーション)

                    } // VStack
                } // ZStack

                // NOTE: カート内のアイテムを監視してハーフモーダルを表示
                //       カートが空になったら、更新インフォメーションを表示
                .onChange(of: inputStock.resultCartAmount) { [before = inputStock.resultCartAmount] after in

                    if before == 0 {
                        inputHome.commerceHalfSheet = .medium
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            inputHome.cartHalfSheet = .medium
                        }
                    }
                    if after == 0 {
                        inputHome.cartHalfSheet = .hidden
                        inputHome.commerceHalfSheet = .hidden
                        inputHome.basketInfomationOpacity = 0.7
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                            inputHome.basketInfomationOpacity = 0.0
                        }
                    }
                }

                .onChange(of: inputStock.filterTagIndex) { newIndex in
                    if newIndex != 0 { inputHome.isShowSearchField = false }
                }

                // NOTE: 入力フィールドの表示に合わせて、フォーカスを切り替えます。
                // NOTE: 入力フィールド表示時に、指定の位置まで自動フォーカスします。
                .onChange(of: inputHome.isShowSearchField) { newValue in

                    searchFocused = newValue ? .check : nil
                    if newValue == true {
                        if inputStock.searchItemNameText == "ALL" {
                            inputStock.searchItemNameText = ""
                            tagVM.tags[0].tagName = "検索"
                        }
                    }
                    if newValue == false {
                        if inputStock.searchItemNameText == "" {
                            inputStock.searchItemNameText = "ALL"
                            tagVM.tags[0].tagName = "ALL"
                        }
                    }

                    if newValue {
                        withAnimation(.easeIn(duration: 2.0)) {
                            scrollProxy.scrollTo("search", anchor: .top)
                        }
                        inputStock.filterTagIndex = 0 // タグを「All」に更新
                    } // if
                } // .onChange

                .onChange(of: searchFocused) { newFocus in
                    if newFocus == nil {
                        inputHome.isShowSearchField = false
                    }
                } // .onChange

            } // ScrollViewReader

            // アイテム取引かごのシート画面
            .resizableSheet($inputHome.cartHalfSheet, id: "A") { builder in
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
                                    inputStock.resultCartPrice = 0
                                    inputStock.resultCartAmount = 0
                                    itemVM.resetAmount()

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
                                    inputStock: $inputStock,
                                    inputHome: $inputHome,
                                    halfSheetScroll: .main)
                            },
                            additional: {
                                CartItemsSheet(
                                    itemVM: itemVM,
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
            .resizableSheet($inputHome.commerceHalfSheet, id: "B") {builder in
                builder.content { _ in

                    CommerceSheet(itemVM: itemVM,
                                  inputHome: $inputHome,
                                  inputStock: $inputStock,
                                  teamID: teamVM.team!.id)

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
        } // NavigationView
    } // body
} // View

// ✅カスタムView: サイドタグバーのフレーム、選択タグの前後要素のインフォメーションを表示するオーバーレイviewです。
struct SideTagBarOverlay: View {

    @Binding var inputStock: InputStock
    @Binding var tags: [Tag]

    var body: some View {
        RoundedRectangle(cornerRadius: 0)
            .foregroundColor(.black)
            .opacity(0.3)
            .frame(width: UIScreen.main.bounds.width + 10, height: 40)
            .shadow(color: .black, radius: 3, x: 0, y: 0)

        // NOTE: タグサイドバー枠内で、現在選択しているタグの前後の値をインフォメーションします。
            .overlay {
                HStack {
                    if inputStock.filterTagIndex - 1 >= 0 {
                        HStack {
                            Text("<")
                            Text("\(tags[inputStock.filterTagIndex - 1].tagName)")
                                .font(.subheadline)
                                .frame(width: 80, alignment: .leading)
                                .lineLimit(1)
                        } // HStack
                        .onTapGesture { inputStock.filterTagIndex -= 1 }
                    }

                    Spacer()

                    if inputStock.filterTagIndex + 1 < tags.count {
                        HStack {
                            Text("\(tags[inputStock.filterTagIndex + 1].tagName)")
                                .font(.subheadline)
                                .frame(width: 80, alignment: .trailing)
                                .lineLimit(1)
                            Text(">")
                        } // HStack
                        .onTapGesture { inputStock.filterTagIndex += 1 }
                    }
                } // HStack
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 20)

            } // overlay(サイドタグ情報)
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

        return StockView(teamVM: TeamViewModel(),
                         userVM: UserViewModel(),
                         itemVM: ItemViewModel(),
                         tagVM: TagViewModel(),
                         inputHome: .constant(InputHome()),
                         inputImage: .constant(InputImage())
        )
        .environment(\.resizableSheetCenter, resizableSheetCenter)
    }
} // View_Previews
