//
//  RootView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/10.
//

import SwiftUI
import Firebase
import ResizableSheet

enum RootNavigation {
    case logIn, fetch, join, home
}

struct RootView: View {

    @StateObject var logInVM: LogInViewModel = LogInViewModel()
    @StateObject var teamVM: TeamViewModel = TeamViewModel()
    @StateObject var userVM: UserViewModel = UserViewModel()
    @StateObject var itemVM: ItemViewModel = ItemViewModel()
    @StateObject var tagVM: TagViewModel = TagViewModel()

    @State private var isShowStandBy: Bool = false

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
                LogInView(logInVM: logInVM, teamVM: teamVM)
                    .environment(\.resizableSheetCenter, resizableSheetCenter)

            case .fetch:
                StandByView()

            case .join:
                StandByView()
                CreateAndJoinTeamView(logInVM: logInVM, teamVM: teamVM, userVM: userVM)

            case .home:
                HomeTabView(logInVM: logInVM,
                            teamVM: teamVM,
                            userVM: userVM,
                            itemVM: itemVM,
                            tagVM: tagVM)
                    .environment(\.resizableSheetCenter, resizableSheetCenter)
            }

            // チームに他のユーザを招待するView
            JoinUserDetectCheckView(teamVM: teamVM)
                .opacity(teamVM.isShowSearchedNewMemberJoinTeam ? 1.0 : 0.0)

            StandByView()
                .opacity(isShowStandBy ? 1.0 : 0.0)

        } // ZStack

        // fetch...
        .onChange(of: logInVM.rootNavigation) { navigation in
            print("LogInVM.rootNavigation: \(logInVM.rootNavigation)")
            if navigation == .fetch {
                Task {
                    do {
                        try await userVM.fetchUser()
                        guard let user = userVM.user else {
                            print("userVMのuserがnilです。ログイン画面に戻ります。")
                            logInVM.rootNavigation = .logIn
                            return
                        }
                        print("userVM.user: \(user)")
                        if user.joins.isEmpty {
                            print("参加チーム無し。チーム作成画面へ遷移")
                            _ = try await userVM.userRealtimeListener()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 1)) {
                                    logInVM.rootNavigation = .join
                                    teamVM.isShowCreateAndJoinTeam.toggle()
                                }
                            }
                            return
                        }
                        guard let lastLogInTeamID = user.lastLogIn else { return }
                        try await teamVM.fetchTeam(teamID: lastLogInTeamID)
                        await tagVM.fetchTag(teamID: lastLogInTeamID)
                        await itemVM.fetchItem(teamID: lastLogInTeamID)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                            withAnimation(.spring(response: 1)) {
                                userVM.canUserFetchedListener = nil
                                logInVM.rootNavigation = .home
                            }
                        }

                        _ = try await teamVM.teamRealtimeListener()
                        _ = try await userVM.userRealtimeListener()

                    } catch CustomError.uidEmpty {
                        print("Error: uidEmpty")
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    } catch CustomError.getRef {
                        print("Error: getRef")
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    } catch CustomError.fetch {
                        print("Error: fetch")
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    } catch CustomError.getDocument {
                        print("Error: getDocument")
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    } catch CustomError.getUserDocument {
                        print("Error: getUserDocument")
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    } catch {
                        print("Error")
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    }
                } // Task
            }
        }

        // Auth check...
        .onAppear {
//            logInVM.logOut()
            if Auth.auth().currentUser != nil {
                print("RootView_onAppear_currentUser != nil")
                logInVM.rootNavigation = .fetch
            } else {
                print("RootView_onAppear_currentUser == nil")
                isShowStandBy.toggle()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        isShowStandBy.toggle()
                    }
                }
            }
        }
    } // body
} // View

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
