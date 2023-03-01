//
//  CreateAndJoinTeamView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/24.
//

import SwiftUI

struct CreateAndJoinTeamView: View {

    enum SelectedTeamCard {
        case start, join, create

        var background: Color {
            switch self {
            case .start: return .userGray1
            case .join: return .userBlue1
            case .create: return .userRed1
            }
        }
    }

    enum SelectTeamFase {
        case start, fase1, fase2, check, success
    }

    @StateObject var logInVM: LogInViewModel
    @StateObject var teamVM: TeamViewModel
    @StateObject var userVM: UserViewModel

    @State private var inputTeamName: String = ""
    @State private var captureImage: UIImage?
    @State private var userQRCodeImage: UIImage?
    @State private var joinedTeamData: JoinTeam?
    @State private var uploadImageData: (url: URL?, filePath: String?)
    @State private var isShowPickerView: Bool = false
    @State private var isShowSignUpSheetView: Bool = false
    @State private var isShowGoBackLogInAlert: Bool = false
    @State private var captureError: Bool = false
    @State private var selectedTeamCard: SelectedTeamCard = .start
    @State private var selectTeamFase: SelectTeamFase = .start
    @State private var customFont: CustomFont = .avenirNextUltraLight
    @State private var backgroundColor: Color = .userGray1
    @FocusState private var createNameFocused: CreateFocused?

    var body: some View {

        ZStack {

            Group {
                BlurView(style: .systemMaterialDark).opacity(0.8)
                selectedTeamCard.background.opacity(0.6)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5)) {
                            if selectTeamFase == .fase1 {
                                selectedTeamCard = .start
                            } else if selectTeamFase == .fase2 {
                                createNameFocused = nil
                            }
                        }
                    }
            }
            .ignoresSafeArea()

            LogoMark().scaleEffect(0.5).opacity(0.2)
                .offset(y: -getRect().height / 2 + getSafeArea().top + 40)

            VStack(spacing: 30) {

                switch selectedTeamCard {

                case .start:
                    VStack(spacing: 50) {
                        Text("チーム選択").tracking(10).opacity(0.6)
                        Text("どちらで始めますか？").tracking(10).opacity(0.5)
                    }
                    .padding(.bottom, 50)

                case .join:
                    VStack(spacing: 10) {
                        Text("チームに参加する").font(.title3.bold()).opacity(0.7).tracking(10)

                        Group {
                            switch selectTeamFase {

                            case .start:
                                Text("")

                            case .fase1:
                                VStack(spacing: 10) {
                                    Text("他のユーザのチームに参加します。")
                                    Text("複数人でアイテムの共有、管理が可能です。")
                                    Text("相手チームからのメンバー承認が必要です。")
                                }

                            case .fase2:
                                VStack(spacing: 10) {
                                    Text("以下の方法でチームからの承認を受けてください。")
                                        .padding(.bottom, 8)
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("方法1: QRコードを相手に読み込んでもらう。")
                                        Text("方法2: ユーザIDをコピーして相手に渡す。")
                                    }
                                    .fontWeight(.bold)
                                }

                            case .check:
                                VStack(spacing: 10) {

                                }

                            case .success:
                                VStack(spacing: 10) {
                                    Text("チームからの承認を受けました。")
                                    Text("ログインを開始します。")
                                }
                            }
                        }
                        .font(.caption).tracking(3).opacity(0.6)
                        .frame(height: 60)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 40)

                case .create:

                    VStack(spacing: 10) {
                        Text("チームを作る").font(.title3.bold()).opacity(0.7).tracking(10)

                        Group {
                            switch selectTeamFase {

                            case .start:
                                Text("")

                            case .fase1:
                                VStack(spacing: 10) {
                                    Text("あなたのチームを新しく作成します。")
                                    Text("アイテムの在庫や売上、情報の管理ができます。")
                                    Text("また、チームに他の人を招待することも可能です。")
                                }

                            case .fase2:
                                VStack(spacing: 10) {
                                    Text("チーム情報を入力してください。")
                                    Text("入力が完了したら、チーム生成を開始します。")
                                }

                            case .check:
                                VStack(spacing: 10) {
                                    if selectTeamFase == .check {
                                        Text("チーム作成中...")
                                        ProgressView()
                                    } else {
                                        Text("チーム情報を入力してください。")
                                        Text("入力が完了したら、チーム生成を開始します。")
                                    }
                                }

                            case .success:
                                VStack(spacing: 10) {
                                    Text("チームの作成が完了しました。")
                                    Text("ログインを開始します。")
                                }
                            }
                        }
                        .font(.caption).tracking(3).opacity(0.6)
                        .frame(height: 60)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 40)
                }

                // create team contents...
                // faseによってoffsetを更新するサイドスライドアニメーション
                ZStack {
                    if selectTeamFase == .start || selectTeamFase == .fase1 || selectTeamFase == .fase2 {
                        HStack(spacing: 15) {
                            joinTeamCardView()
                            Text("<>")
                                .font(.title3).foregroundColor(.white)
                                .opacity(selectedTeamCard == .start ? 0.6 : 0.0)
                            createTeamCardView()
                        }
                        .opacity(selectTeamFase == .fase1 ? 1.0 : 0.0)
                        .offset(x: selectTeamFase == .fase1 ? 0 : selectTeamFase == .start ? getRect().width : -getRect().width)

                        Group {
                            switch selectedTeamCard {
                            case .start:
                                EmptyView()
                            case .create:
                                createTeamIconAndName(captureImage: captureImage)
                            case .join:
                                if selectTeamFase != .success {
                                    VStack(spacing: 40) {
                                        if let userQRCodeImage {
                                            Image(uiImage: userQRCodeImage)
                                                .resizable()
                                                .frame(width: 200, height: 200)
                                                .padding(.top, 20)
                                        } else {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: 200, height: 200)
                                                    .foregroundColor(.black.opacity(0.8))
                                                Button {
                                                    userQRCodeImage = logInVM.generateUserQRCode(with: userVM.uid ?? "")
                                                } label: {
                                                    Image(systemName: "goforward")
                                                        .foregroundColor(.white)
                                                }
                                            }.padding(.top, 20)

                                        }

                                        VStack {
                                            Text("あなたのユーザID")
                                                .opacity(0.6).tracking(4)
                                                .font(.subheadline)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .foregroundColor(.black)
                                                    .padding(.horizontal, 40)
                                                Text(userVM.uid ?? "ユーザIDが見つかりません")
                                                    .textSelection(.enabled)
                                                    .padding(8)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 220)
                        .opacity(selectTeamFase == .fase2 || selectTeamFase == .check ? 1.0 : 0.0)
                        .offset(x: selectTeamFase == .fase2 || selectTeamFase == .check ? 0 :
                                    selectTeamFase == .start || selectTeamFase == .fase1 ? getRect().width : -getRect().width)
                    }

                    if selectTeamFase == .success {
                        joinedTeamIconAndName(url: joinedTeamData?.iconURL, name: joinedTeamData?.name)
//                            .opacity(selectTeamFase == .success ? 1.0 : 0.0)
                    }
                } // ZStack

            } // VStack
            .foregroundColor(.white)
            .offset(y: -30)
            .opacity(selectTeamFase == .start ? 0.0 : 1.0)

            Button(selectTeamFase == .fase1 ? "決定して次へ" : "これで始める") {
                if  selectTeamFase == .fase1 {
                    withAnimation(.spring(response: 0.7)) {
                        selectTeamFase = .fase2
                    }
                } else if selectTeamFase == .fase2 {
                    withAnimation(.spring(response: 0.5)) {
                        selectTeamFase = .check
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .offset(y: getRect().height * 0.3)
            .opacity(selectTeamFase == .start || selectTeamFase == .success ? 0.0 : 1.0)
            .opacity(selectedTeamCard == .join && selectTeamFase == .fase2 ? 0.0 : 1.0)
            .disabled(selectedTeamCard == .start || selectTeamFase == .success ? true : false)
            .disabled(selectedTeamCard == .join && userVM.isAnonymous ? true : false)

            Button("<戻る") {
                withAnimation(.spring(response: 0.7)) {
                    selectTeamFase = .fase1
                }
            }
            .foregroundColor(.white.opacity(0.7))
            .offset(y: getRect().height * 0.36)
            .opacity(selectTeamFase == .fase2 ? 1.0 : 0.0)
            .disabled(selectTeamFase == .success ? true : false)

            // Go back login flow Button...
            Button {
                isShowGoBackLogInAlert.toggle()
            } label: {
                HStack {
                    Text("<<")
                    Image(systemName: "house.fill")
                }
            }
            .disabled(selectTeamFase == .success ? true : false)
            .foregroundColor(.white.opacity(0.5))
            .opacity(selectTeamFase == .start ? 0.0 : 1.0)
            .offset(x: -getRect().width / 2 + 40, y: getRect().height / 2 - 60 )
            .alert("確認", isPresented: $isShowGoBackLogInAlert) {

                Button {
                    teamVM.isShowCreateAndJoinTeam.toggle()
                } label: {
                    Text("いいえ")
                }

                Button {
                    withAnimation(.spring(response: 1.0)) {
                        logInVM.rootNavigation = .logIn
                        teamVM.isShowCreateAndJoinTeam.toggle()
                    }
                    logInVM.logOut()
                    
                } label: {
                    Text("はい")
                }
            } message: {
                Text("ログイン画面に戻ります。よろしいですか？")
            } // alert
            
            // Getting Started button...
            Button {
                // todo: navigateTabView?
                
                
            } label: {
                HStack {
                    Text("あとで決める")
                    Text(">>")
                }
                .font(.subheadline).tracking(2).opacity(0.8)
            }
            .disabled(selectTeamFase == .success ? true : false)
            .foregroundColor(.white.opacity(0.6))
            .opacity(selectTeamFase == .start || selectTeamFase == .fase1 ? 0.0 : 1.0)
            .offset(x: getRect().width / 2 - 80, y: getRect().height / 2 - 60 )
        } // ZStack

        // 「チームに参加」により、相手から承認を受け、チーム情報を受け取ることでリスナーが変更を検知し、作動する
        // 受け取ったチームの情報をもとに、ログインを行う
        .onChange(of: userVM.updatedUser) { _ in
            print("=========user情報の更新を検知=========")
            if selectedTeamCard == .join {
                guard let user = userVM.user else { return }
                for joinTeam in user.joins where joinTeam.teamID == user.lastLogIn {
                    self.joinedTeamData = joinTeam
                }
                withAnimation(.spring(response: 1.5, blendDuration: 1)) { selectTeamFase = .success }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.spring(response: 0.5)) { logInVM.rootNavigation = .fetch }
                }
            }
        }

        .onChange(of: selectTeamFase) { _ in

            if selectTeamFase == .check {

                guard let user = userVM.user else {
                    print("user情報が取得できません。チーム追加処理を終了しました。")
                    return
                }
                print("check開始")
                Task {
                    do {
                        if inputTeamName.isEmpty { inputTeamName = "No Name" }
                        // チームデータに格納するログインユーザのユーザデータ
                        let joinMember = JoinMember(memberUID: user.id, name: user.name, iconURL: user.iconURL)
                        // teamsに格納する際のドキュメントID
                        let teamID = UUID().uuidString
                        await uploadImageData = logInVM.uploadImage(captureImage)
                        let teamData = Team(id: teamID,
                                            name: inputTeamName,
                                            iconURL: uploadImageData.url,
                                            iconPath: uploadImageData.filePath,
                                            members: [joinMember])
                        let joinTeamData = JoinTeam(teamID: teamID,
                                                    name: inputTeamName,
                                                    iconURL: uploadImageData.url)
                        try await teamVM.addTeam(teamData: teamData)
                        try await userVM.addNewJoinTeam(newJoinTeam: joinTeamData)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.spring(response: 1)) {
                                selectTeamFase = .success
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.spring(response: 1)) {
                                    teamVM.isShowCreateAndJoinTeam.toggle()
                                    logInVM.rootNavigation = .fetch
                                }
                            }
                        }

                    } catch CustomError.uidEmpty {
                        print("Error: uidEmpty")
                    } catch CustomError.getRef {
                        print("Error: getRef")
                    } catch CustomError.fetch {
                        print("Error: fetch")
                    } catch CustomError.getDocument {
                        print("Error: getDocument")
                    } catch {
                        print("Error")
                    }
                }
            }
        }

        .onAppear {
            // currentUserのuidをQRコードに変換
            userQRCodeImage = logInVM.generateUserQRCode(with: userVM.uid ?? "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 1.0)) {
                    selectTeamFase = .fase1
                }
            }
        }
        .sheet(isPresented: $isShowSignUpSheetView) {
            LogInView(logInVM: logInVM, teamVM: teamVM, logInViewShowType: .sheet)
        }
        .sheet(isPresented: $isShowPickerView) {
            PHPickerView(captureImage: $captureImage, isShowSheet: $isShowPickerView, isShowError: $captureError)
        }
    }

    @ViewBuilder
    func joinTeamCardView() -> some View {
        ZStack {
            BlurView(style: .systemUltraThinMaterialDark)
            Color.userBlue1
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: 1).opacity(0.3)
                .frame(width: getRect().width * 0.35, height: getRect().height * 0.23)

            VStack(spacing: 50) {
                Image(systemName: "person.3.fill").resizable().scaledToFit().frame(width: 80)
                .foregroundColor(.white)
                cubeRow(color1: .userRed2, color2: .userRedAccent)
                    .background {
                        cubeRow(color1: .userBlue2, color2: .userBlueAccent).opacity(0.5)
                            .offset(x: -25, y: -10)
                    }
                    .background {
                        cubeRow(color1: .userYellow2, color2: .userYellowAccent).opacity(0.3)
                            .offset(x: 25, y: -12)
                    }
            }
            
            if userVM.isAnonymous {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.black)
                    .opacity(selectedTeamCard == .join ? 0.8 : 0.3)
                    .frame(width: getRect().width * 0.4, height: getRect().height * 0.25)
                
                VStack(spacing: 5) {
                    Text("この機能は")
                    Text("ユーザ登録が")
                    Text("必要です")
                }
                .foregroundColor(.white)
                .font(.footnote).tracking(4)
                .opacity(selectedTeamCard == .join ? 0.6 : 0.0)
                
                
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: getRect().width * 0.4, height: getRect().height * 0.25)
        .scaleEffect(selectedTeamCard == .join ? 1.4 : selectedTeamCard == .create ? 0.8 : 1.0)
        .offset(x: selectedTeamCard == .join ? 30 : 0)
        .opacity(selectedTeamCard == .join ? 1.0 : selectedTeamCard == .start ? 0.8 : 0.2)
        .onTapGesture {
            withAnimation(.spring(response: 0.5)) {
                selectedTeamCard = selectedTeamCard == .start || selectedTeamCard == .create ? .join : .start
            }
        }
    }

    func createTeamCardView() -> some View {
        ZStack {
            BlurView(style: .systemUltraThinMaterialDark)
            Color.userRed1
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: 1).opacity(0.3)
                .frame(width: getRect().width * 0.35, height: getRect().height * 0.23)

            VStack(spacing: 40) {
                Image(systemName: "person.fill").resizable().scaledToFit().frame(width: 50)
                .foregroundColor(.white)
                cubeRow(color1: .userYellow2, color2: .userYellowAccent)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: getRect().width * 0.4, height: getRect().height * 0.25)
        .scaleEffect(selectedTeamCard == .create ? 1.4 : selectedTeamCard == .join ? 0.8 : 1.0)
        .offset(x: selectedTeamCard == .create ? -30 : 0)
        .opacity(selectedTeamCard == .create ? 1.0 : selectedTeamCard == .start ? 0.8 : 0.2)
        .onTapGesture {
            withAnimation(.spring(response: 0.5)) {
                selectedTeamCard = selectedTeamCard == .start || selectedTeamCard == .join ? .create : .start
            }
        }
    }

    func createTeamIconAndName(captureImage: UIImage?) -> some View {
        Group {
            VStack(spacing: 40) {
                Group {
                    if let captureImage = captureImage {
                        UIImageCircleIcon(photoImage: captureImage, size: 150)
                    } else {
                        Image(systemName: "photo.circle.fill").resizable().scaledToFit()
                            .foregroundColor(.white.opacity(0.5)).frame(width: 150)
                    }
                }
                .onTapGesture { isShowPickerView.toggle() }
                .overlay(alignment: .top) {
                    Text("チーム情報は後から変更できます。").font(.caption)
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 200)
                    .offset(y: -30)
                }

                TextField("", text: $inputTeamName)
                    .frame(width: 230)
                    .focused($createNameFocused, equals: .check)
                    .textInputAutocapitalization(.never)
                    .multilineTextAlignment(.center)
                    .background {
                        ZStack {
                            Text(createNameFocused == nil && inputTeamName.isEmpty ? "チーム名を入力" : "")
                                .foregroundColor(.white.opacity(0.3))
                            Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                                .offset(y: 20)
                        }
                    }
            }
        }
    }

    func joinedTeamIconAndName(url photoURL: URL?, name teamName: String?) -> some View {
        Group {
            VStack(spacing: 40) {
                Group {
                    if let photoURL {
                        AsyncImageCircleIcon(photoURL: photoURL, size: 150)
                    } else {
                        Image(systemName: "person.2.fill").resizable().scaledToFit()
                            .foregroundColor(.white.opacity(0.5)).frame(width: 150)
                    }
                }

                Text(teamName ?? "No Name")
                    .foregroundColor(.white)
                    .tracking(5)
            }
        }
    }

    func cubeRow(color1: Color, color2: Color) -> some View {
        Image(systemName: "cube").resizable().scaledToFit().frame(width: 40)
            .font(.custom(customFont.font, fixedSize: 50)).opacity(0.7).foregroundColor(.white)
            .background {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [color1, color2]),
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 30)
            }
    }
}

struct CreateAndJoinTeamView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAndJoinTeamView(logInVM: LogInViewModel(),
                              teamVM: TeamViewModel(),
                              userVM: UserViewModel())
    }
}
