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
    
    @Binding var inputTab: InputTab
    
    let passItem: Item?
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .navigationTitle("")
    }
}

struct NewEditItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewEditItemView(teamVM: TeamViewModel(),
                        userVM: UserViewModel(),
                        itemVM: ItemViewModel(),
                        tagVM : TagViewModel(),
                        inputTab: .constant(InputTab()),
                        passItem: nil)
    }
}
