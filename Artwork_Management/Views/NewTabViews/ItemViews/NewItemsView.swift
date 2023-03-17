//
//  ItemView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

struct NewItemsView: View {
    
    /// Tab親Viewから受け取るViewModelと状態変数
    @StateObject var teamVM: TeamViewModel
    @StateObject var userVM: UserViewModel
    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM : TagViewModel
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
    @State private var selectedItem: Item?
    @State private var animateCurrentItem: Bool = false
    
    var body: some View {
        GeometryReader {
            let size = $0.size
        VStack(spacing: 15) {
            
            TagsView()
                .opacity(showDarkBackground ? 0 : 1)
            
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 35) {
                        ForEach(testItem, id: \.self) { item in
                            ItemsCardView(item)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        animateCurrentItem = true
                                        showDarkBackground = true
                                        selectedItem = item
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                            showDetailView.toggle()
                                        }
                                    }
                                }
                                .opacity(showDarkBackground && selectedItem != item ? 0 : 1)
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
            }
            .padding(.top, 15)
        }
        .overlay {
            if let selectedItem, showDetailView {
                DetailView(show: $showDetailView, animation: animation, item: selectedItem)
                    .transition(.asymmetric(insertion: .identity, removal: .offset(y: 0)))
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
    
    /// 最後のカードが上部に残るためのボトムパディング
    func bottomPadding(_ size: CGSize = .zero) -> CGFloat {
        let cardHeight: CGFloat = 220
        let scrollViewHeight: CGFloat = size.height
        return scrollViewHeight - cardHeight - 110
    }
    
    @ViewBuilder
    func ItemsCardView(_ item: Item) -> some View {
        GeometryReader {
            let size = $0.size
            let rect = $0.frame(in: .named("SCROLLVIEW"))
            
            HStack(spacing: -25) {
                /// Book Detail Card
                /// このカードを置くと、カバー画像を愛でることができます。
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(": \(item.author)")
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
                        Text("\(item.price)")
                            .opacity(0.6)
                        Text("yen")
                            .opacity(0.4)
                    }
                    .font(.caption)
                    .tracking(2)
                    .foregroundColor(.black)
                }
                .padding(20)
                .frame(width: size.width / 2, height: size.height * 0.8)
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
                        // TODO: カートシートの表示とアイテムのカート追加
                    } label: {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.gray)
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
                        Image(item.name)
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width / 2, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            /// Matched Geometry ID
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
        NewItemsView(teamVM: TeamViewModel(),
                     userVM: UserViewModel(),
                     itemVM: ItemViewModel(),
                     tagVM : TagViewModel(),
                     inputTab: .constant(InputTab()))
    }
}
