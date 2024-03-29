//
//  DeletingView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/05/22.
//

import SwiftUI

struct DeletingView: View {

    @EnvironmentObject var logInVM: AuthViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var navigationVM: NavigationViewModel

    @Environment(\.dismiss) var dismiss

    @State private var deleteExecution: Bool?

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
            // ビューの表示と同時にデータ削除タスク実行
            deleteExecution = true
        }
        .task(id: deleteExecution) {
            guard let deleteExecution else { return }

            // この画面に遷移した時点で、データ削除を開始する
            Task {

                do {
                    // -----  teamsコレクション内のチーム関連データを削除  -----
                    try await teamVM.deleteAllJoinsTeamDocumentsController(joins: userVM.joins)
                    // -----  usersコレクション内のユーザー関連データを削除  ------
                    try await userVM.deleteAllUserDocumentsController()
                    // -----  ユーザーがアカウント登録したAuthデータを削除  ------
                    try await logInVM.deleteAuth()
                    // 全てのデータ削除が完了したら、削除完了画面へ遷移
                    navigationVM.path.append(SystemAccountPath.deletedAccount)

                } catch {
                    // アカウントデータの削除に失敗したら、一つ前のページに戻る
                    logInVM.deleteAccountCheckFase = .failure
                    dismiss()
                }
            }
        }
    }
}
