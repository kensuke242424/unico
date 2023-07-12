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

    @EnvironmentObject var logInVM: LogInViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tagVM: TagViewModel
    @EnvironmentObject var backgroundVM: BackgroundViewModel

    @State private var inputTeamName: String = ""
    @State private var captureIconUIImage: UIImage?
    @State private var userQRCodeImage: UIImage?
    @State private var joinedTeamData: JoinTeam?
    @State private var uploadImageData: (url: URL?, filePath: String?)

    @State private var isShowPickerView: Bool = false
    @State private var isShowSignUpSheetView: Bool = false
    @State private var isShowGoBackAlert: Bool = false

    @State private var captureError: Bool = false
    @State private var selectedTeamCard: SelectedTeamCard = .start
    @State private var selectTeamFase: SelectTeamFase = .start
    @State private var customFont: CustomFont = .avenirNextUltraLight
    @State private var backgroundColor: Color = .userGray1
    @FocusState private var createNameFocused: ShowKyboard?

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

            LogoMark()
                .scaleEffect(0.4)
                .opacity(0.2)
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
                                    Text("他のユーザーのチームに参加します。")
                                    Text("複数人でアイテムの共有、管理が可能です。")
                                    Text("相手チームからのメンバー承認が必要です。")
                                }

                            case .fase2:
                                VStack(spacing: 10) {
                                    Text("以下の方法でチームからの承認を受けてください。")
                                        .padding(.bottom, 8)
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("方法1: QRコードを相手に読み込んでもらう。")
                                        Text("方法2: ユーザーIDをコピーして相手に渡す。")
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
                        .font(.caption).tracking(3).opacity(0.8)
                        .frame(height: 60)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, selectTeamFase == .success ? 0 : 40)
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
                                createTeamIconAndName()

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
                                            Text("あなたのユーザーID")
                                                .opacity(0.6).tracking(4)
                                                .font(.subheadline)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .foregroundColor(.black)
                                                    .padding(.horizontal, 40)
                                                Text(userVM.uid ?? "ユーザーIDが見つかりません")
                                                    .textSelection(.enabled)
                                                    .padding(8)
                                            }
                                        }
                                    }
                                } // if selectTeamFase != .success
                            }
                        }
                        .frame(height: 220)
                        .opacity(selectTeamFase == .fase2 || selectTeamFase == .check ? 1.0 : 0.0)
                        .offset(x: selectTeamFase == .fase2 || selectTeamFase == .check ? 0 :
                                    selectTeamFase == .start || selectTeamFase == .fase1 ? getRect().width : -getRect().width)
                    }

                    if selectTeamFase == .success {
                        joinedTeamIconAndName(image:captureIconUIImage, name: joinedTeamData?.name)
                    }
                } // ZStack
                
                if selectTeamFase != .check && selectTeamFase != .success {
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
                    .opacity(selectTeamFase == .start || selectTeamFase == .success ? 0 : 1)
                    .opacity(selectedTeamCard == .join && selectTeamFase == .fase2 ? 0 : 1)
                    .disabled(selectedTeamCard == .start || selectTeamFase == .success ? true : false)
                    .disabled(selectedTeamCard == .join && userVM.isAnonymous ? true : false)
                    .padding(.top, 30)
                }
                
                Button("<戻る") {
                    withAnimation(.spring(response: 0.7)) {
                        selectTeamFase = .fase1
                    }
                }
                .buttonStyle(.bordered)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.5))
                .opacity(selectTeamFase == .fase2 ? 1.0 : 0.0)
                .disabled(selectTeamFase == .success ? true : false)
                .padding(.top)

            } // VStack
            .foregroundColor(.white)
            .offset(y: 30)
            .opacity(selectTeamFase == .start ? 0.0 : 1.0)

            

            // Go back login flow Button...
            Button {
                isShowGoBackAlert.toggle()
            } label: {
                HStack {
                    Text("<<")
                    Image(systemName: "house.fill")
                }
                .foregroundColor(.white.opacity(0.5))
            }
            .buttonStyle(.bordered)
            .disabled(selectTeamFase == .success ? true : false)
            .opacity(selectTeamFase == .start ? 0 : 1.0)
            .offset(x: -getRect().width / 2 + 40, y: getRect().height / 2 - 60 )
            .alert("", isPresented: $isShowGoBackAlert) {

                Button {
                    teamVM.isShowCreateAndJoinTeam.toggle()
                } label: {
                    Text("いいえ")
                }

                Button {
                    withAnimation(.spring(response: 1.0)) {
                        logInVM.rootNavigation = .fetch
                        
                        teamVM.isShowCreateAndJoinTeam.toggle()
                    }
                    
                } label: {
                    Text("はい")
                }
            } message: {
                Text("チーム追加をやめて戻りますか？")
            } // alert
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

        // ✅チーム生成と保存処理
        .onChange(of: selectTeamFase) { _ in

            if selectTeamFase == .check {

                guard let user = userVM.user else {
                    print("user情報が取得できません。チーム追加処理を終了しました。")
                    return
                }
                
                Task {
                    do {
                        let userName = userVM.user?.name ?? "名無し"
                        if inputTeamName.isEmpty { inputTeamName = "\(userName)のチーム" }
                        
                        // 背景、アイコン画像をリサイズして保存していく
                        let createTeamID = UUID().uuidString
                        var iconImageContainer      : UIImage?
                        var backgroundImageContainer: UIImage?

                        // アイコン画像が入力されていれば、リサイズ処理をしてコンテナに格納
                        if let captureIconUIImage {
                            iconImageContainer = logInVM.resizeUIImage(image: captureIconUIImage,
                                                                    width: 60)
                        }

                        // 選択カテゴリがオリジナル&背景画像データが入力されていれば、リサイズ処理をしてコンテナに格納
                        if backgroundVM.selectCategory == .original {
                            if let captureBackgroundUIImage = backgroundVM.captureUIImage {

                                let resizedBackgroundUIImage = logInVM.resizeUIImage(image: captureBackgroundUIImage,
                                                                                 width: getRect().width * 4)
                                backgroundImageContainer = resizedBackgroundUIImage

                            } else {
                                /// 入力背景画像がnilだった場合、サンプル画像から一つランダムで選出し、コンテナに格納
                                let randomPickUpBackground = teamVM.getRandomBackgroundUIImage()
                                backgroundImageContainer = randomPickUpBackground
                            }

                        } else {
                            /// 入力背景画像がnilだった場合、サンプル画像から一つランダムで選出し、コンテナに格納
                            let randomPickUpBackground = teamVM.getRandomBackgroundUIImage()
                            backgroundImageContainer = randomPickUpBackground
                        }

                        /// 準備したチームアイコン&背景画像をFirestorageに保存
                        let uplaodIconImageData       = await teamVM.firstUploadTeamImage(iconImageContainer,
                                                                                          id: createTeamID)
                        let uplaodBackgroundImageData = await teamVM.firstUploadTeamImage(backgroundImageContainer,
                                                                                          id: createTeamID)
                        
                        // チームデータに格納するログインユーザのユーザデータ
                        let joinMember = JoinMember(memberUID: user.id,
                                                    name     : user.name,
                                                    iconURL  : user.iconURL)
                        
                        let teamData = Team(id: createTeamID,
                                            name          : inputTeamName,
                                            iconURL       : uplaodIconImageData.url,
                                            iconPath      : uplaodIconImageData.filePath,
                                            backgroundURL : uplaodBackgroundImageData.url,
                                            backgroundPath: uplaodBackgroundImageData.filePath,
                                            members       : [joinMember])
                        
                        let joinTeamData = JoinTeam(teamID : createTeamID,
                                                    name   : inputTeamName,
                                                    iconURL: uplaodIconImageData.url)
                        
                        // 作成or参加したチームをView表示する用のプロパティ
                        self.joinedTeamData = joinTeamData
                        
                        try await teamVM.addTeam(teamData: teamData)
                        try await userVM.addNewJoinTeam(newJoinTeam: joinTeamData)
                            await teamVM.setSampleItem(teamID: teamData.id)
                            tagVM.addTag(tagData: tagVM.sampleTag, teamID: teamData.id)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
                        print("Error: other.")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowPickerView) {
            PHPickerView(captureImage: $captureIconUIImage, isShowSheet: $isShowPickerView)
        }
        .sheet(isPresented: $isShowSignUpSheetView) {
            UserEntryRecommendationView(isShow: $isShowSignUpSheetView)
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
                    .opacity(selectedTeamCard == .join ? 0.8 : 0)
                    .frame(width: getRect().width * 0.4, height: getRect().height * 0.25)

                VStack(spacing: 20) {

                    VStack(spacing: 5) {
                        Text("この機能は")
                        Text("アカウント登録が")
                        Text("必要です")
                    }
                    .font(.footnote)
                    .fontWeight(.bold)
                    .tracking(4)
                    .foregroundColor(.white)
                    .opacity(selectedTeamCard == .join ? 0.6 : 0)

                    Button("アカウント登録") {
                        // エントリーシート画面の表示
                        isShowSignUpSheetView.toggle()
                    }
                    .font(.caption2)
                    .buttonStyle(.borderedProminent)
                    .opacity(selectedTeamCard == .join ? 1 : 0)
                }
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
        .overlay(alignment: .top) {
            Text("参加する")
                .foregroundColor(.white)
                .font(.headline).tracking(8)
                .offset(y: -30)
                .opacity(selectedTeamCard == .start ? 0.7 : 0.0)
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
        .overlay(alignment: .top) {
            Text("作る")
                .foregroundColor(.white)
                .font(.headline).tracking(8)
                .offset(y: -30)
                .opacity(selectedTeamCard == .start ? 0.7 : 0.0)
        }
    }

    func createTeamIconAndName() -> some View {
        Group {
            VStack(spacing: 40) {
                Group {
                    if let captureIconUIImage {
                        UIImageCircleIcon(photoImage: captureIconUIImage, size: 150)
                    } else {
                        Image(systemName: "photo.circle.fill").resizable().scaledToFit()
                            .foregroundColor(.white.opacity(0.8)).frame(width: 150)
                    }
                }
                .onTapGesture { isShowPickerView.toggle() }
                .overlay(alignment: .top) {
                    Text("チーム情報は後から変更できます。").font(.caption)
                    .foregroundColor(.white.opacity(0.6))
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
                                .foregroundColor(.white.opacity(0.6))
                            Rectangle().foregroundColor(.white.opacity(0.8)).frame(height: 1)
                                .offset(y: 20)
                        }
                    }
            }
        }
    }

    func joinedTeamIconAndName(image iconUIImage: UIImage?, name teamName: String?) -> some View {
        Group {
            VStack(spacing: 40) {
                Group {
                    if let iconUIImage {
                        UIImageCircleIcon(photoImage: iconUIImage, size: 150)
                    } else {
                        CubeCircleIcon(size: 150)
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
        CreateAndJoinTeamView()
    }
}
