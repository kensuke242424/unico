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

    enum UpdateTeamFocused {
        case check
    }

    struct InputUpdateUserOrTeam {
        var nameText: String = ""
        var captureImage: UIImage?
        var isShowPickerView: Bool = false
        var captureError: Bool = false
    }

    @Binding var selectedUpdate: SelectedUpdateData
    @StateObject var userVM: UserViewModel
    @StateObject var teamVM: TeamViewModel
    @FocusState var updateTeamfocused: UpdateTeamFocused?

    @State private var inputUpdate = InputUpdateUserOrTeam()

    var body: some View {

        ZStack {

            Color(.black).opacity(0.7)
                .background(.ultraThinMaterial).opacity(0.9)
//                .ignoresSafeArea()
                .onTapGesture {
                    updateTeamfocused = nil
                }

            LogoMark().scaleEffect(0.5).opacity(0.2)
                .offset(y: -getRect().height / 2 + getSafeArea().top + 40)

            VStack(spacing: 40) {

                Text(selectedUpdate == .user ? "ユーザ編集" : "チーム編集")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .opacity(0.7)
                    .tracking(10)

                VStack(spacing: 10) {
                    Text(selectedUpdate == .user ?
                         "ユーザ情報を入力してください。" : "チーム情報を入力してください。")
                        .padding(.bottom, 8)
                }
                .font(.caption).tracking(3).opacity(0.7)
                .foregroundColor(.white)

                Group {
                    if let captureImage = inputUpdate.captureImage {
                        UIImageCircleIcon(photoImage: captureImage, size: 150)
                    } else {
                        Image(systemName: "photo.circle.fill").resizable().scaledToFit()
                            .foregroundColor(.white.opacity(0.5)).frame(width: 150)
                    }
                }
                .onTapGesture { inputUpdate.isShowPickerView.toggle() }

                TextField("", text: $inputUpdate.nameText)
                    .frame(width: 230)
                    .foregroundColor(.white)
                    .focused($updateTeamfocused, equals: .check)
                    .textInputAutocapitalization(.never)
                    .multilineTextAlignment(.center)
                    .background {
                        ZStack {
                            Text(updateTeamfocused == nil && inputUpdate.nameText.isEmpty ?
                                 selectedUpdate == .user ?
                                 "ユーザ名を入力" : "チーム名を入力" : "")
                                .foregroundColor(.white.opacity(0.3))
                            Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                                .offset(y: 20)
                        }
                    }

                Button("保存する") {

                    switch selectedUpdate {
                    case .start:
                        print("")

                    case .user:
                        Task {
                            let iconData = await userVM.uploadUserImageData(inputUpdate.captureImage)
                            try await userVM.updateUserNameAndIcon(name: inputUpdate.nameText, data: iconData)
                        }

                    case .team:
                        Task {
                            let iconData = await teamVM.uploadTeamImageData(inputUpdate.captureImage)
                            try await teamVM.updateTeamNameAndIcon(name: inputUpdate.nameText, data: iconData)
                        }
                    }
                    // 編集画面を閉じる
                    hapticSuccessNotification()
                    withAnimation(.spring(response: 0.3)) { selectedUpdate = .start }
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)

                Button {
                    withAnimation(.spring(response: 0.3)) { selectedUpdate = .start }
                } label: {
                    Label("キャンセル", systemImage: "multiply.circle.fill")
                        .foregroundColor(.white).opacity(0.7)
                }
                .offset(y: 30)

            }
            .sheet(isPresented: $inputUpdate.isShowPickerView) {
                PHPickerView(captureImage: $inputUpdate.captureImage,
                             isShowSheet: $inputUpdate.isShowPickerView,
                             isShowError: $inputUpdate.captureError)
            }
        } // ZStack

        .onChange(of: selectedUpdate) { select in
            switch select {
            case .start:
                print("")

            case .user:
                inputUpdate.captureImage = nil
                let userName = userVM.user?.name ?? ""
                inputUpdate.nameText = userName
                getUIImageByUrl(url: userVM.user?.iconURL)

            case .team:
                inputUpdate.captureImage = nil
                let teamName = teamVM.team?.name ?? ""
                inputUpdate.nameText = teamName
                getUIImageByUrl(url: teamVM.team?.iconURL)
            }
        }
    } // body

    // 編集画面表示時に、元アイコンのUIImageをurlから取得
    func getUIImageByUrl(url: URL?) {
        guard let url else { return }
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                inputUpdate.captureImage = UIImage(data: data)
                print("teamIconのurl->UIImage成功")

            } catch let err {
                print("Error : \(err.localizedDescription)")
            }
        }
    }

} // View

struct UpdateTeamDataView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateTeamOrUserDataView(selectedUpdate: .constant(.user),
                           userVM: UserViewModel(),
                           teamVM: TeamViewModel())
    }
}
