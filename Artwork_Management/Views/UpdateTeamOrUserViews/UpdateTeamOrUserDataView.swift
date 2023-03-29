//
//  UpdateTeamDataView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2023/02/05.
//

import SwiftUI

enum SelectedUpdateData {
    case start, user, team
}

struct UpdateTeamOrUserDataView: View {

    enum ShowKeyboard {
        case check
    }

    struct InputUpdateUserOrTeam {
        var nameText: String = ""
        var defaultIconData: (url: URL?, filePath: String?)
        var isShowPickerView: Bool = false
        var captureImage: UIImage?
        var captureError: Bool = false
        var savingWait: Bool = false
    }

    @Binding var selectedUpdate: SelectedUpdateData
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    
    @FocusState var showKyboard: ShowKeyboard?

    @State private var inputUpdate = InputUpdateUserOrTeam()

    var body: some View {

        ZStack {
            LogoMark().scaleEffect(0.4).opacity(0.4)
                .offset(x: getRect().width / 2 - 70,
                        y: -getRect().height / 2 + getSafeArea().top + 40)

            VStack(spacing: 40) {

                Text(selectedUpdate == .user ? "ユーザ編集" : "チーム編集")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .opacity(0.7)
                    .tracking(10)

                VStack(spacing: 10) {
                    if inputUpdate.savingWait {
                        HStack(spacing: 10) {
                            Text("保存中です...")
                            ProgressView()
                        }
                    } else {
                        Text(selectedUpdate == .user ? "ユーザ情報を入力してください。" : "チーム情報を入力してください。")
                    }
                }
                .font(.caption)
                .tracking(3)
                .opacity(0.7)
                .foregroundColor(.white)
                .padding(.bottom, 8)
                
                if let captureImage = inputUpdate.captureImage {
                    UIImageCircleIcon(photoImage: captureImage, size: 150)
                        .onTapGesture { inputUpdate.isShowPickerView.toggle() }
                } else {
                    if let iconURL = inputUpdate.defaultIconData.url {
                        SDWebImageCircleIcon(imageURL: iconURL, width: 150, height: 150)
                            .onTapGesture { inputUpdate.isShowPickerView.toggle() }
                    } else {
                        if selectedUpdate == .user {
                            PersonCircleIcon(size: 150)
                                .onTapGesture { inputUpdate.isShowPickerView.toggle() }
                        } else if selectedUpdate == .team {
                            CubeCircleIcon(size: 150)
                                .onTapGesture { inputUpdate.isShowPickerView.toggle() }
                        }
                    }
                }

                TextField("", text: $inputUpdate.nameText)
                    .frame(width: 230)
                    .foregroundColor(.white)
                    .focused($showKyboard, equals: .check)
                    .textInputAutocapitalization(.never)
                    .multilineTextAlignment(.center)
                    .background {
                        ZStack {
                            Text(showKyboard == nil && inputUpdate.nameText.isEmpty ?
                                 selectedUpdate == .user ?
                                 "ユーザ名を入力" : "チーム名を入力" : "")
                                .foregroundColor(.white.opacity(0.3))
                            Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                                .offset(y: 20)
                        }
                    }

                Button("保存する") {

                    guard let team = teamVM.team else { return }
                    guard let user = userVM.user else { return }

                    switch selectedUpdate {

                    case .start:
                        print("")

                    case .user:
                        Task {
                            withAnimation(.spring(response: 0.3)) {
                                inputUpdate.savingWait.toggle()
                            }
                            /// アイコンデータのアップロード保存
                            /// 新しいアイコンデータが存在するかどうかで処理を分岐する
                            if let updateIconImage = inputUpdate.captureImage {
                                let updateIconData = await userVM.uploadUserImage(updateIconImage)
                                let updateMemberData = JoinMember(memberUID: user.id,
                                                                  name     : inputUpdate.nameText,
                                                                  iconURL  : updateIconData.url)
                                try await userVM.updateUserNameAndIcon(name: inputUpdate.nameText, data: updateIconData)
                                try await teamVM.updateTeamJoinMemberData(data: updateMemberData, joins: user.joins)
                            } else {
                                let updateMemberData = JoinMember(memberUID: user.id,
                                                                  name     : inputUpdate.nameText,
                                                                  iconURL  : inputUpdate.defaultIconData.url)
                                try await userVM.updateUserNameAndIcon(name: inputUpdate.nameText, data: inputUpdate.defaultIconData)
                                try await teamVM.updateTeamJoinMemberData(data: updateMemberData, joins: user.joins)
                            }
                            
                            // 編集画面を閉じる
                            hapticSuccessNotification()
                            withAnimation(.spring(response: 0.3)) {
                                selectedUpdate = .start
                                inputUpdate.savingWait.toggle()
                            }
                        } // Task ここまで

                    case .team:
                        Task {
                            withAnimation(.spring(response: 0.3)) {
                                inputUpdate.savingWait.toggle()
                            }
                            
                            guard let teamID = teamVM.team?.id else { return }
                            
                            if let updateIconImage = inputUpdate.captureImage {
                                let uploadIconData = await teamVM.uploadTeamImage(updateIconImage, teamID: teamID)
                                let updateTeamData = JoinTeam(teamID : team.id,
                                                              name   : inputUpdate.nameText,
                                                              iconURL: uploadIconData.url)
                                try await teamVM.updateTeamNameAndIcon(name: inputUpdate.nameText, data: uploadIconData)
                                try await userVM.updateUserJoinTeamData(data: updateTeamData, members: team.members)
                            } else {
                                let updateTeamData = JoinTeam(teamID : team.id,
                                                              name   : inputUpdate.nameText,
                                                              iconURL: inputUpdate.defaultIconData.url)
                                try await teamVM.updateTeamNameAndIcon(name: inputUpdate.nameText, data: inputUpdate.defaultIconData)
                                try await userVM.updateUserJoinTeamData(data: updateTeamData, members: team.members)
                            }
                            // 編集画面を閉じる
                            hapticSuccessNotification()
                            withAnimation(.spring(response: 0.3)) {
                                selectedUpdate = .start
                                inputUpdate.savingWait.toggle()
                            }
                        } // Task ここまで
                    }
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
                .opacity(inputUpdate.savingWait ? 0.2 : 1.0)
                .disabled(inputUpdate.savingWait ? true : false)

                Button {
                    withAnimation(.spring(response: 0.3)) { selectedUpdate = .start }
                } label: {
                    Label("キャンセル", systemImage: "multiply.circle.fill")
                        .foregroundColor(.white).opacity(0.7)
                }
                .offset(y: 30)
                .opacity(inputUpdate.savingWait ? 0.2 : 1.0)
                .disabled(inputUpdate.savingWait ? true : false)

            }
            .sheet(isPresented: $inputUpdate.isShowPickerView) {
                PHPickerView(captureImage: $inputUpdate.captureImage,
                             isShowSheet: $inputUpdate.isShowPickerView)
            }
        } // ZStack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.userBlue1
                .frame(width: getRect().width, height: getRect().height)
                .opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { showKyboard = nil }

            BlurView(style: .systemThinMaterialDark)
                .frame(width: getRect().width, height: getRect().height)
                .opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture { showKyboard = nil }
            
            LogoMark().scaleEffect(0.4).opacity(0.4)
                .offset(x: getRect().width / 2 - 70,
                        y: -getRect().height / 2 + getSafeArea().top + 40)
        }

        .onAppear {
            if selectedUpdate == .user {
                inputUpdate.defaultIconData = (url     : userVM.user?.iconURL,
                                               filePath: userVM.user?.iconPath)
                inputUpdate.nameText = userVM.user?.name ?? ""
                
            } else if selectedUpdate == .team {
                inputUpdate.defaultIconData = (url     : teamVM.team?.iconURL,
                                              filePath : teamVM.team?.iconPath)
                inputUpdate.nameText = teamVM.team?.name ?? ""
            }
        }
    } // body
} // View

struct UpdateTeamDataView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateTeamOrUserDataView(selectedUpdate: .constant(.user))
            .environmentObject(TeamViewModel())
            .environmentObject(UserViewModel())
    }
}
