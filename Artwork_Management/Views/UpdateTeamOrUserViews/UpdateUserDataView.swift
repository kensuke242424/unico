//
//  UpdateUserDataView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/07/13.
//

import SwiftUI

struct UpdateUserDataView: View {
    enum ShowKeyboard {
        case check
    }

    /// ビューの表示を管理するプロパティ
    @Binding var show: Bool
    /// ビュー内のコンテンツ表示を管理するプロパティ
    @State private var showContent: Bool = false

    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var logVM: LogViewModel
    @EnvironmentObject var teamNotifyVM: NotificationViewModel

    @FocusState var showKeyboard: ShowKeyboard?
    /// キーボード出現時のViewOffsetを管理するプロパティ
    @State private var showKeyboardOffset: Bool = false
    /// View内でユーザーが入力するデータを管理するプロパティ群
    @State private var input = InputUpdateUser()

    private struct InputUpdateUser {
        var nameText: String = ""
        var defaultIconData: (url: URL?, filePath: String?)
        var showPicker: Bool = false
        var captureImage: UIImage?
        var captureError: Bool = false
        var savingWait: Bool = false
    }

    var body: some View {

        VStack(spacing: 30) {

            LogoMark()
                .frame(height: 30)
                .scaleEffect(0.45)
                .opacity(0.4)
                .padding(.bottom, 40)

            Text("ユーザー編集")
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
                        Text("ユーザー情報を入力してください。")
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
                            Text(showKeyboard == nil && input.nameText.isEmpty ?
                                 "ユーザー名を入力" : "")
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
        .onChange(of: showKeyboard) { newValue in
            if newValue == .check {
                withAnimation { showKeyboardOffset = true }
            } else {
                withAnimation { showKeyboardOffset = false }
            }
        }
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

        .onAppear {
            input.defaultIconData = (url     : userVM.user?.iconURL,
                                     filePath: userVM.user?.iconPath)
            input.nameText = userVM.user?.name ?? ""

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { showContent.toggle() }
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
                PersonCircleIcon(size: 150)
            }
        }
    }
    @ViewBuilder
    func SavingButton() -> some View {
        Button("保存する") {

            guard let team = teamVM.team,
                  let user = userVM.user else {
                print("ユーザーまたはチームがnil")
                return
            }

            Task {
                withAnimation(.spring(response: 0.3)) { input.savingWait = true }

                // ーー保存時の比較に用いるデータコンテナーー
                var beforeUser = user
                var afterUser = user

                // ーーーー　アイコン画像の更新をチェック　ーーーーー
                if let captureImage = input.captureImage {
                    let uploadIconData = await userVM.uploadUserImage(captureImage)
                    afterUser.iconURL = uploadIconData.url
                    afterUser.iconPath = uploadIconData.filePath
                }
                // ーーーー　名前の更新をチェック　ーーーーー
                if user.name != input.nameText {
                    afterUser.name = input.nameText
                }

                // ーーーー　データの更新が確認できたら実行　ーーーーー
                if beforeUser != afterUser {
                    /// 自身のユーザーデータ更新
                    try await userVM.updateUser(from: afterUser)
                    // 所属するチームが保持する自身のデータを更新
                    try await userVM.updateJoinTeamsMyData(from: afterUser)

                    hapticSuccessNotification()
                }

                withAnimation {
                    showContent = false
                    input.savingWait = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.3)) { show = false }
                    if beforeUser != afterUser {
                        let compareUser = CompareUser(id    : user.id,
                                                      before: beforeUser,
                                                      after : afterUser)
                        logVM.addLog(to: team,
                                     by: user,
                                     type: .updateUser(compareUser))
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
}

//struct UpdateUserDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        UpdateUserDataView()
//    }
//}
