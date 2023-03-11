//
//  DeleteAccountView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/10.
//

import SwiftUI

struct DeleteAccountView: View {
    var body: some View {
        VStack {
            Text("アカウント削除画面")
        }
        .customSystemBackground()
        .customBackButton()
        .navigationTitle("アカウントの削除")
        
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView()
    }
}
