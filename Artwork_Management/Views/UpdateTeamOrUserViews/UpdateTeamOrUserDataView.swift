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
        var updateIconURL: URL?
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
                    if let iconURL = inputUpdate.updateIconURL {
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
                            // アイコンデータのアップロード保存
                            let iconData = await userVM.uploadUserImage(inputUpdate.captureImage)
                            // ユーザの名前とアイコンデータをfirestoreに保存
                            try await userVM.updateUserNameAndIcon(name: inputUpdate.nameText, data: iconData)
                            // ユーザが保持している各チームのメンバーデータ(JoinMember)を更新
                            let updateMemberData = JoinMember(memberUID: user.id, name: inputUpdate.nameText, iconURL: iconData.url)
                            try await teamVM.updateTeamJoinMemberData(data: updateMemberData, joins: user.joins)
                            // 編集画面を閉じる
                            hapticSuccessNotification()
                            withAnimation(.spring(response: 0.3)) {
                                selectedUpdate = .start
                                inputUpdate.savingWait.toggle()
                            }
                        }

                    case .team:
                        Task {
                            withAnimation(.spring(response: 0.3)) {
                                inputUpdate.savingWait.toggle()
                            }
                            // アイコンデータのアップロード保存
                            guard let teamID = teamVM.team?.id else { return }
                            let iconData = await teamVM.uploadTeamImage(inputUpdate.captureImage, teamID: teamID)
                            // チームの名前とアイコンデータをfirestoreに保存
                            try await teamVM.updateTeamNameAndIcon(name: inputUpdate.nameText, data: iconData)
                            // チームが保持している各メンバーのチームデータ(JoinTeam)を更新
                            let updateTeamData = JoinTeam(teamID: team.id, name: inputUpdate.nameText, iconURL: iconData.url)
                            try await userVM.updateUserJoinTeamData(data: updateTeamData, members: team.members)
                            // 編集画面を閉じる
                            hapticSuccessNotification()
                            withAnimation(.spring(response: 0.3)) {
                                selectedUpdate = .start
                                inputUpdate.savingWait.toggle()
                            }
                        }
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
                inputUpdate.updateIconURL = userVM.user?.iconURL
                let userName = userVM.user?.name ?? ""
                inputUpdate.nameText = userName
                
            } else if selectedUpdate == .team {
                inputUpdate.updateIconURL = teamVM.team?.iconURL
                let teamName = teamVM.team?.name ?? ""
                inputUpdate.nameText = teamName
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
