//
//  JoinedTeamInformationView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/11.
//

import SwiftUI

/// チームからの招待によって新規チームに加入した時に表示されるビュー。
/// ユーザーがチームへの移動を選択した場合、対象チームへの移動処理を行う。
struct JoinedTeamInformationView: View {

    @EnvironmentObject var logInVM: AuthViewModel
    @EnvironmentObject var progressVM: ProgressViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var teamVM: TeamViewModel

    @Binding var presented: Bool
    /// 新規チームへの移動が選択された時にtrueとなるプロパティ。
    @State private var exchange: Bool?
    /// チーム切り替え実行時に、ビューを隠す動作を管理するプロパティ。
    /// ビューごと破棄するとtaskが発動しないため、offsetとopacityで操作している
    @State private var hideContent = false

    var joinedTeam: JoinTeam? {
        return userVM.newJoinedTeam
    }

    var body: some View {

        VStack(spacing: 40) {
            Spacer()

            LogoMark()
                .frame(height: 80)
                .scaleEffect(0.45)
                .opacity(0.4)
                .padding(.bottom)

            VStack(spacing: 30) {
                Group {
                    Text("相手チームから")
                    Text("招待を受けました！")
                }
                .font(.title3.bold())
                .foregroundColor(.white)
                .opacity(0.7)
                .tracking(10)
            }

            VStack(spacing: 30) {

                WebImageTypesIcon(imageURL: joinedTeam?.iconURL,
                                  size: 150,
                                  type: .team,
                                  shape: AnyShape(Circle()))

                Text(userVM.newJoinedTeam?.name ?? "???")
                    .foregroundColor(.white)
                    .tracking(5)

                VStack(spacing: 20) {
                    Text("すぐにチームへ移動しますか？")
                        .padding(.bottom, 8)
                        .fontWeight(.bold)
                        .font(.caption)
                        .tracking(3)
                        .opacity(0.6)
                        .foregroundColor(.white)

                    HStack(spacing: 20) {
                        Button("今はしない") {
                            withAnimation {
                                presented = false
                            }
                        }
                        .buttonStyle(.bordered)

                        Button("移動する") {
                            withAnimation {
                                hideContent = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.5)) {
                                    progressVM.showCubesProgress = true
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                exchange = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.top, 20)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color(.black)
                .opacity(0.8)
                .background(.ultraThinMaterial)
                .opacity(0.9)
                .ignoresSafeArea()
        }
        .offset(y: hideContent ? 40 : 0)
        .opacity(hideContent ? 0 : 1)
        .task(id: exchange) {
            guard let exchange else { return }
            /* -- チーム移動処理 -- */

            do {
                try await userVM.updateLastLogInTeamId(teamId: joinedTeam?.id)
                presented = false
                logInVM.rootNavigation = .fetch
            } catch {
                print("最新ログインチーム状態のFirestoreへの保存に失敗しました")
                withAnimation(.spring(response: 0.5)) {
                    progressVM.showCubesProgress = false
                    self.exchange = false
                }
                return
            }
        }
        .onAppear {
            /// 承諾
            Task {
                try await userVM.setApprovedJoinTeam(to: joinedTeam)
            }
        }
        .onDisappear {
            userVM.newJoinedTeam = nil
        }
    }
}

struct JoinedTeamInformationView_Previews: PreviewProvider {
    static var previews: some View {
        JoinedTeamInformationView(presented: .constant(true))
            .environmentObject(TeamViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(AuthViewModel())
    }
}
