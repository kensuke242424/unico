//
//  UpadateAddressView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/10.
//

import SwiftUI

struct UpdateAddressView: View {
    @EnvironmentObject var logInVM: LogInViewModel
    var body: some View {
        VStack {
            Text("メールアドレス更新画面")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customSystemBackground()
        .customBackButton()
        .navigationTitle("メールアドレスの変更")
        
    }
}

struct UpadateAddressView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateAddressView()
            .environmentObject(LogInViewModel())
    }
}
