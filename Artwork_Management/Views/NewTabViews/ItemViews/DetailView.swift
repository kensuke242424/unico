//
//  DetailView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import FirebaseFirestore

struct DetailView: View {
    
    var item: Item
    let cardHeight: CGFloat
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("applicationDarkMode") var applicationDarkMode: Bool = true

    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var logVM: LogViewModel

    @StateObject var itemVM: ItemViewModel
    @StateObject var cartVM: CartViewModel
    @Binding var inputTab: InputTab
    @Binding var show: Bool
    var animation: Namespace.ID
    /// View Properties
    @State private var animationContent: Bool = false
    @State private var offsetAnimation: Bool = false
    @State private var openDetail: Bool = false
    @State private var showDetailBackground: Bool = false
    @State private var showDeleteAlert: Bool = false

    var favoriteStatus: Bool {
        return userVM.user?.favorites.contains(where: {$0 == item.id}) ?? false
    }
    
    var body: some View {
        
        VStack(spacing: 15) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    offsetAnimation = false
                }
                /// Closing Detail View
                withAnimation(.easeInOut(duration: 0.2).delay(0.1)) {
                    animationContent          = false
                    showDetailBackground      = false
                    inputTab.reportShowDetail = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        show.toggle()
                    }
                }
                
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .contentShape(Rectangle())
            }
            .padding([.leading, .vertical], 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(animationContent ? 1 : 0)
            
            /// Book Preview (with Matched Geometry Effect)
            GeometryReader {
                let size = $0.size
                
                HStack(spacing: 20) {
                    SDWebImageToItem(imageURL: item.photoURL,
                                      width: size.width / 2 - 15,
                                      height: size.height)
                        .clipShape(CustomCorners(corners: [.topRight, .bottomRight], radius: 10))
                        /// Matched Geometry ID
                        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                        .matchedGeometryEffect(id: item.id, in: animation)
                    // アイテムの簡略情報
                    VStack(alignment: .leading, spacing: 8) {
                        CustomOneLineLimitText(text: item.name == "" ?
                                               "No Name" : item.name,
                                               limit: 7)
                        .font(.title3)
                        .fontWeight(.semibold)
                        
                        Text(item.tag != "" ?
                             ": \(item.tag)" : "未グループ")
                        .font(.caption)
                        .foregroundColor(.gray)
                        
                        HStack {
                            Image(systemName: "shippingbox.fill")
                            Text("\(item.inventory)")
                        }
                        .font(.callout)
                        .foregroundColor(.orange)
                        .padding(.top, 10)
                        
                        HStack {
                            Text("\(item.price)")
                                .opacity(0.6)
                            Text("yen")
                                .opacity(0.4)
                        }
                        .font(.callout)
                        .tracking(2)
                    }
                    .padding(.trailing, 15)
                    .padding(.top, 60)
                    .offset(y: offsetAnimation ? 0 : 50)
                    .opacity(offsetAnimation ? 1 : 0)
                }
            }
            .frame(height: cardHeight)
            .zIndex(1)
            
            Rectangle()
                .fill(.gray)
                .opacity(applicationDarkMode ? 0.15 : 0.05)
                .ignoresSafeArea()
                .overlay(alignment: .top) {
                    ItemDetails()
                }
                .padding(.leading, 30)
                .padding(.top, -180)
                .zIndex(0)
                .opacity(animationContent ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Rectangle()
                .fill(colorScheme == .light ? .white : .black)
                .ignoresSafeArea()
                .opacity(animationContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                animationContent = true
            }
            
            withAnimation(.easeInOut(duration: 0.35).delay(0.1)) {
                offsetAnimation = true
            }
            
            withAnimation(.easeInOut(duration: 0.35).delay(0.1)) {
                showDetailBackground = true
            }
        }
    }
    @ViewBuilder
    func ItemDetails() -> some View {
        VStack(spacing: 0) {
            if !openDetail {
                HStack(spacing: 0) {
                    
                    Button {
                        userVM.updateFavorite(item.id)
                    } label: {
                        Label("お気に入り", systemImage: favoriteStatus ? "heart.fill" : "suit.heart")
                        .font(.callout)
                        .foregroundColor(favoriteStatus ? .red : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(openDetail ? true : false)
                    
                    Button {
                        cartVM.addCartItem(item: item)
                    } label: {
                        Label("カートに追加", systemImage: "cart.fill.badge.plus")
                            .font(.callout)
                            .foregroundColor(checkHaveNotInventory(item) ? .gray : .orange)
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(checkHaveNotInventory(item))
                    .disabled(openDetail ? true : false)
                    .opacity(checkHaveNotInventory(item) ? 0.3 : 1)
                }
                .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: -20)))
            
            
                Divider()
                    .padding(.vertical, 25)
                    .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: -20)))
                
            } // if !openDetail
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    HStack {
                        Text("このアイテムについて")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Button {
                            withAnimation(.spring(response: 0.6)) {
                                openDetail.toggle()
                            }
                        } label: {
                            Image(systemName: openDetail ?
                                  "list.bullet.circle.fill" : "list.bullet.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28)
                        }
                        
                        .padding(.leading, 50)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if openDetail {
                        ItemSalesDetail()
                    }
                    
                    /// Detail
                    Text(item.detail)
                        .font(.subheadline)
                        .kerning(0.5)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.primary.opacity(0.5))
                        .padding(.top, 8)
                }
                .padding(.bottom, 100)
            }
            .alert("確認", isPresented: $showDeleteAlert) {

                Button("削除", role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        offsetAnimation = false
                    }
                    /// Closing Detail View
                    withAnimation(.easeInOut(duration: 0.2).delay(0.1)) {
                        animationContent          = false
                        inputTab.reportShowDetail = false
                    }
                    withAnimation(.easeInOut(duration: 0.2).delay(0.1)) {
                        show.toggle()
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation {
                            itemVM.items.removeAll(where: { $0.id == item.id })
                        }
                        Task {
                            itemVM.deleteImage(path: item.photoPath)
                            itemVM.deleteItem(deleteItem: item, teamId: item.teamID)

                            logVM.addLog(to: teamVM.team,
                                         by: userVM.user,
                                         type: .deleteItem(item))
                        }
                    }
                }
                .foregroundColor(.red)
            } message: {
                Text("\(item.name != "" ? "\(item.name)" : "No Name") を削除しますか？")
            } // alert
            
            HStack {
                Spacer()
                Button {
                    navigationVM.path.append(EditItemPath.edit)
                } label: {
                    Label("編集", systemImage: "pencil.line")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 45)
                        .padding(.vertical, 10)
                        .background {
                            Capsule()
                                .foregroundColor(userVM.memberColor.color3)
                        }
                        .foregroundColor(.white)
                }
                .disabled(inputTab.showCommerce != .hidden ? true : false)
                .opacity(inputTab.showCommerce != .hidden ? 0.3 : 1)
                Spacer()
                
                Button {
                    showDeleteAlert.toggle()
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
            }
            .padding([.bottom, .horizontal], 15)
            
            
        }
        .padding(.top, 180)
        .padding([.horizontal, .top], 15)
        /// Applying Offset Animation
        .offset(y: offsetAnimation ? 0 : 50)
        .opacity(offsetAnimation ? 1 : 0)
    }
    
    @ViewBuilder
    func ItemSalesDetail() -> some View {
        
        VStack(alignment: .listRowSeparatorLeading, spacing: 8) {

            Divider()
                .frame(width: 300)
                .padding(.bottom)
            
            Group {
                HStack(spacing: 0) {
                    Text("名前　　　:　　 ")
                    CustomOneLineLimitText(text: item.name == "" ?
                                           "No Name" : item.name,
                                           limit: 10)
                }
                
                Text(item.author != "" ?
                          "制作者　　:　　 \(item.author)" :
                          "制作者　　:　　 ???")
                    .padding(.bottom, 12)
                     
                Text("在庫　　　:　　 \(item.inventory) 個")
                     
                Text(item.price != 0 ?
                     "価格　　　:　　 ¥ \(item.price)" :
                     "価格　　　:　　   -")
                    .padding(.bottom, 12)
                
                Text(item.sales != 0 ?
                     "総売上　　:　　 ¥ \(item.sales)" :
                     "総売上　　:　　   -")
                
                Text(item.totalAmount != 0 ?
                     "総売個数　:　　 \(item.totalAmount) 個" :
                     "総売個数　:　　   -")
                
                Text(item.totalInventory != 0 ?
                     "総仕入れ　:　　 \(item.totalInventory) 個":
                     "総仕入れ　:　　   -")
                    .padding(.bottom, 12)

                Text("登録日　　:　　 \(item.createTime.toStringWithCurrentLocale())")
                Text("最終更新　:　　 \(item.updateTime.toStringWithCurrentLocale())")
            }
            
            Divider()
                .frame(width: 300)
                .padding(.top)

        } // VStack
        .frame(width: 300)
        .font(.callout)
        .fontWeight(.light)
        .opacity(0.8)
        .tracking(1)
        .lineLimit(1)
        .padding(.vertical, 10)
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
}

struct DetailView_Previews: PreviewProvider {
    @Namespace static var animation
    static var previews: some View {
        DetailView(item: sampleItems.first!,
                   cardHeight: 200,
                   itemVM: ItemViewModel(),
                   cartVM: CartViewModel(),
                   inputTab: .constant(InputTab()),
                   show: .constant(true),
                   animation: animation)
    }
}
