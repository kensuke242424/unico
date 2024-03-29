//
//  UserEntryRecommendationView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/13.
//

import SwiftUI
import Firebase

struct UserEntryRecommendationView: View {

    private enum UserEntryPath {
        case inputAddress
    }
    
    @EnvironmentObject var logInVM: AuthViewModel
    @EnvironmentObject var userVM : UserViewModel
    @Binding var isShow: Bool

    /// ユーザー登録ビューの画面遷移を管理するプロパティ
    @StateObject var userEntryNavigationVM = UserEntryNavigationViewModel()
    @State private var showExistEntryAlert: Bool = false
    @State private var checkTermsAgree: Bool = true
    @State private var showNotYetAgreeAlert: Bool = false
    
    var body: some View {

        VStack(spacing: userDeviseSize == .small ? 30 : 40) {

            LogoMark()
                .frame(height: 30)
                .scaleEffect(0.45)
                .opacity(0.4)
                .padding(.bottom)

            // アカウント登録時の機能説明を保持するView
            VStack(alignment: .leading, spacing: userDeviseSize == .small ? 20 : 30) {

                VStack(alignment: .leading) {
                    Text("アカウント登録をすると")
                    Text("以下の機能が解放されます!!")
                }
                .font(userDeviseSize == .small ? .title3 : .title2)
                .fontWeight(.bold)
                .tracking(3)
                .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 20) {
                    Label("他のユーザーのチームへの参加", systemImage: "person.2.fill")
                    Label(" 自分のチームにユーザーを招待", systemImage: "person.wave.2.fill")
                        .offset(x: 2)
                    Label(" 永続的なデータの保存", systemImage: "cube.transparent.fill")
                }
                .font(userDeviseSize == .small ? .footnote : .subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.yellow)
                .tracking(1)
                .background {

                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.userBlue1)
                        .opacity(0.7)
                        .scaleEffect(1.4)
                        .offset(x: 15)
                }
                .offset(x: 20)
                .padding(.vertical)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("※アカウント登録はお試し期間中いつでも可能です。")
                        Text("  登録が完了すると、お試しアカウントから")
                        Text("  登録済みアカウントに切り替わります。")
                        Text("  管理していたアイテムやデータは全て引き継がれます。")
                    }
                    Text("※アカウント登録による料金の発生は一切ありません。")
                }
                .font(userDeviseSize == .small ? .caption2 : .footnote)
                .foregroundColor(.white.opacity(0.8))
            }

            // 下部の選択ボタンを保有するView
            VStack(spacing: userDeviseSize == .small ? 15 : 30) {

                TermsAndPrivacyView(isCheck: $checkTermsAgree)

                Text("アカウント登録を行いますか？")
                    .font(userDeviseSize == .small ? .callout : .body)
                    .foregroundColor(.white)
                    .tracking(3)
                    .padding(.top)

                HStack(spacing: 40) {
                    Button("戻る") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShow.toggle()
                        }
                    }
                    .font(userDeviseSize == .small ? .callout : .body)
                    .buttonStyle(.bordered)
                    .foregroundColor(.white)
                    Button("\(Image(systemName: "envelope.fill")) 登録") {

                        // すでにアカウント登録済みの場合はアラートを表示して処理終了
                        if !userVM.isAnonymous {
                            showExistEntryAlert.toggle()
                            return
                        }

                        if !checkTermsAgree {
                            showNotYetAgreeAlert.toggle()
                            return
                        }

                        withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                            logInVM.handleUseReceivedEmailLink = .entryAccount
                            /// ⬇︎関係ない値のように見えるが、メソッドのハンドリングに使われる値のため、消さない！！
                            logInVM.userSelectedSignInType = .signUp
                            logInVM.showEmailHalfSheet.toggle()
                        }
                    }
                    .font(userDeviseSize == .small ? .callout : .body)
                    .buttonStyle(.borderedProminent)
                    .disabled(checkTermsAgree ? false : true)
                }
            }
            // 登録済みのユーザーが登録ボタンを押した場合に表示するアラート
            .alert("登録済み", isPresented: $showExistEntryAlert) {
                Button("OK") {
                    showExistEntryAlert.toggle()
                }
            } message: {
                Text("\(userVM.user?.name ?? "No Name")さんのアカウントはすでに登録済みです。")
            }
            .alert("", isPresented: $showNotYetAgreeAlert) {
                Button("OK") {}
            } message: {
                Text("利用規約とプライバシーポリシーの同意が必要です。")
            }
            // アカウント登録の結果をユーザーに知らせるアラート
            .alert(logInVM.resultAccountLink ? "登録完了" : "登録失敗",
                   isPresented: $logInVM.showAccountLinkAlert) {
                Button("OK") {
                    logInVM.showAccountLinkAlert.toggle()
                    if logInVM.resultAccountLink {
                        isShow.toggle()
                    }
                }
            } message: {
                if logInVM.resultAccountLink {
                    Text("アカウントの登録に成功しました！引き続き、unicoをよろしくお願い致します。")
                } else {
                    Text("アカウント登録時にエラーが発生しました。もう一度試してみてください。")
                }
            } // alert
            // アカウントの登録を検知したら、匿名状態を確認するメソッドを実行して状態を更新する(ビューを更新するため)
            .onChange(of: logInVM.resultAccountLink) { result in
                if result == true {
//                    userVM.isAnonymousCheck()
                }
            }
        }
        .frame(width: getRect().width - 50, height: getRect().height)
        .overlay {
            if logInVM.showEmailHalfSheet {
                LogInAddressSheetView(useType: .entryAccount)
            }
        }
        .background {
            ZStack {
                Color.userBlue1
                    .frame(width: getRect().width, height: getRect().height)
                //                        .opacity(0.7)
                    .ignoresSafeArea()

                BlurView(style: .systemThinMaterialDark)
                    .frame(width: getRect().width, height: getRect().height)
                    .opacity(0.5)
                    .ignoresSafeArea()
            }
        }
    }
}

struct UserEntryRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        UserEntryRecommendationView(isShow: .constant(true))
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel())
    }
}
