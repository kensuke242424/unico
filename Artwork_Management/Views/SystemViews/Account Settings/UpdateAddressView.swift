//
//  UpadateAddressView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/10.
//

import SwiftUI

struct UpdateAddressView: View {
    var body: some View {
        VStack {
            Text("アカウント削除画面")
        }
        .customSystemBackground()
        .customBackButton()
        .navigationTitle("メールアドレスの変更")
        
    }
}

struct UpadateAddressView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateAddressView()
    }
}
