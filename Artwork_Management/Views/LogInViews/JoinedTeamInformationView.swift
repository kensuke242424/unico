//
//  JoinedTeamInformationView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/11.
//

import SwiftUI

struct JoinedTeamInformationView: View {

    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var teamVM: TeamViewModel

    var body: some View {
        ZStack {

            VStack(spacing: 30) {

                Spacer()

                LogoMark()
                    .frame(height: 80)
                    .scaleEffect(0.45)
                    .opacity(0.4)
                    .padding(.bottom)

                VStack(spacing: 30) {
                    Text("チームに参加しました！")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .tracking(10)
                        .padding(.bottom)

                    Text("すぐにログインしますか？")
                        .padding(.bottom, 8)
                        .fontWeight(.bold)
                        .font(.caption)
                        .tracking(3)
                        .opacity(0.6)
                        .foregroundColor(.white)

                }

                VStack(spacing: 30) {

                    AsyncImageCircleIcon(photoURL: userVM.newJoinedTeam?.iconURL, size: 150)

                    Text(userVM.newJoinedTeam?.name ?? "???")
                        .foregroundColor(.white)
                        .tracking(5)

                    HStack(spacing: 20) {
                        Group {
                            Button("今はしない") {

                            }
                            .buttonStyle(.bordered)

                            Button("ログイン") {

                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(width: 100, height: 50)
                    }
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
        }
    }
}

struct JoinedTeamInformationView_Previews: PreviewProvider {
    static var previews: some View {
        JoinedTeamInformationView()
            .environmentObject(TeamViewModel())
            .environmentObject(UserViewModel())
    }
}
