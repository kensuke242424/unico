//
//  ItemView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import ResizableSheet

struct InputCart {
    var doCommerce: Bool = false
    var resultCartAmount: Int = 0
    var resultCartPrice: Int = 0
}

struct NewItemsView: View {
    
    /// Tab親Viewから受け取るViewModelと状態変数
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tagVM : TagViewModel
    
    @StateObject var itemVM: ItemViewModel
    @StateObject var cartVM: CartViewModel
    
    @Binding var inputTab: InputTab
    
    /// View Propaties
    @Environment(\.colorScheme) var colorScheme
    @State private var activeTag: String = "全て"
    @State private var carouselMode: Bool = false
    /// For Matched Geometry Effect
    @Namespace private var animation
    /// Detail View Properties
    @State private var showDetailView: Bool = false
    @State private var showDarkBackground: Bool = false
    @State private var selectedItem: RootItem?
    @State private var animateCurrentItem: Bool = false
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            VStack(spacing: 15) {
                
                TagsView()
                    .opacity(showDarkBackground ? 0 : 1)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 35) {
                        ForEach(itemVM.rootItems, id: \.self) { item in
                            ItemsCardView(item)
                                .onAppear {print("ItemCardsView_onAppear: \(item.name)") }
                                .onDisappear {print("ItemCardsView_onDisapper: \(item.name)") }
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        guard let actionIndex = getActionIndex(item) else {
                                            return
                                        }
                                        
                                        cartVM.actionItemIndex = actionIndex
                                        animateCurrentItem        = true
                                        showDarkBackground        = true
                                        inputTab.reportShowDetail = true
                                        /// ✅ アニメーションにチラつきがあったため、二箇所で管理
                                        selectedItem = item
                                        inputTab.selectedItem = item
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                            showDetailView.toggle()
                                        }
                                    }
                                }
                                .opacity(showDarkBackground && inputTab.selectedItem != item ? 0 : 1)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 20)
                    .padding(.bottom, bottomPadding(size))
                    .background {
                        ScrollViewDetector(carouselMode: $carouselMode,
                                           totalContent: sampleBooks.count)
                    }
                }
                /// Since we need offset from here and not from global View
                /// グローバルビューからではなく、ここからのオフセットが必要なため
                /// ビューの座標空間に名前を付け、
                /// 他のコードがポイントやサイズなどの次元を名前付きの空間と相対的に操作できるようにします。
                .coordinateSpace(name: "SCROLLVIEW")
            } // VStack
            .padding(.top, 15)
        } // Geometry
        .overlay {
            if let selectedItem, showDetailView {
                DetailView(itemVM: itemVM,
                           cartVM: cartVM,
                           inputTab: $inputTab,
                           show: $showDetailView,
                           animation: animation,
                           item: itemVM.rootItems[cartVM.actionItemIndex])
                    .transition(.asymmetric(insertion: .identity, removal: .offset(y: 0)))
                    .onAppear { print("カード詳細onAppear") }
                    .onDisappear { print("カード詳細onDisappear") }
            }
        }
        .background {
            ZStack {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(colorScheme == .light ? .white : .black)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .opacity(showDarkBackground ? 1 : 0)
                }
                .ignoresSafeArea()
            }
        }
        .onChange(of: showDetailView) { newValue in
            if !newValue {
                showDarkBackground = false
                withAnimation(.easeInOut(duration: 0.35).delay(0.4)) {
                    animateCurrentItem = false
                }
            }
        }
    }
    
    func getActionIndex(_ selectedItem: RootItem) -> Int? {
        let index = itemVM.rootItems.firstIndex(where: { $0.id == selectedItem.id })
        return index
    }
    
    /// 最後のカードが上部に残るためのボトムパディング
    func bottomPadding(_ size: CGSize = .zero) -> CGFloat {
        let cardHeight: CGFloat = 220
        let scrollViewHeight: CGFloat = size.height
        return scrollViewHeight - cardHeight - 110
    }
    
    @ViewBuilder
    func ItemsCardView(_ item: RootItem) -> some View {
        GeometryReader {
            let size = $0.size
            let rect = $0.frame(in: .named("SCROLLVIEW"))
            
            HStack(spacing: -25) {
                /// Book Detail Card
                /// このカードを置くと、カバー画像を愛でることができます。
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name == "" ? "No Name" : item.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(item.author == "" ? "" : ": \(item.author)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "shippingbox.fill")
                        Text("\(item.inventory)")
                    }
                    .font(.callout)
                    .foregroundColor(.orange)
                    .padding(.top, 20)
                    
                    HStack {
                        Text(item.price == 0 ? "-" : "\(item.price)")
                            .opacity(0.6)
                        Text("yen")
                            .opacity(0.4)
                    }
                    .font(.caption)
                    .tracking(2)
                    .foregroundColor(.black)
                }
                .padding(20)
                .frame(width: size.width / 2, height: size.height * 0.8, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        // Applying Shadow
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 5, y: -5)
                        .shadow(color: .black.opacity(0.08), radius: 8, x: -5, y: -5)
                }
                .zIndex(1)
                /// カートにアイテムを入れるボタン
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        // 取引かごに追加するボタン
                        // タップするたびに、値段合計、個数、カート内アイテム要素にプラスする
                        guard let newActionIndex = getActionIndex(item) else {
                            print("アクションIndexの取得に失敗しました")
                            return
                        }
                        
                        // TODO: カートに追加する在庫が無いことを知らせるアラートメッセージ
                        if checkHaveNotInventory(item) {
                            print("これ以上カートに追加する在庫がありません")
                            return
                        }
                        
                        /// actionItemIndexは、itemVMのアイテムとcartItemのアイテムで同期を取るため必要
                        cartVM.actionItemIndex = newActionIndex
                        cartVM.addCartItem(item: item)
                        
                    } label: {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.gray)
                            .opacity(checkHaveNotInventory(item) ? 0.3 : 1)
                            .background {
                                Circle()
                                    .foregroundColor(.white)
                                    .scaleEffect(2)
                                    .shadow(radius: 1, x: 1, y: 1)
                                    .shadow(radius: 1, x: 1, y: 1)
                            }
                    }
                    .padding([.bottom, .trailing], 20)
                }
                .offset(x: animateCurrentItem && selectedItem?.id == item.id ? -20 : 0)
                
                /// Book Cover Image
                ZStack {
                    if !(showDetailView && selectedItem?.id == item.id) {
                        SDWebImageView(imageURL: item.photoURL,
                                          width: size.width / 2,
                                          height: size.height)
                            /// Matched Geometry ID
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .transition(.asymmetric(insertion: .slide, removal: .identity))
                            .matchedGeometryEffect(id: item.id, in: animation)
                            // Applying Shadow
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: -5)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: size.width)
            .rotation3DEffect(.init(degrees: convertOffsetToRotation(rect)), axis: (x: 1, y: 0, z: 0), anchor: .bottom, anchorZ: 1, perspective: 0.5)
        }
        .frame(height: 220)
    }
    
    func checkHaveNotInventory(_ item: RootItem) -> Bool {
        
        var checkResult: Bool = false
        
        if item.inventory == 0 {
            checkResult = true
            return checkResult
        }
        
        let filterCartItem = cartVM.cartItems.filter({ item.id == $0.id })
        if filterCartItem.isEmpty {
            checkResult = false
            return checkResult
        } else {
            for cartItem in filterCartItem {
                if item.inventory - cartItem.amount <= 0 {
                    checkResult =  true
                } else {
                    checkResult = false
                }
            }
        }
        return checkResult
    }
    
    /// Converting minY Rotation -minY回転を変換する-
    func convertOffsetToRotation(_ rect: CGRect) -> CGFloat {
        let cardHeight = rect.height + 20
        let minY = rect.minY - 20
        let progress = minY < 0 ? (minY / cardHeight) : 0
        /// min -> 比較可能な2つの値のうち、小さい方を返します。
        let conctrainedProgress = min(-progress, 1.0)
        
        return conctrainedProgress * 90
    }
    
    @ViewBuilder
    func TagsView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background {
                            if activeTag == tag {
                                Capsule()
                                    .fill(Color.blue)
                                    .matchedGeometryEffect(id: "ACTIVETAG", in: animation)
                            } else {
                                Capsule()
                                    .fill(Color.gray.opacity(0.4))
                            }
                        }
                        .foregroundColor(activeTag == tag ? .white : .white.opacity(0.6))
                        .onTapGesture {
                            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7)) {
                                activeTag = tag
                            }
                        }
                }
                
                /// Add Tag
                Button {
                    
                } label: {
                    Image(systemName: "plus.app.fill")
                        .foregroundColor(Color.gray.opacity(0.5))
                }
                .padding(.leading, 5)
            }
            .padding(.horizontal, 15)
        }
        .padding(.top)
    }
} // View

/// Sample Tags
var tags: [String] =
[
"全て", "CD", "トートバッグ", "缶バッジ", "DVD",
]

struct NewItemsView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemsView(itemVM: ItemViewModel(),
                     cartVM: CartViewModel(),
                     inputTab   : .constant(InputTab()))
        .environmentObject(LogInViewModel())
        .environmentObject(TeamViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(ItemViewModel())
        .environmentObject(TagViewModel())
    }
}
