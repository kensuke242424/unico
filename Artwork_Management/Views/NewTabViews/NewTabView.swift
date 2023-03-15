//
//  NewHomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import ResizableSheet

struct NewTabView: View {
    
    @State private var selectionTab: Tab = .item
    
    @State private var scrollProgress: CGFloat = .zero
    @State private var imageBlur: CGFloat = 4

    var body: some View {

        GeometryReader {
            let size = $0.size
            
            NavigationStack {
                VStack {
                    TabIndicatorView()
                    
                    TabView(selection: $selectionTab) {
                        NewHomeView()
                            .tag(Tab.home)
                            .offsetX(selectionTab == Tab.home) { rect in
                                let minX = rect.minX
                                let pageOffset = minX - (size.width * CGFloat(Tab.home.index))
                                print(pageOffset)
                                
                                let pageProgress = pageOffset / size.width
                                scrollProgress = max(min(pageProgress, 0), -CGFloat(Tab.allCases.count - 1))
                            }
                        
                        NewItemsView()
                            .tag(Tab.item)
                            .offsetX(selectionTab == Tab.item) { rect in
                                let minX = rect.minX
                                let pageOffset = minX - (size.width * CGFloat(Tab.item.index))
                                print(pageOffset)
                                
                                let pageProgress = pageOffset / size.width
                                scrollProgress = max(min(pageProgress, 0), -CGFloat(Tab.allCases.count - 1))
                            }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .background {
                        ZStack {
                            GeometryReader { proxy in
                                Image("background_4")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .ignoresSafeArea()
                                    .blur(radius: imageBlur)
                            }
                        }
                    }
                    .ignoresSafeArea()
                }
                .onChange(of: selectionTab) { _ in
                    switch selectionTab {
                    case .home:
                        withAnimation(.easeInOut(duration: 0.3)) { imageBlur = 0 }
                    case .item:
                        withAnimation(.easeInOut(duration: 0.3)) { imageBlur = 4 }
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
                        .foregroundColor(selectionTab == tab ? .primary : .gray)
                        .frame(width: tabWidth)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectionTab = tab
                            }
                        }
                }
            }
            .frame(width: CGFloat(Tab.allCases.count) * tabWidth)
            .padding(.leading, tabWidth)
            .offset(x: scrollProgress * tabWidth)
        }
        .frame(height: 40)
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
