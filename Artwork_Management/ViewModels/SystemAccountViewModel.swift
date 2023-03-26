//
//  SystemAccountViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/26.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

class SystemAccountViewModel: ObservableObject {
    
    enum HandleUseReceivedEmailLink {
        case signIn, signUp, entryAccount, updateEmail, deleteAccount
    }
    // メールリンクによって受け取ったユーザリンクをどのように扱うかをハンドルするプロパティ
    @Published var handleUseReceivedEmailLink: HandleUseReceivedEmailLink = .signIn
    
    /// メールアドレス入力用のハーフシートを管理するプロパティ
    @Published var showEmailHalfSheet: Bool = false
    @Published var showEmailSheetBackground: Bool = false
    
    // 匿名アカウントから永久アカウントへの認証結果を管理するプロパティ
    @Published var resultAccountLink   : Bool = false
    @Published var showAccountLinkAlert: Bool = false
    
    // アカウントのメールアドレス設定関連の操作フローを管理するプロパティ
    @Published var defaultEmailCheckFase: DefaultEmailCheckFase = .start
    @Published var updateEmailCheckFase: UpdateEmailCheckFase = .success
    @Published var deleteAccountCheckFase: DeleteAccountCheckFase = .start
    
    @Published var addressReauthenticateResult: Bool = false
    
    func entryAccountByEmailLink(email: String, link: String) {
        
        let credential = EmailAuthProvider.credential(withEmail: email, link: link)
        
        Auth.auth().currentUser?.link(with: credential) { authData, error in
            if let error {
                // And error occurred during linking.
                print("アカウントリンク時にエラー発生")
                self.resultAccountLink = false
                self.showAccountLinkAlert.toggle()
                return
            }
            // The provider was successfully linked.
            // The phone user can now sign in with their phone number or email.
            print("アカウントリンク成功")
            self.resultAccountLink = true
            self.showAccountLinkAlert.toggle()
        }
    }
    
    func verifyInputEmailMatchesCurrent(email: String) async -> Bool {
        guard let user = Auth.auth().currentUser else  { return false }
        if user.email == email {
            return true
        } else  {
            return false
        }
    }
}
