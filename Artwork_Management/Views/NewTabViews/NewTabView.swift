//
//  NewHomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import ResizableSheet

/// 各タブの選択を管理する
enum SelectionTab {
    case home
    case item
}

struct NewTabView: View {
    
    @State private var selectionTab: SelectionTab = .item

    var body: some View {

        NavigationStack {
            TabView(selection: $selectionTab) {
                NewHomeView()
                    .tag(SelectionTab.home)
                
                NewItemsView()
                    .tag(SelectionTab.item)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
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
