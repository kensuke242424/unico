//
//  DefaultEmailCheckView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/24.
//

import SwiftUI

struct DefaultEmailCheckView: View {
    @EnvironmentObject var logInVM: LogInViewModel
    @State private var inputEmailAddress: String = ""
    var body: some View {
        VStack {
            Text("本人確認")
                .font(.title2)
                .fontWeight(.bold)
                .tracking(3)
                .foregroundColor(.white)
                .padding(.top, 100)
            
            Group {
                Text("現在unicoに登録されているメールアドレス宛に本人確認メールを送信します。")
                Text("メールリンクからの本人認証が完了したら、新しいメールアドレスへの変更処理に移ります。")
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .opacity(0.7)
            .multilineTextAlignment(.leading)
            .padding(.top)
            
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
                        
                        Text(inputEmailAddress.isEmpty ? "登録済のメールアドレスを入力" : "")
                            .foregroundColor(.black)
                            .opacity(0.4)
                    }
                }
                .padding()
            
            Button("メールを送信") {
                Task {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        logInVM.systemAccountEmailCheckFase = .check
                    }
                    
                    /// 入力されたアドレスが、登録アドレスと一致するか検証するメソッド
                    let matchesCheckResult = await logInVM.verifyInputEmailMatchesCurrent(email: inputEmailAddress)

                    if matchesCheckResult {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            logInVM.handleUseReceivedEmailLink = .updateEmail
                            logInVM.systemAccountEmailCheckFase = .sendEmail
                        }
                        // リンクメールを送る前に、認証リンクがどのように使われるかハンドルするために
                        // 「handleUseReceivedEmailLink」に値を設定しておく必要がある
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
            .padding()
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .customSystemBackground()
        .customBackButton()
        .navigationTitle("メールアドレスの変更")
        
    }
}

struct DefaultEmailCheckView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultEmailCheckView()
            .environmentObject(LogInViewModel())
    }
}
