//
//  AccountView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct SystemView: View {
    @StateObject var itemVM: ItemViewModel
    var body: some View {

        VStack {

            AccountIconView()

            SystemListView()

        } // VStack
    } // body
} // View

struct SystemView_Previews: PreviewProvider {
    static var previews: some View {
        SystemView(itemVM: ItemViewModel())
    }
}
