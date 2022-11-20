//
//  LogInView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI
import FirebaseAuth

enum Navigation: Hashable {
    case home
}

enum FirstSelect {
    case logIn, signAp, start
}

enum SelectSignInType {
    case apple, google, mailAddress, trial, start
}

enum CreateAccount {
    case start, fase1, fase2, fase3
}

enum CreateFocused {
    case check
}

struct InputLogIn {
    var createUserNameText: String = ""
    var captureImage: UIImage = UIImage()
    var captureError: Bool = false
    var uploadImageData: (url: URL?, filePath: String?) = (url: nil, filePath: nil)
    var address: String = "kennsuke242424@gmail.com"
    var password: String = "ninnzinn2424"
    var passHidden: Bool = false
    var createAccountTitle: Bool = false
    var createAccountContents: Bool = false
    var startFetchContents: Bool = false
    var isShowProgressView: Bool = false
    var isShowPickerView: Bool = false
    var firstSelect: FirstSelect = .start
    var selectSignInType: SelectSignInType = .start
    var createAccount: CreateAccount = .start
}

// ✅ ログイン画面の親Viewです。
struct LogInView: View {

    @StateObject var teamVM: TeamViewModel = TeamViewModel()
    @StateObject var userVM: UserViewModel = UserViewModel()
    @StateObject var itemVM: ItemViewModel = ItemViewModel()
    @StateObject var tagVM: TagViewModel = TagViewModel()

    @State private var logInNavigationPath: [Navigation] = []
    @State private var inputLogIn: InputLogIn = InputLogIn()

    @FocusState private var createFocused: CreateFocused?

    // テスト用のダミーデータです。
    let testUser: User = TestUser().testUser

    var body: some View {

        NavigationStack(path: $logInNavigationPath) {

            ZStack {

                LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .onTapGesture { createFocused = nil }

                RogoMark()
                    .scaleEffect(inputLogIn.firstSelect == .signAp ? 0.4 : 1.0)
                    .offset(y: inputLogIn.firstSelect == .signAp ? -getRect().height / 2.5 : -getRect().height / 4)
                    .offset(x: inputLogIn.firstSelect == .signAp ? getRect().width / 3 : 0)
                    .opacity(inputLogIn.firstSelect == .signAp ? 0.5 : 1.0)

                if inputLogIn.createAccount == .fase2 || inputLogIn.createAccount == .fase3 {
                    Group {
                        VStack {
                            if let iconURL = inputLogIn.uploadImageData.url {
                                CircleIcon(photoURL: iconURL, size: 60)
                                    .onTapGesture { inputLogIn.isShowPickerView.toggle() }
                            } else {
                                Image(systemName: "photo.circle.fill").resizable().scaledToFit()
                                    .foregroundColor(.white.opacity(0.5)).frame(width: 60)
                                    .onTapGesture { inputLogIn.isShowPickerView.toggle() }
                            }
                            Text(inputLogIn.createUserNameText.isEmpty ? "No name" : inputLogIn.createUserNameText)
                                .tracking(3)
                                .font(.caption).foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .offset(x: -getRect().width / 3, y: -getRect().height / 2.5 + 5)
                    .transition(AnyTransition.opacity.combined(with: .offset(x: 50, y: 0)))
                }

                firstSelectButtons()
                    .offset(y: getRect().height / 8)
                    .opacity(inputLogIn.firstSelect == .start ? 1.0 : 0.0)

                if inputLogIn.firstSelect == .logIn {
                    VStack {
                        signInTitle(title: "ログイン")
                        .padding(.bottom, 40)

                        ZStack {
                            logInSelectButtons()
                                .opacity(inputLogIn.selectSignInType == .mailAddress ? 0.0 : 1.0)
                            MailAddressInfomation(inputLogIn: $inputLogIn)
                                .opacity(inputLogIn.selectSignInType == .mailAddress ? 1.0 : 0.0)
                        }
                    }
                    .offset(y: getRect().height / 10)
                    .opacity(inputLogIn.firstSelect == .logIn ? 1.0 : 0.0)
                }

                if inputLogIn.createAccount != .start {
                    createAccountViews()
                }

                if inputLogIn.isShowProgressView {
                    CustomProgressView()
                }

                // Back Button...
                if inputLogIn.firstSelect != .start {
                    Button {
                        withAnimation(.easeIn(duration: 0.3)) {

                            if inputLogIn.selectSignInType == .mailAddress {
                                inputLogIn.selectSignInType = .start
                                return
                            }

                            switch inputLogIn.firstSelect {
                            case .start: print("")
                            case .logIn: inputLogIn.firstSelect = .start
                            case .signAp: print("")
                            }

                            switch inputLogIn.createAccount {
                            case .start: print("")
                            case .fase1:
                                inputLogIn.firstSelect = .start
                                inputLogIn.createAccount = .start
                                inputLogIn.createAccountTitle = false
                                inputLogIn.createAccountContents = false
                            case .fase2:
                                inputLogIn.createAccount = .fase1
                            case .fase3:
                                inputLogIn.createAccount = .fase2
                            }

                        }
                    } label: {
                        Text("<<戻る")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .offset(y: getRect().height / 3)
                }
            } // ZStack
            .navigationDestination(for: Navigation.self) { destination in

                switch destination {
                case .home:
                    HomeTabView(teamVM: teamVM,
                                userVM: userVM,
                                itemVM: itemVM,
                                tagVM: tagVM)

                }
            } // navigationDestination
        } // NavigationStack

        .onChange(of: inputLogIn.captureImage) { newImage in
            Task {
                if let path = inputLogIn.uploadImageData.filePath {
                    await itemVM.deleteImage(path: path)
                    print("以前の画像削除")
                }

                await inputLogIn.uploadImageData = itemVM.uploadImage(newImage)
                print("新規画像登録")
            }
        }

        // LogIn Sucsess fetch Data...
        .onChange(of: inputLogIn.startFetchContents) { check in
            if check {
                Task {
                    print("fetch開始")
                    inputLogIn.isShowProgressView = true
                    await tagVM.fetchTag(teamID: teamVM.teamID)
                    await itemVM.fetchItem(teamID: teamVM.teamID)
                    print("fetch終了")
                    inputLogIn.isShowProgressView = false
                    logInNavigationPath.append(.home)
                }
            }
        }

        .sheet(isPresented: $inputLogIn.isShowPickerView) {
            PHPickerView(captureImage: $inputLogIn.captureImage, isShowSheet: $inputLogIn.isShowPickerView, isShowError: $inputLogIn.captureError)
        }
    } // body

    @ViewBuilder
    func signInTitle(title: String) -> some View {
        HStack {
            Rectangle().foregroundColor(.white.opacity(0.2)).frame(width: 60, height: 1)
            Text(title)
                .tracking(10)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal)
            Rectangle().foregroundColor(.white.opacity(0.2)).frame(width: 60, height: 1)
        }
    }
    func firstSelectButtons() -> some View {

        VStack(spacing: 20) {
            Text("アカウントをお持ちですか？")
                .tracking(10)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
                .padding(.bottom, 40)

            Button {
                withAnimation(.easeIn(duration: 0.3)) {
                    inputLogIn.firstSelect = .logIn
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.black.opacity(0.2))
                        .frame(width: 250, height: 60)
                        .shadow(radius: 10, x: 5, y: 5)
                    Text("ログイン")
                        .tracking(2)
                }
            }
            Button {
                withAnimation(.easeIn(duration: 1)) {
                    inputLogIn.firstSelect = .signAp
                }

                inputLogIn.createAccount = .fase1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.spring(response: 0.5)) {
                        inputLogIn.createAccountTitle = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.spring(response: 0.5)) {
                        inputLogIn.createAccountContents = true
                    }
                }

            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.black.opacity(0.2))
                        .frame(width: 250, height: 60)
                        .shadow(radius: 10, x: 5, y: 5)
                    Text("アカウントを作る")
                        .tracking(2)
                }
            }
        }
    }
    func logInSelectButtons() -> some View {
        VStack(spacing: 15) {

            Button {
                withAnimation(.easeIn(duration: 0.3)) {
                    inputLogIn.selectSignInType = .apple
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.black.opacity(0.8))
                        .frame(width: 250, height: 50)
                        .shadow(radius: 10, x: 5, y: 5)
                    Text("Appleアカウント")
                        .tracking(2)
                        .foregroundColor(.white)
                }
            }
            Button {
                withAnimation(.easeIn(duration: 1)) {
                    inputLogIn.selectSignInType = .google
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 250, height: 50)
                        .shadow(radius: 10, x: 5, y: 5)
                    Text("Googleアカウント")
                        .tracking(2)
                        .foregroundColor(.black)
                }
            }
            Button {
                withAnimation(.easeIn(duration: 0.3)) {
                    inputLogIn.selectSignInType = .mailAddress
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.blue.opacity(0.8))
                        .frame(width: 250, height: 50)
                        .shadow(radius: 10, x: 5, y: 5)
                    Text("メールアドレス")
                        .tracking(2)
                        .foregroundColor(.white)
                }
            }
        }
    }
    func createAccountViews() -> some View {

        VStack(spacing: 50) {

            Group {
                switch inputLogIn.createAccount {
                case .start: Text("")
                case .fase1: Text("あなたのことを教えてください")
                case .fase2: Text("どちらから登録しますか？")
                case .fase3: Text("チームを選んでください")
                }
            }
            .tracking(5)
            .font(.title3).foregroundColor(.white.opacity(0.6))
            .opacity(inputLogIn.createAccountTitle ? 1.0 : 0.0)

            Group {
                switch inputLogIn.createAccount {

                case .start: Text("")

                case .fase1:
                    if let iconURL = inputLogIn.uploadImageData.url {
                        CircleIcon(photoURL: iconURL, size: 150)
                            .onTapGesture { inputLogIn.isShowPickerView.toggle() }
                    } else {
                        Image(systemName: "photo.circle.fill").resizable().scaledToFit()
                            .foregroundColor(.white.opacity(0.5)).frame(width: 150)
                            .onTapGesture { inputLogIn.isShowPickerView.toggle() }
                    }
                    TextField("", text: $inputLogIn.createUserNameText)
                        .frame(width: 230)
                        .focused($createFocused, equals: .check)
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.center)
                        .background {
                            ZStack {
                                Text(createFocused == nil && inputLogIn.createUserNameText.isEmpty ? "ユーザネーム" : "")
                                    .foregroundColor(.white.opacity(0.2))
                                Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                                    .offset(y: 20)
                            }
                        }

                    Button {
                        withAnimation(.spring(response: 0.7)) {
                            inputLogIn.createAccount = .fase2
                        }
                    } label: {
                        Text("次へ")
                    }
                    .buttonStyle(.borderedProminent)

                    Text("ユーザ情報は後から変更できます。").font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))

                case .fase2:
                    signInTitle(title: "新規登録")
                        .padding(.top, 40)

                    ZStack {
                        logInSelectButtons()
                            .opacity(inputLogIn.selectSignInType == .mailAddress ? 0.0 : 1.0)
                        MailAddressInfomation(inputLogIn: $inputLogIn)
                            .opacity(inputLogIn.selectSignInType == .mailAddress ? 1.0 : 0.0)
                    }

                case .fase3:
                    Text("")
                }
            }
            .opacity(inputLogIn.createAccountContents ? 1.0 : 0.0)

        } // VStack
    }

} // View

struct RogoMark: View {
    var body: some View {

        VStack {

            Image(systemName: "cube.transparent")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 150, height: 150)
                .padding()

            Text("unico")
                .tracking(25)
                .font(.title3)
                .foregroundColor(.white.opacity(0.6))
                .fontWeight(.heavy)
                .offset(x: 10)
        } // VStack
    } // body
} // View

struct MailAddressInfomation: View {

    @Binding var inputLogIn: InputLogIn

    var body: some View {

        VStack(spacing: 25) {

            // 入力欄全体
            Group {

                // Mail address...
                VStack {

                    Text("メールアドレス")
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: getRect().width * 0.7, alignment: .leading)

                    RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.2))
                        .frame(width: getRect().width * 0.7, height: 30)
                        .overlay {
                            TextField("artwork/@gmail.com", text: $inputLogIn.address)
                                .foregroundColor(.white)
                                .padding()
                        }
                }

                // Password...
                VStack {
                    Text("パスワード")
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: getRect().width * 0.7, alignment: .leading)

                    RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.2))
                        .frame(width: getRect().width * 0.7, height: 30)
                        .overlay {
                            ZStack(alignment: .leading) {
                                if inputLogIn.passHidden {
                                    SecureField("●●●●", text: $inputLogIn.password)
                                        .foregroundColor(.white)
                                        .padding()
                                } else {
                                    TextField("●●●●", text: $inputLogIn.password)
                                        .foregroundColor(.white)
                                        .padding()
                                } // if passHidden

                                HStack {
                                    Spacer()

                                    Button {
                                        inputLogIn.passHidden.toggle()
                                    } label: {
                                        Image(systemName: inputLogIn.passHidden ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.gray)
                                    } // Button
                                } // HStack
                            } // ZStack
                        }
                }
            } // Group(入力欄全体)
            .font(.subheadline)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            .padding(.horizontal, 25)

            Button(inputLogIn.firstSelect == .logIn ? "ログイン" : "サインアップ") {

                switch inputLogIn.firstSelect {
                case .start: print("処理なし")
                case .signAp:
                    print("サインアップ処理")
                case .logIn:
                    inputLogIn.startFetchContents.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)

        } // VStack

    } // body
} // View

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
