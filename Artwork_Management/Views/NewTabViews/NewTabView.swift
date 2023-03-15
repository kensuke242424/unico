//
//  NewHomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import ResizableSheet

struct NewTabView: View {
    
    @State private var selectionTab: SelectionTab = .item
    
    @State private var imageBlur: CGFloat = 4

    var body: some View {

        NavigationStack {
            TabView(selection: $selectionTab) {
                NewHomeView()
                    .tag(SelectionTab.home)
                
                NewItemsView()
                    .tag(SelectionTab.item)
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
            .onChange(of: selectionTab) { _ in
                switch selectionTab {
                case .home:
                    withAnimation(.easeInOut(duration: 0.3)) { imageBlur = 0 }
                case .item:
                    withAnimation(.easeInOut(duration: 0.3)) { imageBlur = 4 }
                }
            }
        }
        
    } // body
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
