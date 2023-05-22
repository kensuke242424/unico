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
    case start, failure, excution
}

struct DeleteAccountView: View {
    
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var logInVM: LogInViewModel

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
                            // 試しデバッグ用
                        } else {
                            // リンクメールを送る前に、認証リンクがどのように使われるかハンドルするために
                            // 「handleUseReceivedEmailLink」に値を設定しておく必要がある
                            logInVM.handleUseReceivedEmailLink = .deleteAccount
                            withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                                logInVM.showEmailHalfSheet = true
                            }
                        }
                    }
                }
                .alert("確認", isPresented: $showFinalCheckDeletionAlert) {
                    Button("データ削除", role: .destructive) {
                        // 削除実行画面へ遷移
                        navigationVM.path.append(SystemAccountPath.excutionDelete)
                    }
                } message: {
                    Text("アカウントを削除します。本当によろしいですか？")
                }

            if logInVM.deleteAccountCheckFase == .failure {
                Text("アカウント削除時にエラーが発生しました。")
                    .foregroundColor(.orange)
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
        .customNavigationTitle(title: "アカウントの削除")
        .toolbarColorScheme(.dark)
        // アカウント削除画面から離れた際に、メール認証シートが表示中であれば連動して閉じる
        .onChange(of: isPresented) { newValue in
            if !newValue {
                print("アカウント削除画面、破棄")
                withAnimation(.spring(response: 0.1, dampingFraction: 1.0, blendDuration: 0.5)) {
                    logInVM.showEmailHalfSheet = false
                }
            }
        }
        // メールリンクによるアドレス再認証がOKだったら、最終確認アラートの表示
        .onChange(of: logInVM.addressReauthenticateResult) { result in
            if result == true {
                withAnimation(.spring(response: 0.1, dampingFraction: 1.0, blendDuration: 0.5)) {
                    logInVM.showEmailHalfSheet = false
                }
                showFinalCheckDeletionAlert.toggle()
            }
        }
        // アカウント削除の最終確認が取れたら、DeletingViewへ遷移
        .onChange(of: logInVM.deleteAccountCheckFase) { newValue in
            if newValue == .excution {
                navigationVM.path.append(SystemAccountPath.excutionDelete)
            }
        }
        // 再認証結果通知プロパティの初期化
        .onDisappear() {
            logInVM.addressReauthenticateResult = false
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
