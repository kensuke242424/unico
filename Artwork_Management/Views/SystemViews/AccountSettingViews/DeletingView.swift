//
//  DeletingView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/05/22.
//

import SwiftUI

struct DeletingView: View {

    @EnvironmentObject var logInVM: LogInViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var navigationVM: NavigationViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {

           Group {
                Text("アカウントの削除を実行中です")
                Text("しばらくお待ちください...")
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .tracking(3)
            .foregroundColor(.white)
            .opacity(0.7)

            ProgressView()
                .padding(.top)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customSystemBackground()
        .navigationBarBackButtonHidden()
        .customNavigationTitle(title: "削除実行中")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // この画面に遷移した時点で、データ削除を開始する
            Task {

                guard let userID = userVM.user?.id else { return }
                guard let joinsTeam = userVM.user?.joins else { return }

                do {
                    _ = try await logInVM.deleteAccountWithEmailLink()
                    _ = try await teamVM.deleteAccountRelatedTeamData(uid: userID, joinsTeam: joinsTeam)
                    _ = try await userVM.deleteAccountRelatedUserData()

                    navigationVM.path.append(SystemAccountPath.deletedAccount)

                } catch {
                    // アカウントデータの削除に失敗したら、一つ前のページに戻る
                    logInVM.deleteAccountCheckFase = .failure
                    dismiss()
                }
            }
        }
    }

    private func excutionDeleteAll() {
        Task {
            guard let userID = userVM.user?.id else { return }
            guard let joinsTeam = userVM.user?.joins else { return }

            do {
                _ = try await logInVM.deleteAccountWithEmailLink()
                _ = try await teamVM.deleteAccountRelatedTeamData(uid: userID,
                                                                  joinsTeam: joinsTeam)

            } catch {
                // アカウントデータの削除に失敗したら、一つ前のページに戻る
                logInVM.deleteAccountCheckFase = .failure
                dismiss()
            }
        }
    }
}
