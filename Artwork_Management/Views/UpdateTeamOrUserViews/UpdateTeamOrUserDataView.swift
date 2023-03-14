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
        var userIconImage: UIImage?
        var teamIconImage: UIImage?
        var isShowUserPickerView: Bool = false
        var isShowTeamPickerView: Bool = false
        var captureError: Bool = false
        var savingWait: Bool = false
    }

    @Binding var selectedUpdate: SelectedUpdateData
    @StateObject var userVM: UserViewModel
    @StateObject var teamVM: TeamViewModel
    @FocusState var showKyboard: ShowKeyboard?

    @State private var inputUpdate = InputUpdateUserOrTeam()
    @State private var updateContentOpacity: CGFloat = 0

    var body: some View {

        ZStack {

            LogoMark().scaleEffect(0.5).opacity(0.2)
                .offset(y: -getRect().height / 2 + getSafeArea().top + 40)

            VStack(spacing: 40) {

                Text(selectedUpdate == .user ? "ユーザ編集" : "チーム編集")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .opacity(0.7)
                    .opacity(updateContentOpacity)
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
                .opacity(updateContentOpacity)
                .foregroundColor(.white)
                .padding(.bottom, 8)
                
                
                if selectedUpdate == .team {
                    
                    if let teamIconImage = inputUpdate.teamIconImage {
                        UIImageCircleIcon(photoImage: teamIconImage, size: 150)
                            .onTapGesture { inputUpdate.isShowTeamPickerView.toggle() }
                    } else {
                        CubeCircleIcon(size: 150)
                            .onTapGesture { inputUpdate.isShowTeamPickerView.toggle() }
                    }
                    
                } else if selectedUpdate == .user {
                    
                    if let userIconImage = inputUpdate.userIconImage {
                        UIImageCircleIcon(photoImage: userIconImage, size: 150)
                            .onTapGesture { inputUpdate.isShowUserPickerView.toggle() }
                    } else {
                        PersonCircleIcon(size: 150)
                            .onTapGesture { inputUpdate.isShowUserPickerView.toggle() }
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
                    .opacity(updateContentOpacity)

                Button("保存する") {

                    guard let team = teamVM.team else { return }
                    guard let user = userVM.user else { return }

                    switch selectedUpdate {

                    case .start:
                        print("")

                    case .user:
                        Task {
                            inputUpdate.savingWait.toggle()
                            // アイコンデータのアップロード保存
                            let iconData = await userVM.uploadUserImageData(inputUpdate.userIconImage)
                            // ユーザの名前とアイコンデータをfirestoreに保存
                            try await userVM.updateUserNameAndIcon(name: inputUpdate.nameText, data: iconData)
                            // ユーザが保持している各チームのメンバーデータ(JoinMember)を更新
                            let updateMemberData = JoinMember(memberUID: user.id, name: inputUpdate.nameText, iconURL: iconData.url)
                            try await teamVM.updateTeamJoinMemberData(data: updateMemberData, joins: user.joins)
                            // 編集画面を閉じる
                            hapticSuccessNotification()
                            withAnimation(.spring(response: 0.3)) { updateContentOpacity = 0 }
                            withAnimation(.spring(response: 0.3).delay(0.3)) {
                                selectedUpdate = .start
                                inputUpdate.savingWait.toggle()
                            }
                        }

                    case .team:
                        Task {
                            inputUpdate.savingWait.toggle()
                            // アイコンデータのアップロード保存
                            let iconData = await teamVM.uploadTeamImageData(inputUpdate.teamIconImage)
                            // チームの名前とアイコンデータをfirestoreに保存
                            try await teamVM.updateTeamNameAndIcon(name: inputUpdate.nameText, data: iconData)
                            // チームが保持している各メンバーのチームデータ(JoinTeam)を更新
                            let updateTeamData = JoinTeam(teamID: team.id, name: inputUpdate.nameText, iconURL: iconData.url)
                            try await userVM.updateUserJoinTeamData(data: updateTeamData, members: team.members)
                            // 編集画面を閉じる
                            hapticSuccessNotification()
                            withAnimation(.spring(response: 0.3)) { updateContentOpacity = 0 }
                            withAnimation(.spring(response: 0.3).delay(0.3)) {
                                selectedUpdate = .start
                                inputUpdate.savingWait.toggle()
                            }
                        }
                    }
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
                .opacity(updateContentOpacity)
                .opacity(inputUpdate.savingWait ? 0.2 : 1.0)
                .disabled(inputUpdate.savingWait ? true : false)

                Button {
                    withAnimation(.spring(response: 0.3)) { updateContentOpacity = 0 }
                    withAnimation(.spring(response: 0.3).delay(0.3)) { selectedUpdate = .start }
                } label: {
                    Label("キャンセル", systemImage: "multiply.circle.fill")
                        .foregroundColor(.white).opacity(0.7)
                }
                .offset(y: 30)
                .opacity(updateContentOpacity)
                .opacity(inputUpdate.savingWait ? 0.2 : 1.0)
                .disabled(inputUpdate.savingWait ? true : false)

            }
            .sheet(isPresented: $inputUpdate.isShowUserPickerView) {
                PHPickerView(captureImage: $inputUpdate.userIconImage,
                             isShowSheet: $inputUpdate.isShowUserPickerView,
                             isShowError: $inputUpdate.captureError)
            }
            .sheet(isPresented: $inputUpdate.isShowTeamPickerView) {
                PHPickerView(captureImage: $inputUpdate.teamIconImage,
                             isShowSheet: $inputUpdate.isShowTeamPickerView,
                             isShowError: $inputUpdate.captureError)
            }
        } // ZStack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color(.black).opacity(0.7)
                .background(.ultraThinMaterial).opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    showKyboard = nil
                }
        }

        .onChange(of: selectedUpdate) { select in
            switch select {
            case .start:
                withAnimation(.spring(response: 0.3).delay(0.3)) { updateContentOpacity = 0 }

            case .user:
                let userName = userVM.user?.name ?? ""
                inputUpdate.nameText = userName
                withAnimation(.spring(response: 0.3).delay(0.3)) { updateContentOpacity = 1 }

            case .team:
                let teamName = teamVM.team?.name ?? ""
                inputUpdate.nameText = teamName
                withAnimation(.spring(response: 0.3).delay(0.3)) { updateContentOpacity = 1 }
            }
        }
        .onAppear {
            print("チーム&ユーザ情報更新ViewがonApper")
            getUIImageByTeamUrl(url: teamVM.team?.iconURL)
            getUIImageByUserUrl(url: userVM.user?.iconURL)
        }
    } // body

    // 編集画面表示時に、元アイコンのUIImageをurlから取得
    func getUIImageByTeamUrl(url: URL?) {
        guard let url else { return }
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                inputUpdate.teamIconImage = UIImage(data: data)
                print("teamIconのurl->UIImage成功")

            } catch let err {
                print("Error : \(err.localizedDescription)")
            }
        }
    }
    
    func getUIImageByUserUrl(url: URL?) {
        guard let url else { return }
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                inputUpdate.userIconImage = UIImage(data: data)
                print("userIconのurl->UIImage成功")
                
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
