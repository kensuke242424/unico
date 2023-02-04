//
//  UpdateTeamDataView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2023/02/05.
//

import SwiftUI

struct UpdateTeamOrUserDataView: View {

    enum UpdateTeamFocused {
        case check
    }

    enum SelectedUpdateData {
        case user, team
    }

    struct InputUpdateUserOrTeam {
        var nameText: String = ""
        var captureImage: UIImage?
        var isShowPickerView: Bool = false
        var captureError: Bool = false
    }

    var selectedUpdate: SelectedUpdateData
    @StateObject var userVM: UserViewModel
    @StateObject var teamVM: TeamViewModel
    @FocusState var updateTeamfocused: UpdateTeamFocused?

    @State private var inputUpdate = InputUpdateUserOrTeam()

    var body: some View {

        ZStack {

            Color(.black).opacity(0.7)
                .background(.ultraThinMaterial).opacity(0.9)
                .ignoresSafeArea()
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

                }
                .padding(.top)
                .buttonStyle(.borderedProminent)

                Button {
//                    withAnimation(.spring(response: 0.5, blendDuration: 1)) {
//                        teamVM.isShowSearchedNewUserJoinTeam.toggle()
//                    }
                } label: {
                    Label("閉じる", systemImage: "multiply.circle.fill")
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

        .onAppear {
            switch selectedUpdate {
            case .user:
                let teamIcon = getUIImageByUrl(url: teamVM.team?.iconURL)
                let teamName = teamVM.team?.name ?? ""
                inputUpdate.captureImage = teamIcon
                inputUpdate.nameText = teamName

            case .team:
                let userIcon = getUIImageByUrl(url: userVM.user?.iconURL)
                let userName = userVM.user?.name ?? ""
                inputUpdate.captureImage = userIcon
                inputUpdate.nameText = userName
            }
        }
    } // body

    func getUIImageByUrl(url: URL?) -> UIImage? {
        guard let url else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
            return nil
        }
    }

} // View

struct UpdateTeamDataView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateTeamOrUserDataView(selectedUpdate: .user,
                           userVM: UserViewModel(),
                           teamVM: TeamViewModel())
    }
}
