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

struct UpdateTeamDataView: View {

    enum ShowKeyboard {
        case check
    }

    struct InputUpdateTeam {
        var nameText: String = ""
        var defaultIconData: (url: URL?, filePath: String?)
        var showPicker: Bool = false
        var captureImage: UIImage?
        var captureError: Bool = false
        var savingWait: Bool = false
    }

    /// ビューの表示を管理するプロパティ
    @Binding var show: Bool
    /// ビュー内のコンテンツ表示を管理するプロパティ
    @State private var showContent: Bool = false

    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    
    @FocusState var showKeyboard: ShowKeyboard?
    /// キーボード出現時のViewOffsetを管理するプロパティ
    @State private var showKeyboardOffset: Bool = false
    /// View内でユーザーが入力するデータを管理するプロパティ群
    @State private var inputUpdate = InputUpdateTeam()

    var body: some View {

        VStack(spacing: 30) {

            LogoMark()
                .frame(height: 30)
                .scaleEffect(0.45)
                .opacity(0.4)
                .padding(.bottom, 40)

            Text("チーム編集")
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
                        Text("チーム情報を入力してください。")
                    }
                }
                .font(.caption)
                .tracking(3)
                .opacity(0.7)
                .foregroundColor(.white)
                .padding(.bottom, 8)

                CaptureImageIcon(image: inputUpdate.captureImage)
                    .onTapGesture { inputUpdate.showPicker.toggle() }

                TextField("", text: $inputUpdate.nameText)
                    .frame(width: 230)
                    .foregroundColor(.white)
                    .focused($showKeyboard, equals: .check)
                    .textInputAutocapitalization(.never)
                    .multilineTextAlignment(.center)
                    .background {
                        ZStack {
                            Text(showKeyboard == nil && inputUpdate.nameText.isEmpty ? "チーム名を入力" : "")
                            .foregroundColor(.white.opacity(0.3))
                            Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                                .offset(y: 20)
                        }
                    }

                SavingButton()
                    .disabled(inputUpdate.savingWait ? true : false)
                    .opacity(inputUpdate.savingWait ? 0.2 : 1.0)
                    .padding(.top)

                CancelButton()
                .disabled(inputUpdate.savingWait ? true : false)
                .opacity(inputUpdate.savingWait ? 0.2 : 1.0)
                .padding(.top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: showKeyboardOffset ? -100 : 0)
        .sheet(isPresented: $inputUpdate.showPicker) {
            PHPickerView(captureImage: $inputUpdate.captureImage,
                         isShowSheet: $inputUpdate.showPicker)
        }
        .background {
            Color(.black)
                .opacity(0.8)
                .background(.ultraThinMaterial)
                .opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture { showKeyboard = nil }
        }
        .onChange(of: showKeyboard) { newValue in
            if newValue == .check {
                withAnimation { showKeyboardOffset = true }
            } else {
                withAnimation { showKeyboardOffset = false }
            }
        }
        .onAppear {
            inputUpdate.defaultIconData = (url     : teamVM.team?.iconURL,
                                           filePath : teamVM.team?.iconPath)
            inputUpdate.nameText = teamVM.team?.name ?? ""

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
                CubeCircleIcon(size: 150)
            }
        }
    }
    @ViewBuilder
    func SavingButton() -> some View {
        Button("保存する") {

            guard let team = teamVM.team else { return }
            guard let user = userVM.user else { return }
            guard let currentTeamIndex = userVM.currentTeamIndex else { return }

            Task {
                withAnimation(.spring(response: 0.3)) { inputUpdate.savingWait = true }

                // ーー保存に用いるデータコンテナ群ーー
                var newIconDataContainer: (url: URL?, filePath: String?)?
                var newNameContainer: String?
                let defaultIconDataContainer = (url: team.iconURL, filePath: team.iconPath)
                let defaultNameContainer = team.name
                var updateJoinTeamContainer = user.joins[currentTeamIndex]

                // 新規アイコンデータが存在すれば、アップロード&コンテナに格納
                if let updateIconImage = inputUpdate.captureImage {
                    let uploadIconData = await teamVM.uploadTeamImage(updateIconImage)
                    newIconDataContainer = uploadIconData
                    updateJoinTeamContainer.iconURL = uploadIconData.url
                }
                // 名前に変更があれば、JoinTeamデータを更新&コンテナに格納
                if team.name != inputUpdate.nameText {
                    newNameContainer = inputUpdate.nameText
                    updateJoinTeamContainer.name = inputUpdate.nameText
                }

                if newIconDataContainer != nil || newNameContainer != nil {
                    try await teamVM.updateTeamNameAndIcon(name: newNameContainer ?? defaultNameContainer,
                                                           data: newIconDataContainer ?? defaultIconDataContainer)
                    try await userVM.updateJoinTeamNameNameAndIcon(data: updateJoinTeamContainer, members: team.members)
                }

                // 編集画面を閉じる
                hapticSuccessNotification()

                withAnimation {
                    showContent.toggle()
                    inputUpdate.savingWait = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.3)) { show = false }
                }
            } // Task ここまで
        }
        .buttonStyle(.borderedProminent)
        .disabled(inputUpdate.savingWait ? true : false)
    }
    @ViewBuilder
    func CancelButton() -> some View {
        Button {
            withAnimation { showContent.toggle() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.3)) { show = false }
            }
        } label: {
            Label("キャンセル", systemImage: "multiply.circle.fill")
                .foregroundColor(.white).opacity(0.7)
        }
    }
} // View

struct UpdateTeamDataView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateTeamDataView(show: .constant(true))
            .environmentObject(TeamViewModel())
            .environmentObject(UserViewModel())
    }
}
