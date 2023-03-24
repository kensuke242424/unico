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
    
    @EnvironmentObject var logInVM: LogInViewModel
    
    @State private var inputEmailAddress: String = ""
    
    var body: some View {
        VStack(spacing: 30) {

            VStack(alignment: .leading) {
                Text("※ unicoに登録されているアカウントデータ及び、\n「アイテム」「ユーザー」「チーム」データをを削除します。")
                    .foregroundColor(.white)
                    .padding(.vertical)
                    
                Text("※ チーム内に他のメンバーが存在する場合、チーム内の\n 「アイテム」「タグ」を含めたチームデータは消去されずに\n   残ります。")
                    .foregroundColor(.orange)
            }
            .font(.caption)
            .opacity(0.5)
            .multilineTextAlignment(.leading)
            
            
            Text("アカウント削除を実行するために、あなたが当アカウントのユーザー本人であることを確認します。\n現在unicoに登録されているメールアドレスを入力して、本人確認メールからログインしてください。")
                .font(.subheadline)
                .foregroundColor(.white)
                .opacity(0.7)
                .multilineTextAlignment(.leading)
                .padding(.top)
            
            Text("メールからのログイン認証が完了した時点で、アカウントの削除が実行されます。")
                .foregroundColor(.red)
                .font(.caption)
                .opacity(0.7)
                .multilineTextAlignment(.leading)
            
            TextField("", text: $inputEmailAddress)
                .textInputAutocapitalization(.never)
                .foregroundColor(.black)
                .padding()
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .opacity(0.8)
                            .frame(height: 32)
                        
                        Text(inputEmailAddress.isEmpty ? "登録メールアドレスを入力" : "")
                            .foregroundColor(.black)
                            .opacity(0.4)
                    }
                }
            
            Button("メールを送信") {
                logInVM.sendEmailLink(email: inputEmailAddress)
            }
            
            if logInVM.addressSignInFase == .check {
                
            }
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 30)
        .customSystemBackground()
        .customBackButton()
        .navigationTitle("アカウントの削除")
        
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VStack {
                DeleteAccountView()
                    .environmentObject(LogInViewModel())
            }
            .navigationTitle("アカウントの削除")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
        
    }
}
