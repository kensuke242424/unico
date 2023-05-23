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

    @EnvironmentObject var logInVM: LogInViewModel
    @EnvironmentObject var userVM : UserViewModel
    @Binding var isShow: Bool

    /// ユーザー登録ビューの画面遷移を管理するプロパティ
    @StateObject var userEntryNavigationVM = UserEntryNavigationViewModel()

    var body: some View {

        VStack(spacing: 40) {

            LogoMark()
                .frame(height: 30)
                .scaleEffect(0.45)
                .opacity(0.4)
                .padding(.bottom)

            // アカウント登録時の機能説明を保持するView
            VStack(alignment: .leading, spacing: 30) {

                VStack(alignment: .leading) {
                    Text("アカウント登録をすると\n以下の機能が解放されます!!")
                }
                .font(.title2)
                .fontWeight(.bold)
                .tracking(3)
                .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 20) {
                    Label("他のユーザーのチームへの参加", systemImage: "person.2.fill")
                    Label(" 自分のチームにユーザーを招待", systemImage: "person.wave.2.fill")
                        .offset(x: 2)
                    Label(" 永続的なデータの保存", systemImage: "cube.transparent.fill")
                }
                .font(.subheadline)
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
                    Text("※アカウント登録はお試し期間中いつでも可能です。\n  登録が完了すると、お試しアカウントから\n  登録済みアカウントに切り替わります。管理していた\n  アイテムやデータは全て引き継がれます。")
                        .foregroundColor(.white.opacity(0.8))

                }
                .font(.footnote)
            }

            // 下部の選択ボタンを保有するView
            VStack(spacing: 30) {
                Text("今はアカウント登録せずに\nお試しアカウントで始めますか？")
                    .foregroundColor(.white)
                    .tracking(3)
                    .padding(.top)

                HStack(spacing: 40) {
                    Button("戻る") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShow.toggle()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.white)

                    Button("お試しで始める") {

                        if userVM.isAnonymous {
                            // すでにお試しアカウントでアプリを始めている場合の処理
                            withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                                logInVM.handleUseReceivedEmailLink = .entryAccount
                                /// ⬇︎関係ない値のように見えるが、メソッドのハンドリングに使われる値のため、消さない！！
                                logInVM.userSelectedSignInType = .signUp
                                logInVM.showEmailHalfSheet.toggle()
                            }

                        } else {
                            // アプリをまだ始めてなくて、ログイン画面からのアクセスの場合の処理
                            // すでにアカウントを作成しログイン済みの場合は弾く
                            if Auth.auth().currentUser != nil { return }
                            logInVM.resultSignInType = .signUp
                            logInVM.signInAnonymously()

                            withAnimation(.easeInOut(duration: 0.5)) {
                                isShow.toggle()
                            }
                            withAnimation(.spring(response: 0.8).delay(0.5)) {
                                logInVM.userSelectedSignInType = .signUp
                                logInVM.createAccountFase      = .check
                                logInVM.selectProviderType     = .trial
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(width: getRect().width - 50, height: getRect().height)
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

struct AnonymousEntryRecomendationView_Previews: PreviewProvider {
    static var previews: some View {
        AnonymousEntryRecomendationView(isShow: .constant(true))
            .environmentObject(LogInViewModel())
            .environmentObject(UserViewModel())
    }
}
