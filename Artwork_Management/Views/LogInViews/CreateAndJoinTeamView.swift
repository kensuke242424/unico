//
//  CreateAndJoinTeamView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/24.
//

import SwiftUI

struct CreateAndJoinTeamView: View {

    enum SelectTeamCard {
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

    @State private var teamName: String = ""
    @State private var captureImage: UIImage = UIImage()
    @State private var uploadImageData: (url: URL?, filePath: String?) = (nil, nil)
    @State private var isShowPickerView: Bool = false
    @State private var captureError: Bool = false
    @State private var selectTeamCard: SelectTeamCard = .start
    @State private var selectTeamFase: SelectTeamFase = .start
    @State private var customFont: CustomFont = .avenirNextUltraLight
    @State private var backgroundColor: Color = .userGray1
    @FocusState private var createNameFocused: CreateFocused?

    var body: some View {

        ZStack {

            Group {
                BlurView(style: .systemMaterialDark).opacity(0.8)
                selectTeamCard.background.opacity(0.6)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5)) {
                            if selectTeamFase == .fase1 {
                                selectTeamCard = .start
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

                switch selectTeamCard {

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
                                    Text("「ユーザID」をコピーして相手に渡します。")
                                    Text("または、QRコードを表示して相手に見せてください。")
                                    Text("メンバー承認が完了次第、自動でログインを開始します。")
                                }

                            case .check:
                                VStack(spacing: 10) {

                                }

                            case .success:
                                Text("チームが見つかりました。ログインを開始します。")
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
                                    Text("あなたの素晴らしい活動を応援しています。")
                                }

                            case .fase2:
                                VStack(spacing: 10) {
                                    Text("チーム情報を入力してください。")
                                    Text("入力が完了したら、チーム生成を開始します。")
                                }

                            case .check:
                                Text("")

                            case .success:
                                VStack(spacing: 10) {
                                    Text("お疲れ様でした。")
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
                ZStack {
                    if selectTeamFase != .success {
                        HStack(spacing: 15) {
                            joinCard()
                            Text("<>")
                                .font(.title3).foregroundColor(.white)
                                .opacity(selectTeamCard == .start ? 0.6 : 0.0)
                            createCard()
                        }
                        .opacity(selectTeamFase == .fase1 ? 1.0 : 0.0)
                        .offset(x: selectTeamFase == .fase1 ? 0 : selectTeamFase == .start ? getRect().width : -getRect().width)

                        Group {
                            createTeamIconAndName(iconURL: uploadImageData.url)
                        }
                        .opacity(selectTeamFase == .fase2 ? 1.0 : 0.0)
                        .offset(x: selectTeamFase == .fase2 ? 0 : selectTeamFase == .start || selectTeamFase == .fase1 ? getRect().width : -getRect().width)
                    }
                    if selectTeamFase == .success {
                        Text("ようこそ、\(userVM.users[0].name)さん")
                            .tracking(5).opacity(0.6)
                            .opacity(selectTeamFase == .success ? 1.0 : 0.0)
                    }
                } // ZStack

            } // VStack
            .foregroundColor(.white)
            .offset(y: -30)
            .opacity(selectTeamFase == .start ? 0.0 : 1.0)

            Button(selectTeamFase == .fase1 ? "決定して次へ" : "これで始める") {
                withAnimation(.spring(response: 0.7)) {
                    selectTeamFase = selectTeamFase == .fase1 ? .fase2 : .success
                }
            }
            .buttonStyle(.borderedProminent)
            .offset(y: getRect().height * 0.3)
            .opacity(selectTeamFase == .start || selectTeamFase == .success ? 0.0 : 1.0)
            .opacity(selectTeamCard == .join && selectTeamFase == .fase2 ? 0.0 : 1.0)
            .disabled(selectTeamCard == .start || selectTeamFase == .success ? true : false)

            Button("<戻る") {
                withAnimation(.spring(response: 0.7)) {
                    selectTeamFase = .fase1
                }
            }
            .foregroundColor(.white.opacity(0.7))
            .offset(y: getRect().height * 0.36)
            .opacity(selectTeamFase == .fase2 ? 1.0 : 0.0)
            .disabled(selectTeamFase == .success ? true : false)

            Button {
                withAnimation(.spring(response: 1.0)) {
                    logInVM.rootNavigation = .logIn
                    teamVM.isShowCreateAndJoinTeam.toggle()
                }
            } label: {
                HStack {
                    Text("<<")
                    Image(systemName: "house.fill")
                }
            }
            .disabled(selectTeamFase == .success ? true : false)
            .foregroundColor(.white.opacity(0.5))
            .offset(x: -getRect().width / 2 + 40, y: getRect().height / 2 - 60 )
        } // ZStack

        .onChange(of: captureImage) { newImage in
            Task {
                if let path = uploadImageData.filePath {
                    await logInVM.deleteImage(path: path)
                    uploadImageData.url = nil
                    print("以前の画像削除")
                }

                await uploadImageData = logInVM.uploadImage(newImage)
                print("新規画像登録")
            }
        }

        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 1.0)) {
                    selectTeamFase = .fase1
                }
            }
        }
        .sheet(isPresented: $isShowPickerView) {
            PHPickerView(captureImage: $captureImage, isShowSheet: $isShowPickerView, isShowError: $captureError)
        }
    }

    @ViewBuilder

    func joinCard() -> some View {
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
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: getRect().width * 0.4, height: getRect().height * 0.25)
        .scaleEffect(selectTeamCard == .join ? 1.4 : selectTeamCard == .create ? 0.8 : 1.0)
        .offset(x: selectTeamCard == .join ? 30 : 0)
        .opacity(selectTeamCard == .join ? 1.0 : selectTeamCard == .start ? 0.8 : 0.2)
        .onTapGesture {
            withAnimation(.spring(response: 0.5)) {
                selectTeamCard = selectTeamCard == .start || selectTeamCard == .create ? .join : .start
            }
        }
    }

    func createCard() -> some View {
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
        .scaleEffect(selectTeamCard == .create ? 1.4 : selectTeamCard == .join ? 0.8 : 1.0)
        .offset(x: selectTeamCard == .create ? -30 : 0)
        .opacity(selectTeamCard == .create ? 1.0 : selectTeamCard == .start ? 0.8 : 0.2)
        .onTapGesture {
            withAnimation(.spring(response: 0.5)) {
                selectTeamCard = selectTeamCard == .start || selectTeamCard == .join ? .create : .start
            }
        }
    }

    func createTeamIconAndName(iconURL: URL?) -> some View {
        Group {
            VStack(spacing: 40) {
                Group {
                    if let iconURL = iconURL {
                        CircleIcon(photoURL: iconURL, size: 150)
                    } else {
                        Image(systemName: "photo.circle.fill").resizable().scaledToFit()
                            .foregroundColor(.white.opacity(0.8)).frame(width: 150)
                    }
                }
                .onTapGesture { isShowPickerView.toggle() }
                .overlay(alignment: .top) {
                    Text("チーム情報は後から変更できます。").font(.caption)
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 200)
                    .offset(y: -30)
                }

                TextField("", text: $teamName)
                    .frame(width: 230)
                    .focused($createNameFocused, equals: .check)
                    .textInputAutocapitalization(.never)
                    .multilineTextAlignment(.center)
                    .background {
                        ZStack {
                            Text(createNameFocused == nil && teamName.isEmpty ? "チーム名を入力" : "")
                                .foregroundColor(.white.opacity(0.3))
                            Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                                .offset(y: 20)
                        }
                    }
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
