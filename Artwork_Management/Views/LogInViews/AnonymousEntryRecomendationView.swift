//
//  AnonymousEntryRecomendationView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/05/17.
//

import SwiftUI
import Firebase

struct AnonymousEntryRecomendationView: View {

    private enum UserEntryPath {
        case inputAddress
    }

    @EnvironmentObject var logInVM: AuthViewModel
    @EnvironmentObject var userVM : UserViewModel
    @Binding var isShow: Bool

    /// ユーザー登録ビューの画面遷移を管理するプロパティ
    @StateObject var userEntryNavigationVM = UserEntryNavigationViewModel()
    /// 利用規約とプライバシーポリシーへの同意を管理するチェックボタンに使用するプロパティ
    @State private var checkTermsAgree: Bool = true

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

                VStack(alignment: .leading) {
                    Text("今はアカウント登録せずに")
                    Text("お試しアカウントで始めますか？")
                }
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

                    Button("お試しで始める") {

                        // すでにアカウントを作成しログイン済みの場合は弾く
                        // if Auth.auth().currentUser != nil { return }
                        logInVM.resultSignInType = .signUp
                        logInVM.signUpAnonymously()

                        withAnimation(.easeInOut(duration: 0.5)) {
                            isShow.toggle()
                        }
                        withAnimation(.spring(response: 0.8).delay(0.5)) {
                            logInVM.userSelectedSignInType = .signUp
                            logInVM.createAccountFase      = .check
                            logInVM.selectProviderType     = .trial
                        }
                    }
                    .font(userDeviseSize == .small ? .callout : .body)
                    .buttonStyle(.borderedProminent)
                    .disabled(checkTermsAgree ? false : true)
                }
            }
        }
        .frame(width: getRect().width - 50, height: getRect().height)
        .background {
            ZStack {
                Color.userBlue1
                    .frame(width: getRect().width, height: getRect().height)
                    .ignoresSafeArea()

                BlurView(style: .systemThinMaterialDark)
                    .frame(width: getRect().width, height: getRect().height)
                    .opacity(0.5)
                    .ignoresSafeArea()
            }
        }
    }
}

struct AnonymousEntryRecomendationView_Previews: PreviewProvider {
    static var previews: some View {
        AnonymousEntryRecomendationView(isShow: .constant(true))
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel())
    }
}
