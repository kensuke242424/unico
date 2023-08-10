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
    @EnvironmentObject var logVM: LogViewModel
    
    @FocusState var showKeyboard: ShowKeyboard?
    /// キーボード出現時のViewOffsetを管理するプロパティ
    @State private var showKeyboardOffset: Bool = false
    /// View内でユーザーが入力するデータを管理するプロパティ群
    @State private var input = InputUpdateTeam()

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
                    if input.savingWait {
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

                CaptureImageIcon(image: input.captureImage)
                    .onTapGesture { input.showPicker.toggle() }

                TextField("", text: $input.nameText)
                    .frame(width: 230)
                    .foregroundColor(.white)
                    .focused($showKeyboard, equals: .check)
                    .textInputAutocapitalization(.never)
                    .multilineTextAlignment(.center)
                    .background {
                        ZStack {
                            Text(showKeyboard == nil && input.nameText.isEmpty ? "チーム名を入力" : "")
                            .foregroundColor(.white.opacity(0.3))
                            Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                                .offset(y: 20)
                        }
                    }

                SavingButton()
                    .disabled(input.savingWait ? true : false)
                    .opacity(input.savingWait ? 0.2 : 1.0)
                    .padding(.top)

                CancelButton()
                .disabled(input.savingWait ? true : false)
                .opacity(input.savingWait ? 0.2 : 1.0)
                .padding(.top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: showKeyboardOffset ? -100 : 0)
        // 写真ピッカー&クロップビュー
        .cropImagePicker(option: .circle,
                         show: $input.showPicker,
                         croppedImage: $input.captureImage)
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
            input.defaultIconData = (url     : teamVM.team?.iconURL,
                                           filePath : teamVM.team?.iconPath)
            input.nameText = teamVM.team?.name ?? ""

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showContent.toggle()
                }
            }
        }
    } // body
    @ViewBuilder
    func CaptureImageIcon(image: UIImage?) -> some View {
        if let captureImage = input.captureImage {
            UIImageCircleIcon(photoImage: captureImage, size: 150)
        } else {
            if let iconURL = input.defaultIconData.url {
                SDWebImageCircleIcon(imageURL: iconURL, width: 150, height: 150)
            } else {
                CubeCircleIcon(size: 150)
            }
        }
    }
    @ViewBuilder
    func SavingButton() -> some View {
        Button("保存する") {

            guard let team = teamVM.team,
                  let joinIndex = userVM.currentJoinsTeamIndex else {
                print("ERROR: チームデータの更新に失敗しました。")
                withAnimation { showContent.toggle() }
                return
            }

            Task {
                withAnimation(.spring(response: 0.3)) { input.savingWait = true }

                // ーー保存に用いるデータコンテナ群ーー
                var beforeTeam = team
                var afterTeam = team
                var joinTeamContainer = userVM.joins[joinIndex]

                // 新規アイコンデータが存在すれば、アップロード&アイコンコンテナに格納
                if let updateIconImage = input.captureImage {
                    let uploadIconData = await teamVM.uploadTeamImage(updateIconImage)
                    afterTeam.iconURL = uploadIconData.url
                    afterTeam.iconPath = uploadIconData.filePath
                    joinTeamContainer.iconURL = uploadIconData.url
                }
                // 名前に変更があれば、JoinTeamコンテナを更新&名前コンテナに格納
                if team.name != input.nameText {
                    afterTeam.name = input.nameText
                    joinTeamContainer.name = input.nameText
                }
                // データの変更があれば、Firebaseへの保存処理実行
                if beforeTeam != afterTeam {
                    try await teamVM.updateTeam(data: afterTeam)
                    try await userVM.updateJoinTeamToMembers(data: joinTeamContainer,
                                                             ids: team.membersId)

                    hapticSuccessNotification()
                }
                // 編集画面を閉じる
                withAnimation {
                    showContent.toggle()
                    input.savingWait = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.3)) { show = false }
                    if beforeTeam != afterTeam {
                        // 変更前・変更後のデータを使って通知の作成
                        let compareTeam = CompareTeam(id: team.id,
                                                      before: beforeTeam,
                                                      after: afterTeam)
                        logVM.addLog(to: teamVM.team,
                                     by: userVM.user,
                                     type: .updateTeam(compareTeam))
                    }
                }
            } // Task ここまで
        }
        .buttonStyle(.borderedProminent)
        .disabled(input.savingWait ? true : false)
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
