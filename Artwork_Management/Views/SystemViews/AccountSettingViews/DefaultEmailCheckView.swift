//
//  DefaultEmailCheckView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/24.
//

import SwiftUI

enum DefaultEmailCheckFase {
    case start, check, failure, notMatches, sendEmail, waitDelete, success
    
    var faseText: String {
        switch self {
        case .start:
            return ""
        case.check:
            return "アドレスをチェックしています..."
        case .notMatches:
            return "登録されているアドレスと一致しません。"
        case .failure:
            return "エラーが発生しました。"
        case .sendEmail:
            return "入力アドレスにメールを送信しました。"
        case .waitDelete:
            return "アカウントの削除を実行しています..."
        case .success:
            return "アカウントの削除が完了しました。"
        }
    }
}

struct DefaultEmailCheckView: View {
    
    @EnvironmentObject var logInVM: LogInViewModel
    @EnvironmentObject var navigationVM: NavigationViewModel
    
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
                        logInVM.defaultEmailCheckFase = .check
                    }
                    
                    /// 入力されたアドレスが、登録アドレスと一致するか検証するメソッド
                    let matchesCheckResult = await logInVM.verifyInputEmailMatchesCurrent(email: inputEmailAddress)

                    if matchesCheckResult {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            logInVM.handleUseReceivedEmailLink = .updateEmail
                            logInVM.defaultEmailCheckFase = .sendEmail
                        }
                        // リンクメールを送る前に、認証リンクがどのように使われるかハンドルするために
                        // 「handleUseReceivedEmailLink」に値を設定しておく必要がある
                        logInVM.sendEmailLink(email: inputEmailAddress, useType: .updateEmail)
                    } else {
                        hapticErrorNotification()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            logInVM.defaultEmailCheckFase = .notMatches
                        }
                    }
                }
            }
            HStack(spacing: 10) {
                Text(logInVM.defaultEmailCheckFase.faseText)
                    .foregroundColor(logInVM.defaultEmailCheckFase == .notMatches ||
                                     logInVM.defaultEmailCheckFase == .failure ? .red : .white)
                
                if logInVM.defaultEmailCheckFase == .check ||
                   logInVM.defaultEmailCheckFase == .waitDelete {
                   ProgressView()
                }
            }
            .padding()
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .customSystemBackground()
        .customBackButton()
        .customNavigationTitle(title: "メールアドレスの変更")
        // メールリンクによる再認証結果「addressReauthenticateResult」のtrueを検知したら、アドレス更新画面へ遷移
        .onChange(of: logInVM.addressReauthenticateResult) { newValue in
            if newValue {
                navigationVM.path.append(SystemAccountPath.updateEmail)
            }
        }
    }
}

struct DefaultEmailCheckView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultEmailCheckView()
            .environmentObject(LogInViewModel())
    }
}
