//
//  AccountView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct SystemView: View {
    var body: some View {

        VStack {
            AccountIconView()

            SystemListView()
        }


    } // body
} // View

struct SystemView_Previews: PreviewProvider {
    static var previews: some View {
        SystemView()
    }
}
