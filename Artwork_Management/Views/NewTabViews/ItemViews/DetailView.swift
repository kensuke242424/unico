//
//  DetailView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import FirebaseFirestore

struct DetailView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var show: Bool
    var animation: Namespace.ID
    var item: Item
    /// View Properties
    @State private var animationContent: Bool = false
    @State private var offsetAnimation: Bool = false
    @State private var openDetail: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    offsetAnimation = false
                }
                /// Closing Detail View
                withAnimation(.easeInOut(duration: 0.35).delay(0.1)) {
                    animationContent = false
                }
                withAnimation(.easeInOut(duration: 0.35).delay(0.1)) {
                    show.toggle()
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
                    Image(item.name)
                        .resizable()
                        .scaledToFill()
                        .frame(width: (size.width - 30) / 2, height: size.height)
                        .clipShape(CustomCorners(corners: [.topRight, .bottomRight], radius: 20))
                        /// Matched Geometry ID
                        .transition(.opacity)
                        .matchedGeometryEffect(id: item.id, in: animation)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(": \(item.name)")
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
            .frame(height: 220)
            .zIndex(1)
            
            Rectangle()
                .fill(.gray.opacity(0.05))
                .ignoresSafeArea()
                .overlay(alignment: .top) {
                    BookDetails()
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
                .opacity(show ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                animationContent = true
            }
            
            withAnimation(.easeInOut(duration: 0.35).delay(0.1)) {
                offsetAnimation = true
            }
        }
    }
    @ViewBuilder
    func BookDetails() -> some View {
        VStack(spacing: 0) {
            if !openDetail {
                HStack(spacing: 0) {
                    
                    Button {
                        
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button {
                        
                    } label: {
                        Label("Like", systemImage: "suit.heart")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button {
                        
                    } label: {
                        Label("Cart", systemImage: "cart.fill.badge.plus")
                            .font(.callout)
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity)
                }
            
            
                Divider()
                    .padding(.vertical, 25)
                
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
                            .frame(width: 22)
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
                        .foregroundColor(.primary.opacity(0.7))
                        .padding(.top)
                }
                .padding(.bottom, 100)
            }
            Button {
                
            } label: {
                Label("編集", systemImage: "pencil.line")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 45)
                    .padding(.vertical, 10)
                    .background {
                        Capsule()
                            .fill(Color.red.gradient)
                    }
                    .foregroundColor(.white)
            }
            .padding(.bottom, 15)
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
            
            Text("タグ　　　:　　 \(item.tag)")
                .padding(.bottom, 12)
            Text("在庫　　　:　　 \(item.inventory) 個")
            Text(item.price != 0 ? "価格　　　:　　 ¥ \(item.price)" : "価格　　　:　　   -")
                .padding(.bottom, 12)
            Text(item.totalInventory != 0 ?
                 "総在庫　　:　　 \(item.totalInventory) 個": "総在庫　　:　　   -  個")
            Text(item.totalAmount != 0 ?
                 "総売個数　:　　 \(item.totalAmount) 個" : "総売個数　:　　   - 個")
            Text(item.sales != 0 ?
                 "総売上　　:　　 ¥ \(item.sales)" : "総売上　　:　　   -")
                .padding(.bottom, 12)

            Text("登録日　　:　　 \(asTimesString(item.createTime))")
            Text("最終更新　:　　 \(asTimesString(item.updateTime))")
            
            Divider()
                .frame(width: 300)
                .padding(.top)

        } // VStack
        .frame(maxWidth: .infinity)
        .font(.callout)
        .fontWeight(.light)
        .opacity(0.6)
        .tracking(1)
        .lineLimit(1)
        .padding(.vertical, 10)
    }
    
    func asTimesString(_ time: Timestamp?) -> String {
        
        if let time = item.createTime {
            let formatter = DateFormatter()
            formatter.setTemplate(.date, .jaJP)
            return formatter.string(from: time.dateValue())
        } else {
            return "???"
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    @Namespace static var animation
    static var previews: some View {
        DetailView(show: .constant(true),
                   animation: animation,
                   item: testItem.first!)
    }
}
