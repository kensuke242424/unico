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
    
    @EnvironmentObject var progress: ProgressViewModel

    @StateObject var logInVM: LogInViewModel = LogInViewModel()
    @StateObject var teamVM: TeamViewModel = TeamViewModel()
    @StateObject var userVM: UserViewModel = UserViewModel()
    @StateObject var itemVM: ItemViewModel = ItemViewModel()
    @StateObject var tagVM: TagViewModel = TagViewModel()

    @State private var isShowStandBy: Bool = false
    @State private var showLogInAlert: Bool = false

    var windowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene
    }

    var resizableSheetCenter: ResizableSheetCenter? {
        windowScene.flatMap(ResizableSheetCenter.resolve(for:))
    }

    var body: some View {

        ZStack {
            switch logInVM.rootNavigation {
            case .logIn:
                LogInView(logInVM: logInVM, teamVM: teamVM, userVM: userVM)
                    .environment(\.resizableSheetCenter, resizableSheetCenter)

            case .fetch:
                StandByView()

            case .join:
                StandByView()
                CreateAndJoinTeamView(logInVM: logInVM, teamVM: teamVM, userVM: userVM)

            case .home:
                NewTabView()
                    .environment(\.resizableSheetCenter, resizableSheetCenter)
            }

            // チームに他のユーザを招待するView
            JoinUserDetectCheckView(teamVM: teamVM)
                .opacity(teamVM.isShowSearchedNewMemberJoinTeam ? 1.0 : 0.0)

            StandByView()
                .opacity(isShowStandBy ? 1.0 : 0.0)
            
            if progress.isShow {
                CustomProgressView()
            }

        } // ZStack
        .preferredColorScheme(.dark)

        // fetch...
        .onChange(of: logInVM.rootNavigation) { navigation in
            print("LogInVM.rootNavigation: \(logInVM.rootNavigation)")
            
            if navigation == .fetch {
                Task {
                    do {
                        /// ユーザーデータの取得
                        _ = try await userVM.fetchUser()
                        
                        /// ユーザーデータの所得ができなければ、ログイン画面に遷移
                        guard let user = userVM.user else {
                            logInVM.rootNavigation = .logIn
                            return
                        }
                        
                        /// チームデータを持っていなければ、チーム追加画面へ遷移
                        if user.joins.isEmpty {
                            print("参加チーム無し。チーム作成画面へ遷移")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 1)) {
                                    logInVM.rootNavigation = .join
                                    teamVM.isShowCreateAndJoinTeam.toggle()
                                }
                            }
                            return
                        }
                        
                        /// 最後にログインしたチーム情報をもとに、対象のチームの全データを取得
                        guard let lastLogInTeamID = user.lastLogIn else { return }
                        
                        try await teamVM.fetchTeam(teamID: lastLogInTeamID)
                            await tagVM.fetchTag(teamID: lastLogInTeamID)
                            await itemVM.fetchItem(teamID: lastLogInTeamID)

                        /// チームandユーザーデータのリスナーを起動
                        _ = try await teamVM.teamRealtimeListener()
                        _ = try await userVM.userRealtimeListener()
                        
                        /// ホーム画面へ遷移
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.spring(response: 1)) {
                                logInVM.rootNavigation = .home
                                /// ログインが完了したら、LogInViewの操作フローを初期化
                                logInVM.createAccountFase    = .start
                                logInVM.userSelectedSignInType     = .start
                                logInVM.selectProviderType   = .start
                                logInVM.addressSignInFase    = .start
                            }
                        }

                    } catch CustomError.uidEmpty {
                        print("Error: uidEmpty")
                        logInVM.logOut()
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    } catch CustomError.getRef {
                        print("Error: getRef")
                        logInVM.logOut()
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    } catch CustomError.fetch {
                        print("Error: fetch")
                        logInVM.logOut()
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    } catch CustomError.getDocument {
                        print("Error: getDocument")
                        logInVM.logOut()
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    } catch CustomError.getUserDocument {
                        print("Error: getUserDocument")
                        logInVM.logOut()
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    } catch {
                        print("Error")
                        logInVM.logOut()
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    }
                } // Task
            }
        }

        // Auth check...
        .onAppear {
            
            if Auth.auth().currentUser != nil {
                print("RootView_onAppear_currentUser != nil")
                logInVM.rootNavigation = .fetch
            } else {
                print("RootView_onAppear_currentUser == nil")
                isShowStandBy.toggle()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        isShowStandBy.toggle()
                    }
                }
            }
        }
        .onOpenURL { url in
            
            // handle the URL that must be opened
            // メールリンクからのログイン時、遷移リンクURLを検知して受け取る
            let incomingURL = url
            print("Incoming URL is: \(incomingURL)")
            // 受け取ったメールリンクURLを使ってダイナミックリンクを生成
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else {
                    print("Error found!: \(error!.localizedDescription)")
                    return
                }
                // ダイナミックリンクが有効かチェック
                // リンクが有効だった場合、メールリンクからのサインインメソッド実行
                let defaults = UserDefaults.standard
                if let email = defaults.string(forKey: "Email") {
                    progress.isShow.toggle()
                    withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                        // ViewModel内のアドレスログインフローに関わる状態を初期化
                        logInVM.showEmailHalfSheet = false
                        logInVM.showEmailSheetBackground = false
                    }
                    
                    print("アカウント登録するユーザのメールアドレス: \(email)")
                    // Firebase Authにアカウントの登録
                    /// TODO: この時すでにアカウントが存在した場合どのような動きになるか確認する
                    ///  ⇨ uidなどのデータはそのまま引き継がれ、サインインの形になった
                    Auth.auth().signIn(withEmail: email, link: incomingURL.absoluteString)
                    { authResult, error in
                        if let error {
                            print("ログインエラー：", error.localizedDescription)
                            progress.isShow.toggle()
                            // TODO: リンクメールの有効期限が切れていた時、ここに処理が走るみたい。適切なアラート要る
                            logInVM.isShowLogInFlowAlert.toggle()
                            logInVM.logInAlertMessage = .invalidLink
                            return
                        }
                        // メールリンクからのサインイン成功時の処理
                        if let authResult {
                            print("メールリンクからのログイン成功")
                            print("currentUser: \(Auth.auth().currentUser)")
                            
                            progress.isShow.toggle()
                        }
                    }
                } else {
                    print("ユーザーデフォルトからのメールアドレス取得失敗: defaults.string(forKey: Email)")
                    progress.isShow.toggle()
                }
            }
            if linkHandled {
                print("Link Handled")
                return
            } else {
                print("NO linkHandled")
                progress.isShow.toggle()
                return
            }
        }
    } // body
} // View

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
