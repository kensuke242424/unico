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

    let sideBarTagItemPadding: CGFloat = 80

    @State private var searchItemText = ""
    @State private var currentIndex = 0
    @State private var listIndex = 0
    @State private var sideTagOpacity: CGFloat = 0.7
    @State private var isPresentedNewItem = false
    @State private var isShowSearchField = false
    @State private var isShowItemDetail: Bool = false
    @State var state: ResizableSheetState = .hidden
    @State private var mode: Mode = .dark

    @FocusState var searchFocused: SearchFocus?

    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        NavigationView {
            ZStack {
                VStack {

                    // NOTE: 検索ボックスの表示管理
                    if isShowSearchField {

                        TextField("キーワード検索", text: $searchItemText)
                            .textFieldStyle(.roundedBorder)
                            .focused($searchFocused, equals: .check)
                            .padding(.horizontal)
                    }

                    // NOTE: Geometryを用いたサイドタグセレクトバー
                    GeometryReader { bodyView in

                        LazyHStack(spacing: sideBarTagItemPadding) {

                            ForEach(itemVM.tags.indices, id: \.self) {index in

                                Text(itemVM.tags[index].tagName)
                                    .font(.system(size: 20, weight: .bold))
                                    .frame(width: bodyView.size.width * 0.7, height: 40)
                                    .padding(.leading, index == 0 ? bodyView.size.width * 0.1 : 0)

                            } // ForEach
                        } // LazyHStack
                        .padding()
                        .offset(x: self.dragOffset)
                        .offset(x: -CGFloat(self.currentIndex) * (bodyView.size.width * 0.7 + sideBarTagItemPadding))

                        .gesture(
                            DragGesture()
                                .updating(self.$dragOffset, body: { (value, state, _) in

                                    // 先頭・末尾ではスクロールする必要がないので、画面幅の1/5までドラッグで制御する
                                    if self.currentIndex == 0, value.translation.width > 0 {
                                        state = value.translation.width / 5
                                    } else if self.currentIndex == (itemVM.tags.count - 1), value.translation.width < 0 {
                                        state = value.translation.width / 5
                                    } else {
                                        state = value.translation.width
                                    }
                                })
                                .onEnded({ value in
                                    var newIndex = self.currentIndex

                                    // ドラッグ幅からページングを判定
                                    // 今回は画面幅x0.3としているが、操作感に応じてカスタマイズする必要がある
                                    if abs(value.translation.width) > bodyView.size.width * 0.2 {
                                        newIndex = value.translation.width > 0 ? self.currentIndex - 1 : self.currentIndex + 1
                                    }
                                    if newIndex < 0 {
                                        newIndex = 0
                                    } else if newIndex > (itemVM.tags.count - 1) {
                                        newIndex = itemVM.tags.count - 1
                                    }
                                    self.currentIndex = newIndex
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
                        SideTagBarOverlay(currentIndex: $currentIndex,
                                          sideTagOpacity: $sideTagOpacity,
                                          tags: $itemVM.tags)
                    } // overlay

                    // NOTE: サイドタグバー両端のタグインフォメーションopacityを、ドラッグ位置を監視して管理しています。
                    .onChange(of: dragOffset) { newValue in
                        if newValue == 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.sideTagOpacity = 0.3
                            }
                        } else {
                            self.sideTagOpacity = 0.0
                        }
                    } // onChange

                    // Check: タグセレクトバーの選択タグindex値
                    .onChange(of: currentIndex) { newValue in
                            print(newValue)
                    }

                    // NOTE: アイテム要素全体のロケーション
                    ScrollView {
                        TagTitle(title: "最近更新したアイテム", font: .title3)
                            .padding(.top)

                        Divider()
                            .background(.gray)
                            .padding()
                         // ✅カスタムView: 最近更新したアイテムをHStack表示します。(横スクロール)
                        UpdateTimeCards(isShowItemDetail: $isShowItemDetail,
                                        listIndex: $listIndex,
                                        itemWidth: UIScreen.main.bounds.width * 0.41,
                                        itemHeight: 210,
                                        itemSpase: 20,
                                        itemNameTag: "アイテム",
                                        items: itemVM.items)

                         Divider()
                             .background(.gray)
                             .padding()

                        TagTitle(title: itemVM.tags[currentIndex].tagName, font: .title)
                            .padding()
                         // ✅カスタムView: アイテムを表示します。(縦スクロール)
                         TagCards(isShowItemDetail: $isShowItemDetail,
                                  listIndex: $listIndex,
                                  itemWidth: UIScreen.main.bounds.width * 0.43,
                                  itemHeight: 220,
                                  itemSpase: 20,
                                  itemNameTag: "アイテム",
                                  items: itemVM.items)
                    } // ScrollView (アイテムロケーション)

                } // VStack

                // NOTE: アイテム詳細ボタンをタップすると、詳細画面が発火します。
                if isShowItemDetail {
                    ShowsItemDetail(itemVM: itemVM,
                                    item: itemVM.items[listIndex],
                                    itemIndex: listIndex,
                                    isShowitemDetail: $isShowItemDetail)
                } // if isShowItemDetail
            } // ZStack
            .background(LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                                       startPoint: .top, endPoint: .bottom))
            .navigationTitle("ItemStock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.isShowSearchField.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.searchFocused = isShowSearchField ? .check : nil
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 20)
                            .shadow(radius: 3, x: 1, y: 1)
                    } // Button
                }
            } // .toolbar
            .animation(.easeIn(duration: 0.2), value: isShowSearchField)
            .navigationTitle("ItemStock")
            .navigationBarTitleDisplayMode(.inline)
        } // NavigationView
        .onTapGesture { searchFocused = nil }

        // NOTE: ディスプレイのカラーモードを検知し、enumを切り替えます。
        .onChange(of: colorScheme) { _ in
            switch colorScheme {
            case .light: mode = .light
            case .dark: mode = .dark
            default:
                fatalError()
            } // switch
            print("ディスプレイモード: \(mode)")
        } // .onChange
    } // body
} // View

// ✅カスタムView: アイテムのタグタイトル
struct TagTitle: View {

    let title: String
    let font: Font

    var body: some View {

        HStack {
             Text("- \(title) -")
                 .font(font.bold())
                 .shadow(radius: 3, x: 4, y: 6)
                 .padding(.horizontal)

            Spacer()
         }
    } // body
} // カスタムView

// ✅カスタムView: サイドタグバーのフレーム、選択タグの前後要素のインフォメーションを表示するオーバーレイviewです。
struct SideTagBarOverlay: View {

    @Binding var currentIndex: Int
    @Binding var sideTagOpacity: CGFloat
    @Binding var tags: [Tag]

    var body: some View {
        RoundedRectangle(cornerRadius: 0)
            .stroke(lineWidth: 0.2)
//            .opacity(0.3)
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
                        .onTapGesture { self.currentIndex += 1 }
                    }
                } // HStack
                .padding(.horizontal, 20)
                .opacity(sideTagOpacity)
                .animation(.easeIn(duration: 0.1), value: currentIndex)

            } // overlay(サイドタグ情報)
            .animation(.easeIn(duration: 0.2), value: sideTagOpacity)
    }
} // カスタムView

struct ItemStockControlView_Previews: PreviewProvider {
    static var previews: some View {
        var windowScene: UIWindowScene? {
                    let scenes = UIApplication.shared.connectedScenes
                    let windowScene = scenes.first as? UIWindowScene
                    return windowScene
                }
        var resizableSheetCenter: ResizableSheetCenter? {
                   windowScene.flatMap(ResizableSheetCenter.resolve(for:))
               }

        return ItemStockView(itemVM: ItemViewModel())
            .environment(\.resizableSheetCenter, resizableSheetCenter)
    }
} // View_Previews
