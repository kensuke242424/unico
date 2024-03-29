//
//  DeletedAccountView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/24.
//

import SwiftUI

struct DeletedView: View {

    @EnvironmentObject var logInVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var navigationVM: NavigationViewModel

    var body: some View {
        
        VStack(spacing: 20) {
            
           Group {
                Text("アカウントの削除が完了しました。")
                Text("またのご利用をお待ちしております。")
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .tracking(3)
            .foregroundColor(.white)
            .opacity(0.7)
            
            Button("ログイン画面へ戻る") {
                withAnimation(.easeIn(duration: 0.4)) {
                    logInVM.rootNavigation = .logIn
                }
            }
            .padding(.top, 40)
        }
        .overlay {
            LogoMark()
                .scaleEffect(0.6)
                .opacity(0.7)
                .offset(y: -getRect().height / 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customSystemBackground()
        .navigationBarBackButtonHidden()
        .customNavigationTitle(title: "アカウント削除完了")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            print("アカウント削除画面の破棄を検知。ログイン画面に戻る")
            navigationVM.path.removeLast(navigationVM.path.count)
            logInVM.deleteAccountCheckFase = .start
        }
        
    }
}

struct DeletedAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeletedView()
    }
}
