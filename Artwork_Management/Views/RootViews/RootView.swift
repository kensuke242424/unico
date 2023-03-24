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
    
    var windowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene
    }
    var resizableSheetCenter: ResizableSheetCenter? {
        windowScene.flatMap(ResizableSheetCenter.resolve(for:))
    }
    
    private struct PreloadProperty {
        var startPreload: Bool = false
        var inputTab    : InputTab = InputTab()
        var captureImage: UIImage?
        var showSheet   : Bool = false
    }
    
    @EnvironmentObject var progress: ProgressViewModel

    @EnvironmentObject var logInVM: LogInViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tagVM: TagViewModel
    @EnvironmentObject var preloadVM: PreloadViewModel
    
    @StateObject var itemVM: ItemViewModel = ItemViewModel()
    @StateObject var cartVM: CartViewModel = CartViewModel()

    @State private var isShowStandBy: Bool = false
    @State private var showLogInAlert: Bool = false
    
    @State private var preloads: PreloadProperty = PreloadProperty()

    var body: some View {

        ZStack {
            switch logInVM.rootNavigation {
            case .logIn:
                LogInView()

            case .fetch:
                StandByView()

            case .join:
                StandByView()
                CreateAndJoinTeamView()

            case .home:
                NewTabView(itemVM: itemVM, cartVM: cartVM)
                    .environment(\.resizableSheetCenter, resizableSheetCenter)
            }

//            // チームに他のユーザを招待するView
//            JoinUserDetectCheckView(teamVM: teamVM)
//                .opacity(teamVM.isShowSearchedNewMemberJoinTeam ? 1.0 : 0.0)

            StandByView()
                .opacity(isShowStandBy ? 1.0 : 0.0)
            
            if progress.isShow {
                CustomProgressView()
            }

        } // ZStack
        //        .preferredColorScheme(.dark)
        /// プリロードView
        /// 一度ロードしたViewはキャッシュが作られて初回時のView表示が軽くなる仕様を使う
        .background {
            if preloads.startPreload {
                Group {
                    NewItemsView(itemVM: itemVM, cartVM: cartVM, inputTab: $preloads.inputTab)
                    NewEditItemView(itemVM: itemVM, passItem: nil)
                    PHPickerView(captureImage: $preloads.captureImage, isShowSheet: $preloads.showSheet)
                }
                .opacity(0)
            }
        }
        .onAppear {
            preloads.startPreload = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                preloads.startPreload = false
            }
        }

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
                            await tagVM.fetchTag(  teamID: lastLogInTeamID)
                            await itemVM.fetchItem(teamID: lastLogInTeamID)

                        /// チームandユーザーデータのリスナーを起動
                        _ = try await teamVM.teamRealtimeListener()
                        _ = try await userVM.userRealtimeListener()
                        
                        /// ホーム画面へ遷移
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 1)) {
                                logInVM.rootNavigation = .home
                                /// ログインが完了したら、LogInViewの操作フローを初期化
                                logInVM.createAccountFase          = .start
                                logInVM.userSelectedSignInType     = .start
                                logInVM.selectProviderType         = .start
                                logInVM.addressSignInFase          = .start
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
                print("RootView_onAppear_currentUserが存在します。fetchを開始")
                logInVM.rootNavigation = .fetch
            } else {
                print("RootView_onAppear_currentUserがnilです。ログイン画面に遷移します。")
                isShowStandBy.toggle()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        isShowStandBy.toggle()
                    }
                }
            }
        }
        /// 📩メールリンク経由からURLを受け取った時に発火
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
                        // アドレス入力ハーフシートを閉じる
                        logInVM.showEmailHalfSheet       = false
                        logInVM.showEmailSheetBackground = false
                    }
                    print("アカウント登録するユーザのメールアドレス: \(email)")
                    
                    switch logInVM.handleUseReceivedEmailLink {
                    case .signIn:
                        logInVM.signInEmailLink(email: email, link: incomingURL.absoluteString)
                        progress.isShow.toggle()
                        
                    case .entryAccount:
                        if userVM.isAnonymous {
                            logInVM.entryAccountEmailLink(email: email, link: incomingURL.absoluteString)
                            progress.isShow.toggle()
                        }
                        
                    case .deleteAccount:
                        logInVM.deleteAccountEmailLink(email: email, link: incomingURL.absoluteString)
                        progress.isShow.toggle()
                    } // switch
                    
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
            .environmentObject(LogInViewModel())
            .environmentObject(TeamViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(ItemViewModel())
            .environmentObject(TagViewModel())
            .environmentObject(ProgressViewModel())
    }
}
