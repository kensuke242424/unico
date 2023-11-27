//
//  RootView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/10.
//

import SwiftUI
import Firebase
import FirebaseDynamicLinks
import ResizableSheet

enum RootNavigation {
    case logIn, fetch, join, home
}

struct RootView: View {

    // ----- ResizableSheetを起動するために必要 -------
    var windowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene
    }
    var resizableSheetCenter: ResizableSheetCenter? {
        windowScene.flatMap(ResizableSheetCenter.resolve(for:))
    }
    // -----  -------  -------  -------  -------

    private struct PreloadProperty {
        var startPreload: Bool = false
        var inputTab    : InputTab = InputTab()
        var captureImage: UIImage?
        var showSheet   : Bool = false
    }
    
    @EnvironmentObject var progressVM: ProgressViewModel
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tagVM: TagViewModel
    @EnvironmentObject var preloadVM: PreloadViewModel
    @EnvironmentObject var backgroundVM: BackgroundViewModel

    @EnvironmentObject var itemVM: ItemViewModel
    @StateObject var cartVM: CartViewModel = CartViewModel()

    @State private var isShowStandBy: Bool = false
    @State private var showLogInAlert: Bool = false
    
    @State private var preloads: PreloadProperty = PreloadProperty()

    @AppStorage("applicationDarkMode") var applicationDarkMode: Bool = true

    var body: some View {

        ZStack {
            switch authVM.rootNavigation {
            case .logIn:
                LogInView()

            case .fetch:
                CubesProgressView()

            case .join:
                CubesProgressView()
                CreateAndJoinTeamView()

            case .home:
                ParentTabView(cartVM: cartVM)
                    .environment(\.resizableSheetCenter, resizableSheetCenter)
            }
        } // ZStack
        .preferredColorScheme(applicationDarkMode ? .dark : .light)
        .overlay {
            if progressVM.showCubesProgress {
                CubesProgressView()
            }
        }
        .overlay {
            if progressVM.showLoading {
                CustomLoadingView()
            }
        }
        /// プリロードView
        /// 一度ロードしたViewはキャッシュが作られて初回時のView表示が軽くなる仕様を使う
        .background {
            if preloads.startPreload {
                Group {
                    ItemTabView(cartVM: cartVM, inputTab: $preloads.inputTab)
                    ItemEditingView(passItem: nil)
                    CreateAndJoinTeamView()
                    PHPickerView(captureImage: $preloads.captureImage, isShowSheet: $preloads.showSheet)
                }
                .opacity(0.01)
            }
        }
        .onAppear {
            preloads.startPreload = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                preloads.startPreload = false
            }
        }

        // ☑️全データのフェッチ処理☑️
        .onChange(of: authVM.rootNavigation) { navigation in
            
            if navigation == .fetch {
                Task {
                    do {
                        /// MEMO: スナップショットはasync/awaitに対応してないため、
                        /// 先に取得しておく必要がある「user」と「joins」をasync/awaitメソッドで取得。
                        /// 取得に成功すれば、以降のデータ取得が進む。
                        await userVM.fetchUser()
                        /// ユーザーデータの所得ができなければ、ログイン画面に遷移
                        guard let user = userVM.user else {
                            authVM.rootNavigation = .logIn
                            return
                        }

                        await userVM.getJoinTeams()

                        /// チームデータを持っていなければ、チーム追加画面へ遷移
                        if userVM.joins.isEmpty {
                            print("参加チーム無し。チーム作成画面へ遷移")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 1)) {
                                    authVM.rootNavigation = .join
                                    teamVM.isShowCreateAndJoinTeam.toggle()
                                }
                            }
                            return
                        }
                        
                        /// 最後にログインしたチームIdをもとに、対象のチームの全データを取得
                        guard let lastLogInTeamID = user.lastLogIn else { return }
                        print("ログインするチームのID: \(lastLogInTeamID)")

                        await tagVM.tagsLister(teamID: lastLogInTeamID)

                        // ---- ユーザー関連データをリスニング ----
                        await userVM.userListener()
                        await userVM.joinsListener()
                        // ---- チーム関連データをリスニング ----
                        await teamVM.teamListener(id: lastLogInTeamID)
                        await teamVM.membersListener(id: lastLogInTeamID)
                        await itemVM.itemsListener(id: lastLogInTeamID)
                        
                        /// ホーム画面へ遷移
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 1)) {
                                progressVM.showCubesProgress = false
                                authVM.rootNavigation = .home
                                /// ログインが完了したら、LogInViewの操作フローを初期化
                                authVM.createAccountFase          = .start
                                authVM.userSelectedSignInType     = .start
                                authVM.selectProviderType         = .start
                                authVM.addressSignInFase          = .start
                            }
                        }
                    }
                } // Task
            }
        }

        // Auth check...
        .onAppear {
            if Auth.auth().currentUser != nil {
                print("unicoのアカウントデータが存在しました。データフェッチを開始")
                authVM.rootNavigation = .fetch
            } else {
                print("unicoのアカウントデータが存在しません。ログイン画面に遷移")
                progressVM.showCubesProgress.toggle()

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        progressVM.showCubesProgress.toggle()
                    }
                }
            }
        }
        /// 📩メールリンク経由からURLを受け取った時に発火
        .onOpenURL { url in
            print("メールリンクからのログインを確認")
            // handle the URL that must be opened
            // メールリンクからのログイン時、遷移リンクURLを検知して受け取る
            let incomingURL = url
            // 受け取ったメールリンクURLを使ってダイナミックリンクを生成
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else {
                    print("Error found!: \(error!.localizedDescription)")
                    return
                }
                // ダイナミックリンクが有効かチェック
                // リンクが有効だった場合、メールリンクからのサインインメソッド実行
                let defaults = UserDefaults.standard
                let link = incomingURL.absoluteString
                if let email = defaults.string(forKey: "Email") {
                    withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                        // View側で開かれているアドレス入力ハーフシートを閉じる
                        authVM.showEmailHalfSheet       = false
                        authVM.showEmailSheetBackground = false
                    }
                    print("メールリンクで受け取ったユーザーのメールアドレス: \(email)")
                    print("メールリンクによって行う処理の種類: \(authVM.handleUseReceivedEmailLink)")

                    switch authVM.handleUseReceivedEmailLink {

                    case .signIn:
                        authVM.resultSignInType = .signIn
                        authVM.signInEmailLink(email: email, link: link)

                    case .signUp:
                        authVM.resultSignInType = .signUp
                        authVM.signInEmailLink(email: email, link: link)

                    case .updateEmail:
                        authVM.addressReAuthenticateByEmailLink(email: email,
                                                                 link: link,
                                                                 handle: .updateEmail)
                    case .entryAccount:
                        if userVM.isAnonymous {
                            authVM.entryAccountByEmailLink(email: email,
                                                            link: link)
                        } else {
                            print("ERROR: ユーザーは匿名アカウントではありません。")
                        }
                    case .deleteAccount:
                        authVM.addressReAuthenticateByEmailLink(email: email,
                                                                 link: link,
                                                                 handle: .deleteAccount)
                    } // switch
                    
                } else {
                    print("ユーザーデフォルトからのメールアドレス取得失敗: defaults.string(forKey: Email)")
                }
            }
            if linkHandled {
                print("Link Handled")
            } else {
                print("NO linkHandled")
                return
            }
        }
    } // body
} // View

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(NavigationViewModel())
            .environmentObject(MomentLogViewModel())
            .environmentObject(AuthViewModel())
            .environmentObject(TeamViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(ItemViewModel())
            .environmentObject(TagViewModel())
            .environmentObject(ProgressViewModel())
            .environmentObject(PreloadViewModel())
    }
}
