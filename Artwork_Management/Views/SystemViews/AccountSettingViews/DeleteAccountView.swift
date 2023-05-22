//
//  DeleteAccountView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/10.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

enum DeleteAccountCheckFase {
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

struct DeleteAccountView: View {
    
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var logInVM: LogInViewModel
    
    @State private var inputEmailAddress: String = ""

    @State private var showEmailLinkHalfSheet: Bool = false
    @State private var showFinalCheckDeletionAlert: Bool = false

    // ビューが現在表示されているかどうかを検知する
    @Environment(\.isPresented) private var isPresented
    
    var body: some View {

        VStack(spacing: 30) {

            VStack(alignment: .leading) {
                Text("※ unicoに登録されているアカウントデータ及び、\n「アイテム」「ユーザー」「チーム」データを削除します。")
                    .foregroundColor(.red)
                    .padding(.vertical)
                    
                Text("※ チーム内に他のメンバーが存在する場合、チーム内の\n 「アイテム」「タグ」を含めたチームデータは消去されずに\n   残ります。")
                    .foregroundColor(.orange)
            }
            .font(.footnote)
            .opacity(0.8)
            .multilineTextAlignment(.leading)
            
            
            Text("あなたが当アカウントのユーザー本人であることを確認する再認証が必要な場合があります。アドレス入力画面が表示された場合は、現在unicoに登録されているメールアドレスを入力して、届いた認証メールからログインしてください。")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .opacity(0.7)
                .multilineTextAlignment(.leading)
                .padding(.top)
            
            Button("データ削除へ進む", role: .destructive) {
                Task {
                    // ユーザーのメールアドレスが認証済み状態かどうか確認
                    let verifiedCheckResult = logInVM.verifiedEmailCheck()

                    if verifiedCheckResult {
                        showFinalCheckDeletionAlert.toggle()
                    } else {
                        // リンクメールを送る前に、認証リンクがどのように使われるかハンドルするために
                        // 「handleUseReceivedEmailLink」に値を設定しておく必要がある
                        logInVM.handleUseReceivedEmailLink = .deleteAccount
                        withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                            logInVM.showEmailHalfSheet = true
                        }
                    }

                    // ⬆︎の処理が問題なければ⬇︎の処理は消す
//                    if matchesCheckResult {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            logInVM.deleteAccountCheckFase = .sendEmail
//                        }
                        // リンクメールを送る前に、認証リンクがどのように使われるかハンドルするために
                        // 「handleUseReceivedEmailLink」に値を設定しておく必要がある
//                        logInVM.handleUseReceivedEmailLink = .deleteAccount
//                        logInVM.sendEmailLink(email: inputEmailAddress)
//                    } else {
//                        hapticErrorNotification()
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            logInVM.deleteAccountCheckFase = .notMatches
//                        }
//                    }
                }
            }
            .alert("確認", isPresented: $showFinalCheckDeletionAlert) {
                Button("データ削除", role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showFinalCheckDeletionAlert.toggle()
                        logInVM.deleteAccountCheckFase = .check
                    }
                }
            } message: {
                Text("アカウントデータを削除します。本当によろしいですか？")
            }

            HStack(spacing: 10) {
                Text(logInVM.deleteAccountCheckFase.faseText)
                    .foregroundColor(logInVM.deleteAccountCheckFase == .notMatches ||
                                     logInVM.deleteAccountCheckFase == .failure ? .red : .white)
                
                if logInVM.deleteAccountCheckFase == .check ||
                   logInVM.deleteAccountCheckFase == .waitDelete {
                   ProgressView()
                }
            }
            
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .overlay {
            if logInVM.showEmailHalfSheet {
                LogInAddressSheetView()
            }
        }
        .customSystemBackground()
        .customBackButton()
        .navigationTitle("アカウントの削除")
        // アカウント削除を検知したら、DeletedViewへ遷移
        .onChange(of: logInVM.deleteAccountCheckFase) { newValue in
            if newValue == .success {
                navigationVM.path.append(SystemAccountPath.deletedData)
            }
        }
        .onChange(of: isPresented) { newValue in
            if !newValue {
                print("アカウント削除画面、破棄")
                // 画面破棄の際に、メール認証シートが表示中であれば連動して閉じる
                withAnimation(.spring(response: 0.1, dampingFraction: 1.0, blendDuration: 0.5)) {
                    logInVM.showEmailHalfSheet = false
                }
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
