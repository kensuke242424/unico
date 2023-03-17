//
//  NewEditItemView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/17.
//

import SwiftUI

struct NewEditItemView: View {
    
    @StateObject var teamVM: TeamViewModel
    @StateObject var userVM: UserViewModel
    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM : TagViewModel
    
    let passItem: Item?
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
            .frame(width: size.width, height: size.height)
            .navigationTitle(passItem == nil ? "アイテム追加" : "アイテム編集")
        }
        .onAppear {
            print("アイテムエディット画面生成")
        }
        
    }
}

struct NewEditItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewEditItemView(teamVM: TeamViewModel(),
                        userVM: UserViewModel(),
                        itemVM: ItemViewModel(),
                        tagVM : TagViewModel(),
                        passItem: nil)
    }
}
