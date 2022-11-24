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
                LogInView(logInVM: logInVM)

            case .fetch:
                StandByView()

            case .join:
                CreateAndJoinTeamView()

            case .home:
                HomeTabView(logInVM: logInVM,
                            teamVM: teamVM,
                            userVM: userVM,
                            itemVM: itemVM,
                            tagVM: tagVM)
                    .environment(\.resizableSheetCenter, resizableSheetCenter)
            }

            StandByView()
                .opacity(isShowStandBy ? 1.0 : 0.0)

        } // ZStack

        // Data fetch...
        .onChange(of: logInVM.rootNavigation) { _ in
            print("rootNavigation: \(logInVM.rootNavigation)")
            if logInVM.rootNavigation == .fetch {
                Task {
                    guard (try? await userVM.fetchUser()) != nil else {
                        print("fetchUser == nil")
                        logInVM.rootNavigation = .logIn
                        return
                    }
                    await tagVM.fetchTag(teamID: teamVM.teamID)
                    await itemVM.fetchItem(teamID: teamVM.teamID)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.spring(response: 1)) {
                            logInVM.rootNavigation = .home
                        }
                    }
                }
            }
        }

        // Auth check...
        .onAppear {
            if Auth.auth().currentUser != nil {
                logInVM.rootNavigation = .fetch
            } else {

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
