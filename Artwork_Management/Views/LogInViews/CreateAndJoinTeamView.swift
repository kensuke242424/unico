//
//  CreateAndJoinTeamView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/24.
//

import SwiftUI

struct CreateAndJoinTeamView: View {

    enum SelectTeamCard {
        case start, join, create
    }

    @StateObject var logInVM: LogInViewModel
    @StateObject var teamVM: TeamViewModel
    @StateObject var userVM: UserViewModel

    @State private var selectTeamCard: SelectTeamCard = .start

    var body: some View {

        ZStack {

            BlurView(style: .systemUltraThinMaterialDark)
            Color.userGray1.opacity(0.5).blur(radius: 20)
                .onTapGesture { selectTeamCard = .start }

            VStack(spacing: 30) {
                Text("チーム設定")
                    .tracking(20)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.bottom, 30)

                switch selectTeamCard {
                case .start:
                    Text("どちらで始めますか？").tracking(10)
                case .join:
                    Text("チーム参加の説明")
                case .create:
                    Text("チーム作成の説明")
                }

                Spacer().frame(height: 100)

                HStack(spacing: 20) {

                    // join Team...
                    joinCard()

                    Text("or").font(.title3).foregroundColor(.white)
                        .opacity(selectTeamCard == .start ? 0.6 : 0.0)

                    // create Team...
                    createCard()
                }

                Spacer().frame(height: 100)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    func joinCard() -> some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.green)
            .frame(width: getRect().width * 0.4, height: 250)
            .scaleEffect(selectTeamCard == .join ? 1.4 : selectTeamCard == .create ? 0.8 : 1.0)
            .offset(x: selectTeamCard == .join ? 30 : 0)
            .opacity(selectTeamCard == .join ? 1.0 : selectTeamCard == .start ? 0.8 : 0.4)
            .onTapGesture { selectTeamCard = selectTeamCard == .start || selectTeamCard == .create ? .join : .start }
    }

    func createCard() -> some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.red)
            .frame(width: getRect().width * 0.4, height: 250)
            .scaleEffect(selectTeamCard == .create ? 1.4 : selectTeamCard == .join ? 0.8 : 1.0)
            .offset(x: selectTeamCard == .create ? -30 : 0)
            .opacity(selectTeamCard == .create ? 1.0 : selectTeamCard == .start ? 0.8 : 0.4)
            .onTapGesture { selectTeamCard = selectTeamCard == .start || selectTeamCard == .join ? .create : .start }
    }
}

struct CreateAndJoinTeamView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAndJoinTeamView(logInVM: LogInViewModel(),
                              teamVM: TeamViewModel(),
                              userVM: UserViewModel())
    }
}
