//
//  NewHomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import ResizableSheet

struct NewTabView: View {
    
    /// View Propertys
    @State private var selectionTab: Tab = .item
    @State private var animationTab: Tab = .item
    @State private var animationOpacity: CGFloat = 1
    @State private var animationScale: CGFloat = 1
    @State private var scrollProgress: CGFloat = .zero

    var body: some View {

        GeometryReader {
            let size = $0.size
            
            NavigationStack {
                
                VStack {
                    
                    TabIndicatorView()
                    
                    Spacer(minLength: 0)
                    
                    TabView(selection: $selectionTab) {
                        NewHomeView()
                            .tag(Tab.home)
                            .offsetX(selectionTab == Tab.home) { rect in
                                let minX = rect.minX
                                let pageOffset = minX - (size.width * CGFloat(Tab.home.index))
                                let pageProgress = pageOffset / size.width
                                
                                scrollProgress = max(min(pageProgress, 0), -CGFloat(Tab.allCases.count - 1))
                                animationOpacity = 1 - -scrollProgress
                            }
                        
                        NewItemsView()
                            .tag(Tab.item)
                            .offsetX(selectionTab == Tab.item) { rect in
                                let minX = rect.minX
                                let pageOffset = minX - (size.width * CGFloat(Tab.item.index))
                                let pageProgress = pageOffset / size.width
                                
                                scrollProgress = max(min(pageProgress, 0), -CGFloat(Tab.allCases.count - 1))
                                animationOpacity = -scrollProgress
                            }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .background {
                    ZStack {
                        GeometryReader { proxy in
                            Image("background_1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .ignoresSafeArea()
                                .blur(radius: min((-scrollProgress * 4), 4), opaque: true)
                        }
                    }
                }
                .ignoresSafeArea()
                .onChange(of: selectionTab) { _ in
                    switch selectionTab {
                    case .home:
                        withAnimation(.easeInOut(duration: 0.2)) { animationTab = .home }
                    case .item:
                        withAnimation(.spring(response: 0.2)) { animationTab = .item }
                    }
                }
            } // NavigationStack
        } // GeometryReader
        

    } // body
    @ViewBuilder
    func TabIndicatorView() -> some View {
        GeometryReader {
            let size = $0.size
            let tabWidth = size.width / 3
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Text(tab.rawValue)
                        .font(.title3.bold())
                        .tracking(4)
                        .scaleEffect(animationTab == tab ? 1.0 : 0.5)
                        .foregroundColor(animationTab == tab ? .primary : .gray)
                        .frame(width: tabWidth)
                        .contentShape(Rectangle())
                        .padding(.top, 60)
                }
            }
            .frame(width: CGFloat(Tab.allCases.count) * tabWidth)
            .padding(.leading, tabWidth)
            .offset(x: scrollProgress * tabWidth)
            .overlay {
                HStack {
                    /// Homeタブに移動した時に表示するチームアイコン
                    if animationTab == .home {
                        Circle()
                            .frame(width: 35, height: 35)
                            .transition(.asymmetric(
                                insertion: AnyTransition.opacity.combined(with: .offset(x: -20, y: 0)),
                                removal: AnyTransition.opacity.combined(with: .offset(x: -20, y: 0))
                            ))
                            .opacity(animationOpacity)
                    }
                    
                    Spacer()
                    
                    /// Itemタブに移動した時に表示するアイテム追加タブボタン
                    if animationTab == .item {
                        Button {
                            
                        } label: {
                            Image(systemName: "shippingbox.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.primary)
                                .frame(width: 30, height: 30)
                                .opacity(animationOpacity)
                        }
                        .transition(.asymmetric(
                            insertion: AnyTransition.opacity.combined(with: .offset(x: 20, y: 0)),
                            removal: AnyTransition.opacity.combined(with: .offset(x: 20, y: 0))
                        ))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
            }
        }
        .frame(height: 100)
        .background(
            Color.clear
                .overlay {
                    BlurView(style: .systemUltraThinMaterial)
                        .ignoresSafeArea()
                        .opacity(min(-scrollProgress, 1))
                }
        )
    }
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

        return NewTabView()
            .environment(\.resizableSheetCenter, resizableSheetCenter)

    }
}
