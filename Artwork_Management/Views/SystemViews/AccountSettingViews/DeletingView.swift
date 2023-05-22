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
        // アカウント削除の失敗を検知したら、一つ前のページに戻る
        .onChange(of: logInVM.deleteAccountCheckFase) { fase in
            if fase == .failure {
                dismiss()
            }
        }
        .onAppear {
            // この画面に遷移した時点で、データ削除を開始する
            excutionDeleteAll()
        }
    }

    private func excutionDeleteAll() {
        Task {
            logInVM.deleteAccountWithEmailLink()
            
        }
    }
}
