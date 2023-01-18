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
            JoinUserCheckView(teamVM: teamVM)
                .opacity(teamVM.isShowSearchedNewUserJoinTeam ? 1.0 : 0.0)

            StandByView()
                .opacity(isShowStandBy ? 1.0 : 0.0)

        } // ZStack

        // Data fetch...
        .onChange(of: logInVM.rootNavigation) { _ in
            print("LogInVM.rootNavigation: \(logInVM.rootNavigation)")
            if logInVM.rootNavigation == .fetch {
                Task {
                    do {
                        try await userVM.fetchUser()
                        print("userVM.user: \(userVM.user)")
                        if userVM.user!.joins.isEmpty {
                            print("参加チーム無し。チーム作成画面へ遷移")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 1)) {
                                    logInVM.rootNavigation = .join
                                    teamVM.isShowCreateAndJoinTeam.toggle()
                                }
                            }
                            return
                        }
                        guard let lastLogInTeamID = userVM.user!.lastLogIn else { return }
                        try await teamVM.fetchTeam(teamID: lastLogInTeamID)
                        await tagVM.fetchTag(teamID: lastLogInTeamID)
                        await itemVM.fetchItem(teamID: lastLogInTeamID)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.spring(response: 1)) {
                                logInVM.rootNavigation = .home
                            }
                        }
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
                    } catch {
                        print("Error")
                        withAnimation(.spring(response: 1)) { logInVM.rootNavigation = .logIn }
                    }
                } // Task
            }
        }

        // Auth check...
        .onAppear {
            if Auth.auth().currentUser != nil {
                logInVM.rootNavigation = .fetch
                print("RootView_onAppear_currentUser != nil")
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
