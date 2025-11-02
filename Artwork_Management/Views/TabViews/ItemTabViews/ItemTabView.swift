//
//  ItemView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import ResizableSheet
import Introspect

/// アイテムの在庫処理時のカート内の状態を管理する
/// このプロパティ群に値が検知されると、カートハーフモーダルが出現する
struct InputCart {
    var doCommerce: Bool = false
    var resultCartAmount: Int = 0
    var resultCartPrice: Int = 0
}

struct ItemTabView: View {

    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var momentLogVM: MomentLogViewModel
    @EnvironmentObject var logVM: LogViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var itemVM: ItemViewModel
    @EnvironmentObject var tagVM : TagViewModel

    @StateObject var cartVM: CartViewModel
    
    @Binding var inputTab: InputTab
    
    /// View Properties
    @Environment(\.colorScheme) var colorScheme
    @State private var activeTag: Tag?
    /// カートの表示に合わせてソートボタンを上にずらすためのプロパティ。
    @State private var sortViewOffsetY: CGFloat = 0
    @State private var carouselMode: Bool = false
    /// For Matched Geometry Effect
    @Namespace private var animation
    /// Detail View Properties
    @State private var showDetailView    : Bool = false
    @State private var showDarkBackground: Bool = false
    @State private var selectedItem      : Item?
    @State private var animateCurrentItem: Bool = false

    @State private var showDeleteAlert: Bool = false
    @State private var showImpossibleAlert: Bool = false

    /// アイテムカードの高さ
    @State var cardHeight: CGFloat = UIScreen.main.bounds.width / 2

    var selectedItemIndex: Int? {
        if let selectedItem {
            return getActionIndex(selectedItem)
        } else {
            return nil
        }
    }

    var selectedItemName: String {
        guard let selectedItem else { return "" }
        let getName = selectedItem.name != "" ? selectedItem.name : "No Name"
        return getName
    }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let filteredItems = itemVM.items.filter(
                itemVM.filteringFavorite ?
                {   userVM.user?.favorites.firstIndex(of: $0.id ?? "") != nil &&
                    ($0.tag == tagVM.activeTag?.tagName ||
                     tagVM.activeTag?.tagName == "全て") } :
                    {   $0.tag == tagVM.activeTag?.tagName ||
                        tagVM.activeTag?.tagName == "全て"
                    })

            VStack(spacing: 15) {

                ItemTagsView(tags: tagVM.tags, items: itemVM.items)
                    .padding(.top, 5)
                    .opacity(showDetailView ? 0 : 1)

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 35) {
                        ForEach(filteredItems) { item in
                            ItemCardView(item)
                                    .opacity(showDetailView && inputTab.selectedItem != item ? 0 : 1)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            guard let actionIndex = getActionIndex(item) else {
                                                return
                                            }
                                            cartVM.actionItemIndex = actionIndex
                                            animateCurrentItem        = true
                                            showDarkBackground        = true
                                            /// ✅ アニメーションにチラつきがあったため、二箇所で管理
                                            selectedItem = item
                                            inputTab.selectedItem = item
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                            withAnimation(.interactiveSpring(response: 0.6,
                                                                             dampingFraction: 0.7,
                                                                             blendDuration: 0.7)) {
                                                showDetailView.toggle()
                                                inputTab.reportShowDetail = true
                                            }
                                        }
                                    }
                                    .contextMenu {
                                        Button {
                                            // アイテム編集
                                            selectedItem = item
                                            inputTab.selectedItem = item
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                navigationVM.path.append(EditItemPath.edit)
                                            }
                                        } label: {
                                            Label("アイテムを編集する", systemImage: "pencil.line")
                                        }
                                        Button("Delete", role: .destructive) {
                                            // アイテム削除
                                            selectedItem = item
                                            inputTab.selectedItem = item
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                showDeleteAlert.toggle()
                                            }
                                        }
                                    }
                                    .alert("確認", isPresented: $showDeleteAlert) {
                                        Button("削除", role: .destructive) {
                                            // 一瞬ずらさないとアラートが瞬間だけ再表示されてしまう🧐
                                            guard let selectedItem else { return }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                Task {
                                                    await itemVM.deleteItem(deleteItem: selectedItem,
                                                                      teamId: selectedItem.teamID)

                                                    await logVM.addLog(to: teamVM.team,
                                                                       by: userVM.user,
                                                                       type: .deleteItem(selectedItem))
                                                }
                                            }
                                        }
                                        .foregroundColor(.red)
                                    } message: {
                                        Text("\(selectedItemName)を削除しますか？")
                                    } // alert
                            } // ForEath
                        
                        if itemVM.items.isEmpty {
                            AddItemScrollContainerView(size: size)
                                .onTapGesture {
                                    DispatchQueue.main.async {
                                        navigationVM.path.append(EditItemPath.create)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 20)
                    .padding(.bottom, bottomPadding(size))
                    .background {
                        ScrollViewDetector(carouselMode: $carouselMode,
                                           totalContent: itemVM.items.count)
                    }
                }
                /// グローバルビューからではなく、ここからのオフセットが必要なため
                /// ビューの座標空間に名前を付け、
                /// 他のコードがポイントやサイズなどの次元を名前付きの空間と相対的に操作できるようにする
                .coordinateSpace(name: "SCROLLVIEW")
            } // VStack
            .padding(.top, 15)
        } // Geometry
        .overlay {
            if let selectedItem, let selectedItemIndex, showDetailView {
                DetailView(item: itemVM.items[selectedItemIndex],
                           cardHeight: cardHeight,
                           cartVM: cartVM,
                           inputTab: $inputTab,
                           show: $showDetailView,
                           animation: animation)
                .transition(.asymmetric(insertion: .identity, removal: .offset(y: 0)))
            }
        }
        .overlay {
            ItemSortManuView(userColor: userVM.memberColor)
                .opacity(showDetailView ? 0 : 1)
                .offset(y: sortViewOffsetY)
                .onChange(of: inputTab.showCart) { showCart in
                    if showCart == .hidden {
                        withAnimation { sortViewOffsetY = 0 }
                    } else {
                        withAnimation { sortViewOffsetY = -120 }
                    }
                }
        }
        .background {
            ZStack {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(colorScheme == .light ? .white : .black)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .opacity(showDetailView ? 1 : 0)
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
    
    func getActionIndex(_ selectedItem: Item) -> Int? {
        let index = itemVM.items.firstIndex(where: { $0.id == selectedItem.id })
        return index
    }
    
    /// 最後のカードが上部に残るためのボトムパディング
    func bottomPadding(_ size: CGSize = .zero) -> CGFloat {
        let cardHeight: CGFloat = size.width / 2
        let scrollViewHeight: CGFloat = size.height
        return scrollViewHeight - cardHeight - 90
    }
    
    @ViewBuilder
    func ItemCardView(_ item: Item) -> some View {

        GeometryReader {
            let size = $0.size
            let rect = $0.frame(in: .named("SCROLLVIEW"))

            let _ = {
                let newHeight = size.width / 2
                if abs(cardHeight - newHeight) > 1 {  // 差が1px以上なら更新
                    DispatchQueue.main.async {
                        cardHeight = newHeight
                    }
                }
            }()

            HStack(spacing: -25) {
                /// Item Detail Card
                VStack(alignment: .leading, spacing: 8) {
                    Spacer(minLength: 5)

                    CustomOneLineLimitText(text: item.name, limit: 6)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text(item.tag == "" ? ": 未グループ" : ": \(item.tag)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "shippingbox.fill")
                        Text("\(item.inventory)")
                    }
                    .font(.callout)
                    .foregroundColor(.orange)
                    .padding(.top, 20)

                    Spacer(minLength: 0)
                    
                    HStack {
                        Text(item.price == 0 ? "-" : "\(item.price)")
                            .opacity(0.6)
                        Text("yen")
                            .opacity(0.4)
                    }
                    .font(.caption)
                    .tracking(2)
                    .foregroundColor(.black)

                    Spacer(minLength: 5)
                }
                .padding(20)
                .padding(.vertical, 20)
                .frame(width: size.width / 2, height: size.height * 0.85, alignment: .leading)
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
                    // 取引かごに追加するボタン
                    // タップするたびに、値段合計、個数、カート内アイテム要素にプラスする
                    Button {
                        guard let newActionIndex = getActionIndex(item) else {
                            print("アクションIndexの取得に失敗しました")
                            return
                        }
                        // カートに追加する在庫が無いことを知らせる通知
                        if checkHaveNotInventory(item) {
                            withAnimation(.spring(response: 0.2)) {
                                momentLogVM.setLog(type: .outItemStock)
                                hapticErrorNotification()
                            }
                            return
                        }
                        /// actionItemIndexは、itemVM内のアイテムとcartItem内のアイテムで同期を取るため必要
                        cartVM.actionItemIndex = newActionIndex
                        cartVM.setItemToCart(item: item)

                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.black)
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
                    .overlay(alignment: .top) {
                        FavoriteButton(item)
                    }
                    .padding([.bottom, .trailing], 20)
                }
                .offset(x: animateCurrentItem && selectedItem?.id == item.id ? -20 : 0)
                .opacity(showDetailView ? 0 : 1)

                /// アイテムのImageカード
                ZStack {
                    if !(showDetailView && selectedItem?.id == item.id) {
                        SDWebImageToItem(imageURL: item.photoURL,
                                          width: size.width / 2,
                                          height: size.width / 2)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .transition(.asymmetric(insertion: .slide, removal: .identity))
                            /// Matched Geometry ID
                            .matchedGeometryEffect(id: item.id, in: animation)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: -5)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: size.width)
            .rotation3DEffect(.init(degrees: convertOffsetToRotation(rect)),
                              axis: (x: 1, y: 0, z: 0),
                              anchor: .bottom, anchorZ: 1,
                              perspective: 0.5)
        }
        .frame(height: cardHeight)
    }
    
    func checkHaveNotInventory(_ item: Item) -> Bool {
        
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
    private func FavoriteButton(_ item: Item) -> some View {
        /// ユーザーが対象アイテムをお気に入りに入れているかをBool値で返すプロパティ
        var favoriteStatus: Bool {
            return userVM.user?.favorites.contains(where: {$0 == item.id}) ?? false
        }
        Button {
            Task {
              await userVM.updateFavorite(item.id)
            }
        } label: {
            if favoriteStatus {
                Image(systemName: "heart.fill")
            } else {
                Image(systemName: "heart")
            }
        }
        .particleEffect(systemImage: "heart.fill",
                        font: .title,
                        status: favoriteStatus,
                        activeTint: .red,
                        inActiveTint: .white
        )
        .foregroundColor(.red)
        .offset(x: 2, y: -40)
    }
    
    @ViewBuilder
    func FilteringFavoriteItemButton() -> some View {
        ZStack {
            Capsule()
                .frame(width: 40, height: 12)
                .foregroundColor(itemVM.filteringFavorite ? .green : .gray)
                .opacity(itemVM.filteringFavorite ? 0.7 : 0.5)
            Image(systemName: "heart.fill")
                .font(.title)
                .foregroundColor(.black).opacity(0.6)
                .offset(x: itemVM.filteringFavorite ? 9 : -7)
            Image(systemName: "heart.fill")
                .font(.title)
                .foregroundColor(itemVM.filteringFavorite ? .red : .white)
                .scaleEffect(0.95)
                .padding()
                .offset(x: itemVM.filteringFavorite ? 9 : -7)
        }
        .opacity(itemVM.items.isEmpty ? 0 : 1)
        .onTapGesture {
            withAnimation(.spring(response: 0.4)) {
                itemVM.filteringFavorite.toggle()
            }
        }
    }
    
    @ViewBuilder
    func AddItemScrollContainerView(size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.gray.gradient)
                .frame(width: size.width * 0.5, height: 120)
            
            Image(systemName: "shippingbox")
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .foregroundColor(.black.opacity(0.3))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 27)
                        .foregroundColor(.black.opacity(0.35))
                        .offset(x: 20, y: -15)
                }
        }
        .opacity(0.7)
    }
    
    @ViewBuilder
    func ItemTagsView(tags: [Tag], items: [Item]) -> some View {
        HStack {
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // MEMO: 未グループタグのアイテムがあるかどうかで「未グループ」タグの表示を切り替える
                    ForEach(tags.filter(items.contains(where: { $0.tag == "未グループ" }) ?
                                        {$0.tagName != ""} :
                                        {$0.tagName != "未グループ"})) { tag in
                        Text(tag.tagName)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background {
                                if tagVM.activeTag == tag {
                                    Capsule()
                                        .foregroundColor(userVM.memberColor.color3)
                                        .matchedGeometryEffect(id: "ACTIVETAG", in: animation)
                                } else {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.6))
                                }
                            }
                            .foregroundColor(tagVM.activeTag == tag ? .white : .white.opacity(0.7))
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7)) {
                                    tagVM.activeTag = tag
                                }
                            }
                            .contextMenu {
                                Button {
                                    // タグ編集
                                    if tag.tagName == "全て" || tag.tagName == "未グループ" {
                                        showImpossibleAlert.toggle()
                                        return
                                    }
                                    inputTab.selectedTag = tag
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            tagVM.showEdit.toggle()
                                        }
                                    }

                                } label: {
                                    Label("タグを編集する", systemImage: "pencil.line")
                                }

                                Button("Delete", role: .destructive) {
                                    // タグ削除
                                    if tag.tagName == "全て" || tag.tagName == "未グループ" {
                                        showImpossibleAlert.toggle()
                                        return
                                    }
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        tagVM.tags.removeAll(where: {$0 == tag})
                                    }
                                    Task {
                                        await tagVM.deleteTag(deleteTag: tag,
                                                              teamId: teamVM.team!.id,
                                                              items: itemVM.items)
                                    }
                                }
                            }
                            .alert("", isPresented: $showImpossibleAlert) {
                                Button("OK") {}
                            } message: {
                                Text("このタグは削除できません。")
                            } // alert
                        
                    } // ForEath
                } // HStack
                .padding(.leading, 15)
            } // ScrollView
            // スクロール時の引っ掛かりを無くす
            .introspectScrollView { scrollView in
                 scrollView.isDirectionalLockEnabled = true
                 scrollView.bounces = false
            }
            
            /// Add Tag
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    inputTab.selectedTag = nil
                    tagVM.showEdit = true
                }
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 8)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding(6)
                    .background {
                        Circle()
                        .fill(.white.gradient)
                        .shadow(radius: 3, x: 1, y: 1)
                    }
            }
            .padding(.leading, 5)
            .padding(.trailing, 15)
            .offset(y: -1)
        }
    }
} // View
