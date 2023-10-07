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
    @State private var croppedIconUIImage: UIImage?
    @State private var userQRCodeImage: UIImage?
    @State private var joinedTeamData: JoinTeam?
    @State private var uploadImageData: (url: URL?, filePath: String?)

    @State private var showPicker: Bool = false
    @State private var isShowSignUpSheetView: Bool = false
    @State private var isShowGoBackAlert: Bool = false

    @State private var captureError: Bool = false
    @State private var selectedTeamCard: SelectedTeamCard = .start
    @State private var selectTeamFase: SelectTeamFase = .start
    @State private var customFont: CustomFont = .avenirNextUltraLight
    @State private var backgroundColor: Color = .userGray1
    @FocusState private var createNameFocused: ShowKeyboard?

    var cardSize: CGSize {
        return CGSize(width: userDeviseSize == .medium ? 150 : 130,
                      height: userDeviseSize == .medium ? 200 : 180)
    }

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
                        Text("チームに参加する")
                            .font(userDeviseSize == .small ? .body : .title3)
                            .fontWeight(.bold)
                            .opacity(0.7)
                            .tracking(10)

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
                                        Text("方法2: ユーザーIDを相手に渡す。")
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
                        Text("チームを作る")
                            .font(userDeviseSize == .small ? .body : .title3)
                            .fontWeight(.bold)
                            .opacity(0.7)
                            .tracking(10)

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
                    .padding(.bottom, selectTeamFase == .success ? 0 :
                                userDeviseSize == .small ? 20 : 40)
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
                                                .frame(width: 150, height: 150)
                                        } else {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: 150, height: 150)
                                                    .foregroundColor(.black.opacity(0.8))
                                                Button {
                                                    userQRCodeImage = logInVM.generateUserQRCode(with: userVM.uid ?? "")
                                                } label: {
                                                    Image(systemName: "goforward")
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }

                                        VStack {
                                            Text("あなたのユーザーID")
                                                .opacity(0.6).tracking(4)
                                                .font(.subheadline)
                                            Text(userVM.uid ?? "ユーザーIDが見つかりません")
                                                .font(userDeviseSize == .medium ? .body : .callout)
                                                .textSelection(.enabled)
                                                .padding(8)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 3)
                                                        .foregroundColor(.black)
                                                }
                                                .padding(.horizontal, 40)

                                            HStack(spacing: 30) {
                                                Button {
                                                    if let idString = userVM.uid {
                                                        UIPasteboard.general.string = idString
                                                        print(idString.count)
                                                        hapticActionNotification()
                                                    }

                                                } label: {
                                                    Label("IDをコピー", systemImage: "doc.on.doc.fill")
                                                        .font(.subheadline)
                                                }
                                                .padding(5)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(.black)
                                                        .opacity(0.3)
                                                }
                                                ShareLink(item: userVM.uid ?? "",
                                                          preview: SharePreview(
                                                            "ユーザーIDを共有",
                                                            image: Image("unico_logo_a3")
                                                          )
                                                ) {
                                                    Label("IDを送る", systemImage: "square.and.arrow.up.fill")
                                                        .font(.subheadline)
                                                }
                                                .padding(5)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(.black)
                                                        .opacity(0.3)
                                                }
                                            }
                                            .offset(y: 15)
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
                    /// 相手チームのチーム名とアイコンを表示するビューメソッド。
                    /// 相手チームからの参加許可に検知時に、参加アナウンスとともに表示される。
                    if selectTeamFase == .success {
                        joinedTeamIconAndName(url:joinedTeamData?.iconURL,
                                              name: joinedTeamData?.name)
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
                    .font(userDeviseSize == .small ? .callout : .body)
                    .buttonStyle(.borderedProminent)
                    .opacity(selectTeamFase == .start || selectTeamFase == .success ? 0 : 1)
                    .opacity(selectedTeamCard == .join && selectTeamFase == .fase2 ? 0 : 1)
                    .disabled(selectedTeamCard == .start || selectTeamFase == .success ? true : false)
//                    .disabled(selectedTeamCard == .join && userVM.isAnonymous ? true : false) // 匿名は使えない
                    .padding(.top, userDeviseSize == .small ? 15 : 30)
                }
                
                Button("<戻る") {
                    withAnimation(.spring(response: 0.7)) {
                        selectTeamFase = .fase1
                    }
                }
                .font(userDeviseSize == .small ? .callout : .body)
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
            .disabled(selectTeamFase == .success ? true : false)
            .opacity(selectTeamFase == .start ? 0 : 1.0)
            .offset(x: -getRect().width / 2 + 40, y: getRect().height / 2 - 60 )
            .alert("", isPresented: $isShowGoBackAlert) {

                Button("いいえ") {}

                Button("はい") {
                    if userVM.joins.isEmpty {
                        withAnimation(.spring(response: 1.0)) {
                            logInVM.rootNavigation = .logIn
                            teamVM.isShowCreateAndJoinTeam.toggle()
                        }
                        // 匿名ユーザーがチームを作成せずにログイン画面へ戻った時の処理
                        // userドキュメントとAuthデータを削除しておく
                        if userVM.isAnonymous {
                            Task {
                                try await userVM.deleteUserDocument()
                                try await logInVM.deleteAuth()
                            }
                        }
                    } else {
                        withAnimation(.spring(response: 1.0)) {
                            logInVM.rootNavigation = .fetch
                            teamVM.isShowCreateAndJoinTeam.toggle()
                        }
                    }
                }
            } message: {
                if userVM.joins.isEmpty {
                    Text("チーム作成をやめてログイン画面に戻りますか？")
                } else {
                    Text("チーム追加をやめて戻りますか？")
                }
            } // alert
        } // ZStack
        .overlay {
            if userVM.showJoinedTeamInformation {
                JoinedTeamInformationView(presented: $userVM.showJoinedTeamInformation)
                    .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
            }
        }
        // 新規チームへの加入が検知されたら、新規加入報告ビューを表示
        .task(id: userVM.newJoinedTeam) {
            if logInVM.rootNavigation != .join { return }
            guard let _ = userVM.newJoinedTeam else { return }

            print("=========他チームからのチーム加入承諾を検知=========")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    userVM.showJoinedTeamInformation = true
                    hapticSuccessNotification()
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
                        var iconImageContainer: UIImage?
                        var backgroundContainer: Background = backgroundVM.sampleBackground

                        // アイコン画像が入力されていれば、リサイズ処理をしてコンテナに格納
                        if let croppedIconUIImage {
                            iconImageContainer = logInVM.resizeUIImage(image: croppedIconUIImage,
                                                                    width: 60)
                        }
                        /// 準備したチームアイコン&背景画像をFirestorageに保存
                        let uplaodIconImageData = await teamVM.firstUploadTeamImage(iconImageContainer,
                                                                                    id: createTeamID)
                        
                        let teamData = Team(id            : createTeamID,
                                            name          : inputTeamName,
                                            iconURL       : uplaodIconImageData.url,
                                            iconPath      : uplaodIconImageData.filePath,
                                            backgroundURL : backgroundContainer.imageURL,
                                            backgroundPath: backgroundContainer.imagePath)
                        
                        let joinTeamData = JoinTeam(id : createTeamID,
                                                    name   : inputTeamName,
                                                    iconURL: uplaodIconImageData.url,
                                                    currentBackground: backgroundContainer)
                        
                        // 作成or参加したチームをView表示する用のプロパティ
                        self.joinedTeamData = joinTeamData
                        
                        try await teamVM.addNewTeam(team: teamData)
                        try await teamVM.addFirstMemberToFirestore(teamId: teamData.id, data: user)
                        try await userVM.addNewJoinTeam(data: joinTeamData)
                        try await userVM.updateLastLogInTeam(teamId: teamData.id)
                            await teamVM.setSampleItem(teamID: teamData.id)
                            await tagVM.setSampleTag(teamID: teamData.id)

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
        .cropImagePicker(option: .circle,
                         show: $showPicker,
                         croppedImage: $croppedIconUIImage)
        .sheet(isPresented: $isShowSignUpSheetView) {
            UserEntryRecommendationView(isShow: $isShowSignUpSheetView)
        }

        .onAppear {

            Task {
                try await userVM.joinsListener() // ← チームからの加入許可をリスニングするために必要
            }

            // currentUserのuidをQRコードに変換
            userQRCodeImage = logInVM.generateUserQRCode(with: userVM.uid ?? "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 1.0)) {
                    selectTeamFase = .fase1
                }
            }
        }
    }
    /// 他チーム参加フェーズの選択を管理するカード型のビュー。
    /// ユーザーが匿名アカウントの場合は、カード上にアカウント登録ボタンを表示し、
    /// カードを選択できない状態になる。
    @ViewBuilder
    func joinTeamCardView() -> some View {
        ZStack {
            BlurView(style: .systemUltraThinMaterialDark)
            Color.userBlue1
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: 1).opacity(0.3)
                .frame(width: cardSize.width * 0.9, height: cardSize.height * 0.9)

            VStack(spacing: 50) {
                Image(systemName: "person.3.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: userDeviseSize == .small ? 70 : 80)
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
                    .frame(width: cardSize.width, height: cardSize.height)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "lock.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.yellow)
                            .opacity(selectedTeamCard == .join ? 1 : 0)
                    }

                VStack(spacing: 20) {

                    VStack(spacing: 5) {
                        Text("この機能は")
                        Text("アカウント登録が")
                        Text("必要です")
                    }
                    .font(userDeviseSize == .medium ? .footnote : .caption2)
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
        .frame(width: cardSize.width, height: cardSize.height)
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
    /// チーム新規作成フェーズの選択を管理するカード型のビュー。
    @ViewBuilder
    func createTeamCardView() -> some View {
        ZStack {
            BlurView(style: .systemUltraThinMaterialDark)
            Color.userRed1
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: 1).opacity(0.3)
                .frame(width: cardSize.width * 0.9, height: cardSize.height * 0.9)

            VStack(spacing: 40) {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: userDeviseSize == .small ? 40 : 50)
                    .foregroundColor(.white)
                cubeRow(color1: .userYellow2, color2: .userYellowAccent)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: cardSize.width, height: cardSize.height)
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
    /// 新規作成したチームのチーム名とアイコンを表示するビュー。
    /// 作成完了のアナウンスとともに、チーム部屋ログインの直前に表示される。
    @ViewBuilder
    func createTeamIconAndName() -> some View {
        Group {
            VStack(spacing: 40) {
                Group {
                    if let croppedIconUIImage {
                        UIImageCircleIcon(photoImage: croppedIconUIImage, size: 150)
                    } else {
                        CubeCircleIcon(size: userDeviseSize == .medium ? 150 : 130)
                    }
                }
                .onTapGesture { showPicker.toggle() }
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
    /// 相手チームのチーム名とアイコンを表示するビューメソッド。
    /// 相手チームからの参加許可に検知時に、参加アナウンスとともに表示される。
    @ViewBuilder
    func joinedTeamIconAndName(url iconImageURL: URL?, name teamName: String?) -> some View {
        Group {
            VStack(spacing: 40) {
                Group {
                    if let iconImageURL {
                        SDWebImageCircleIcon(imageURL: iconImageURL, width: 150, height: 150)
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
