//
//  SuccessUpdateEmailView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/26.
//

import SwiftUI
import FirebaseAuth

struct SuccessUpdateAddressView: View {
    
    @EnvironmentObject var navigationVM: NavigationViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("新しい登録メールアドレス")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.top, 100)
            
            Text(Auth.auth().currentUser?.email ?? "???")
                .foregroundColor(.white.opacity(0.7))
            
            Text("メールアドレスの更新が完了しました。")
                .foregroundColor(.white)
                .padding(.top)
            
            Button("完了") {
                // アカウント設定画面まで戻る
                navigationVM.path.removeLast(3)
            }
            .buttonStyle(.bordered)
            .padding(.top, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationTitle(title: "更新完了")
        .customSystemBackground()
    }
}

struct SuccessUpdateEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessUpdateAddressView()
    }
}
