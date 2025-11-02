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

    @State private var hasStartedDeletion = false

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
        .task {
            // 既に実行済みなら何もしない（重複実行を防ぐ）
            guard !hasStartedDeletion else { return }
            hasStartedDeletion = true

            do {
                Logger.i("🔴 === アカウント削除処理開始 ===")
                Logger.i("削除対象ユーザー: \(userVM.user?.name ?? "不明") [id=\(userVM.user?.id ?? "不明")]")

                // -----  teamsコレクション内のチーム関連データを削除  -----
                Logger.i("ステップ 1/3: チーム関連データ削除中...")
                try await teamVM.deleteAllJoinsTeamDocumentsController(joins: userVM.joins)

                // -----  usersコレクション内のユーザー関連データを削除  ------
                Logger.i("ステップ 2/3: ユーザー関連データ削除中...")
                try await userVM.deleteAllUserDocumentsController()

                // -----  ユーザーがアカウント登録したAuthデータを削除  ------
                Logger.i("ステップ 3/3: 認証データ削除中...")
                try await logInVM.deleteAuth()

                Logger.i("🔴 === アカウント削除処理完了 ===")

                // メインスレッドで確実に画面遷移を実行
                await MainActor.run {
                    // 削除完了画面を表示
                    navigationVM.path.append(SystemAccountPath.deletedAccount)

                    // Auth削除後の状態をリセット
                    logInVM.deleteAccountCheckFase = .start
                }

            } catch {
                Logger.e("❌ アカウント削除処理失敗: \(error.localizedDescription)")

                // メインスレッドでエラー処理
                await MainActor.run {
                    logInVM.deleteAccountCheckFase = .failure

                    // NavigationPathから確実に前の画面に戻る
                    if !navigationVM.path.isEmpty {
                        navigationVM.path.removeLast()
                    }
                }
            }
        }
    }
}
