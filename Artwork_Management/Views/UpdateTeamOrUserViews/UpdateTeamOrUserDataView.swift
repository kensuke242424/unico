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

    // ビューの表示を管理するプロパティ群
    @Binding var selectedUpdate: SelectedUpdateData
    @State private var showContent: Bool = false

    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    
    @FocusState var showKyboard: ShowKeyboard?
    /// キーボード出現時、Viewを上にずらす
    @State private var showKeyboardOffset: Bool = false

    @State private var inputUpdate = InputUpdateUserOrTeam()

    var body: some View {

        VStack(spacing: 30) {

            LogoMark()
                .frame(height: 30)
                .scaleEffect(0.45)
                .opacity(0.4)
                .padding(.bottom, 40)

            Text(selectedUpdate == .user ? "ユーザー編集" : "チーム編集")
                .font(.title3.bold())
                .foregroundColor(.white)
                .opacity(0.7)
                .tracking(10)

            if showContent {

                VStack(spacing: 10) {
                    if inputUpdate.savingWait {
                        HStack(spacing: 10) {
                            Text("保存中です...")
                            ProgressView()
                        }
                    } else {
                        Text(selectedUpdate == .user ? "ユーザー情報を入力してください。" : "チーム情報を入力してください。")
                    }
                }
                .font(.caption)
                .tracking(3)
                .opacity(0.7)
                .foregroundColor(.white)
                .padding(.bottom, 8)

                CaptureImageIcon(image: inputUpdate.captureImage)
                    .onTapGesture { inputUpdate.isShowPickerView.toggle() }


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
                                 "ユーザー名を入力" : "チーム名を入力" : "")
                            .foregroundColor(.white.opacity(0.3))
                            Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                                .offset(y: 20)
                        }
                    }

                UpdateButton()
                    .padding(.top)
                    .opacity(inputUpdate.savingWait ? 0.2 : 1.0)

                Button {
                    withAnimation { showContent.toggle() }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.3)) { selectedUpdate = .start }
                    }
                } label: {
                    Label("キャンセル", systemImage: "multiply.circle.fill")
                        .foregroundColor(.white).opacity(0.7)
                }
                .opacity(inputUpdate.savingWait ? 0.2 : 1.0)
                .disabled(inputUpdate.savingWait ? true : false)
                .padding(.top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: showKeyboardOffset ? -100 : 0)
        .onChange(of: showKyboard) { newValue in
            if newValue == .check {
                withAnimation { showKeyboardOffset = true }
            } else {
                withAnimation { showKeyboardOffset = false }
            }
        }
        .sheet(isPresented: $inputUpdate.isShowPickerView) {
            PHPickerView(captureImage: $inputUpdate.captureImage,
                         isShowSheet: $inputUpdate.isShowPickerView)
        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showContent.toggle()
                }
            }
        }
    } // body
    @ViewBuilder
    func CaptureImageIcon(image: UIImage?) -> some View {
        if let captureImage = inputUpdate.captureImage {
            UIImageCircleIcon(photoImage: captureImage, size: 150)
        } else {
            if let iconURL = inputUpdate.defaultIconData.url {
                SDWebImageCircleIcon(imageURL: iconURL, width: 150, height: 150)
            } else {
                // 既存の画像がなければ、「チーム」「ユーザー」それぞれの初期アイコンを表示
                if selectedUpdate == .user {
                    PersonCircleIcon(size: 150)
                } else if selectedUpdate == .team {
                    CubeCircleIcon(size: 150)
                }
            }
        }
    }
    @ViewBuilder
    func UpdateButton() -> some View {
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
                        /// 自身のユーザーデータ更新と、所属するチームが保持する自身のデータを更新
                        try await userVM.updateUserNameAndIcon(name: inputUpdate.nameText, data: updateIconData)
                        try await teamVM.updateTeamJoinMemberData(data: updateMemberData, joins: user.joins)
                    } else {
                        let updateMemberData = JoinMember(memberUID: user.id,
                                                          name     : inputUpdate.nameText,
                                                          iconURL  : inputUpdate.defaultIconData.url)
                        /// 自身のユーザーデータ更新と、所属するチームが保持する自身のデータを更新
                        try await userVM.updateUserNameAndIcon(name: updateMemberData.name, data: inputUpdate.defaultIconData)
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

                    if let updateIconImage = inputUpdate.captureImage {
                        let uploadIconData = await teamVM.uploadTeamImage(updateIconImage)
                        let updateTeamData = JoinTeam(teamID : team.id,
                                                      name   : inputUpdate.nameText,
                                                      iconURL: uploadIconData.url)
                        /// チームデータ更新と、所属するユーザーメンバーが保持するチームデータを更新
                        try await teamVM.updateTeamNameAndIcon(name: inputUpdate.nameText, data: uploadIconData)
                        try await userVM.updateUserJoinTeamData(data: updateTeamData, members: team.members)
                    } else {
                        let updateTeamData = JoinTeam(teamID : team.id,
                                                      name   : inputUpdate.nameText,
                                                      iconURL: inputUpdate.defaultIconData.url)
                        /// チームデータ更新と、所属するユーザーメンバーが保持するチームデータを更新
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
        .buttonStyle(.borderedProminent)
        .disabled(inputUpdate.savingWait ? true : false)
    }
} // View

struct UpdateTeamDataView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateTeamOrUserDataView(selectedUpdate: .constant(.user))
            .environmentObject(TeamViewModel())
            .environmentObject(UserViewModel())
    }
}
