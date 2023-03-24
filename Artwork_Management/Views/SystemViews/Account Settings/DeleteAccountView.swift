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
    
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var logInVM: LogInViewModel
    
    @State private var inputEmailAddress: String = ""
    
    var body: some View {
        VStack(spacing: 30) {

            VStack(alignment: .leading) {
                Text("※ unicoに登録されているアカウントデータ及び、\n「アイテム」「ユーザー」「チーム」データを削除します。")
                    .foregroundColor(.white)
                    .padding(.vertical)
                    
                Text("※ チーム内に他のメンバーが存在する場合、チーム内の\n 「アイテム」「タグ」を含めたチームデータは消去されずに\n   残ります。")
                    .foregroundColor(.orange)
            }
            .font(.caption)
            .opacity(0.6)
            .multilineTextAlignment(.leading)
            
            
            Text("アカウント削除を実行するために、あなたが当アカウントのユーザー本人であることを確認します。現在unicoに登録されているメールアドレスを入力して、本人確認メールからログインしてください。")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .opacity(0.7)
                .multilineTextAlignment(.leading)
                .padding(.top)
            
            Text("メールリンクからの本人認証が完了した時点で、アカウントの削除が実行されます。")
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
                Task {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        logInVM.systemAccountEmailCheckFase = .check
                    }

                    /// 入力されたアドレスが、登録アドレスと一致するか検証するメソッド
                    let matchesCheckResult = await logInVM.verifyInputEmailMatchesCurrent(email: inputEmailAddress)

                    if matchesCheckResult {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            logInVM.systemAccountEmailCheckFase = .sendEmail
                        }
                        // リンクメールを送る前に、認証リンクがどのように使われるかハンドルするために
                        // 「handleUseReceivedEmailLink」に値を設定しておく必要がある
                        logInVM.handleUseReceivedEmailLink = .deleteAccount
                        logInVM.sendEmailLink(email: inputEmailAddress)
                    } else {
                        hapticErrorNotification()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            logInVM.systemAccountEmailCheckFase = .notMatches
                        }
                    }
                }
            }
            HStack(spacing: 10) {
                Text(logInVM.systemAccountEmailCheckFase.faseText)
                    .foregroundColor(logInVM.systemAccountEmailCheckFase == .notMatches ||
                                     logInVM.systemAccountEmailCheckFase == .failure ? .red : .white)
                
                if logInVM.systemAccountEmailCheckFase == .check ||
                   logInVM.systemAccountEmailCheckFase == .waitDelete {
                   ProgressView()
                }
            }
            
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 30)
        .customSystemBackground()
        .customBackButton()
        .navigationTitle("アカウントの削除")
        // アカウント削除を検知したら、DeletedViewへ遷移
        .onChange(of: logInVM.systemAccountEmailCheckFase) { newValue in
            if newValue == .success {
                navigationVM.path.append(SystemAccountPath.deletedData)
            }
        }
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VStack {
                DeleteAccountView()
                    .environmentObject(NavigationViewModel())
                    .environmentObject(LogInViewModel())
            }
            .navigationTitle("アカウントの削除")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
        
    }
}
