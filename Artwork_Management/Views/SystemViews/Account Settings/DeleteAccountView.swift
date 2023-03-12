//
//  DeleteAccountView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/10.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct DeleteAccountView: View {
    @StateObject var logInVM: LogInViewModel
    var body: some View {
        VStack {
            // Sign In With Apple...
//            SignInWithAppleButton(.continue) { request in
//                logInVM.handleSignInWithAppleRequest(request)
//            } onCompletion: { result in
//                let credencial = logInVM.getSignOutWithAppleCredential(result)
//                logInVM.signOutAndDeleteAccount(credencial: credencial)
//            }
//            .buttonStyle(.borderedProminent)
            
        }
        .customSystemBackground()
        .customBackButton()
        .navigationTitle("アカウントの削除")
        
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(logInVM: LogInViewModel())
    }
}
