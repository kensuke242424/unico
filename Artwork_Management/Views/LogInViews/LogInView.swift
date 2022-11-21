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
    var passwordConfirm: String = "ninnzinn2424"
    var passHidden: Bool = true
    var passHiddenConfirm: Bool = true
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

                Group {
                    if let iconURL = inputLogIn.uploadImageData.url {
                        CircleIcon(photoURL: iconURL, size: 60)
                    } else {
                        Image(systemName: "photo.circle.fill").resizable().scaledToFit()
                            .foregroundColor(.white.opacity(0.5)).frame(width: 60)
                    }
                }
                .offset(x: -getRect().width / 3, y: -getRect().height / 2.5)
                .offset(x: inputLogIn.createAccount == .fase2 || inputLogIn.createAccount == .fase3 ? 0 : 30)
                .opacity(inputLogIn.createAccount == .fase2 || inputLogIn.createAccount == .fase3 ? 1.0 : 0.0)
                .onTapGesture { inputLogIn.isShowPickerView.toggle() }

                firstSelectButtons()
                    .offset(y: getRect().height / 8)
                    .opacity(inputLogIn.firstSelect == .start ? 1.0 : 0.0)

                if inputLogIn.firstSelect == .logIn {
                    VStack {
                        signInTitle(title: "ログイン")

                        ZStack {
                            logInSelectButtons()
                                .opacity(inputLogIn.selectSignInType == .mailAddress ? 0.0 : 1.0)
                            MailAddressInfomation(teamVM: teamVM, userVM: userVM, inputLogIn: $inputLogIn)
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
                                if inputLogIn.createUserNameText == "名無し" { inputLogIn.createUserNameText = "" }
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
                        .foregroundColor(.black.opacity(0.1))
                        .frame(width: 250, height: 60)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 10, x: 5, y: 5)
                    Text("ログイン")
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.8))
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
                        .foregroundColor(.black.opacity(0.1))
                        .frame(width: 250, height: 60)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 10, x: 5, y: 5)
                    Text("いえ、初めてです")
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.8))
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
                case .fase1:
                    VStack(spacing: 10) {
                        Text("unicoへようこそ").tracking(10)
                        Text("あなたのことを教えてください")
                    }

                case .fase2:
                    if inputLogIn.selectSignInType != .mailAddress {
                        VStack(spacing: 10) {
                            Text("初めまして、\(inputLogIn.createUserNameText)さん")
                            Text("どちらから登録しますか？")
                        }
                        .frame(width: 250)
                    }

                case .fase3:
                    Text("ユーザ登録に成功しました！")
                    Text("最後にチームを選んでください")
                }
            }
            .tracking(5)
            .font(.subheadline).foregroundColor(.white.opacity(0.6))
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
                            inputLogIn.createAccountTitle = false
                            inputLogIn.createAccountContents = false
                            inputLogIn.createAccount = .fase2
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            if inputLogIn.createUserNameText.isEmpty { inputLogIn.createUserNameText = "名無し" }
                            withAnimation(.spring(response: 0.7)) {
                                inputLogIn.createAccountTitle = true
                                inputLogIn.createAccountContents = true
                            }
                        }

                    } label: {
                        Text("次へ進む")
                    }
                    .buttonStyle(.borderedProminent)

                    Text("ユーザ情報はいつでも変更できます。").font(.caption)
                        .foregroundColor(.white.opacity(0.6))

                case .fase2:
                    signInTitle(title: inputLogIn.selectSignInType != .mailAddress ? "新規登録" : "メールアドレス登録")

                    ZStack {
                        logInSelectButtons()
                            .opacity(inputLogIn.selectSignInType == .mailAddress ? 0.0 : 1.0)
                        if inputLogIn.selectSignInType == .mailAddress {
                            MailAddressInfomation(teamVM: teamVM, userVM: userVM, inputLogIn: $inputLogIn)
                                .opacity(inputLogIn.selectSignInType == .mailAddress ? 1.0 : 0.0)
                        }
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

    enum AddressCheck {
        case stop, start, failure, succsess

        var icon: Image {
            switch self {
            case .stop: return Image(systemName: "")
            case .start: return Image(systemName: "")
            case .failure: return Image(systemName: "multiply.circle.fill")
            case .succsess: return Image(systemName: "checkmark.seal.fill")
            }
        }

        var text: String {
            switch self {
            case .stop: return ""
            case .start: return "check..."
            case .failure: return "failure!!"
            case .succsess: return "succsess!!"
            }
        }
    }

    @StateObject var teamVM: TeamViewModel
    @StateObject var userVM: UserViewModel
    @Binding var inputLogIn: InputLogIn

    @State private var addressHidden: Bool = false
    @State private var passwordHidden: Bool = false
    @State private var passwordCountError: Bool = false
    @State private var passwordConfirmHidden: Bool = false
    @State private var passwordConfirmError: Bool = false
    @State private var disabledButton: Bool = false
    @State private var addressCheck: AddressCheck = .stop
    @State private var signUperrorMessage: String = ""

    var body: some View {

        VStack(spacing: 25) {

            // 入力欄全体
            Group {

                // Mail address...
                VStack {
                    HStack {
                        Text("メールアドレス")
                            .foregroundColor(.white.opacity(0.7))

                        if addressHidden {
                            Text("※アドレスが未入力です").font(.caption).foregroundColor(.red.opacity(0.7))
                        }
                    }
                    .frame(width: getRect().width * 0.7, alignment: .leading)

                    RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.2))
                        .frame(width: getRect().width * 0.7, height: 30)
                        .overlay {
                            TextField("unico@gmail.com", text: $inputLogIn.address)
                                .foregroundColor(.white)
                                .padding()
                        }
                }

                // Password...
                VStack {
                    HStack {
                        Text("パスワード")
                            .foregroundColor(.white.opacity(0.7))
                        if passwordHidden {
                            Text("※パスワードが未入力です").font(.caption).foregroundColor(.red.opacity(0.7))
                        } else if passwordCountError {
                            Text("※パスワードは6文字以上必要です").font(.caption).foregroundColor(.red.opacity(0.7))
                        } else {
                            Text("(※8文字以上)").font(.caption).foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .frame(width: getRect().width * 0.7, alignment: .leading)

                    RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.2))
                        .frame(width: getRect().width * 0.7, height: 30)
                        .overlay {
                            ZStack(alignment: .leading) {
                                if inputLogIn.passHidden {
                                    SecureField("●●●●●●●●", text: $inputLogIn.password)
                                        .foregroundColor(.white)
                                        .padding()
                                } else {
                                    TextField("●●●●●●●●", text: $inputLogIn.password)
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
                // Password確認...
                if inputLogIn.firstSelect == .signAp {
                    VStack {
                        HStack {
                            Text("パスワード確認")
                                .foregroundColor(.white.opacity(0.7))
                            if passwordConfirmError {
                                Text("※パスワードが一致しません").font(.caption).foregroundColor(.red.opacity(0.7))
                            }
                        }
                        .frame(width: getRect().width * 0.7, alignment: .leading)

                        RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.2))
                            .frame(width: getRect().width * 0.7, height: 30)
                            .overlay {
                                ZStack(alignment: .leading) {
                                    if inputLogIn.passHidden {
                                        SecureField("●●●●●●●●", text: $inputLogIn.passwordConfirm)
                                            .foregroundColor(.white)
                                            .padding()
                                    } else {
                                        TextField("●●●●●●●●", text: $inputLogIn.passwordConfirm)
                                            .foregroundColor(.white)
                                            .padding()
                                    }

                                    HStack {
                                        Spacer()

                                        Button {
                                            inputLogIn.passHiddenConfirm.toggle()
                                        } label: {
                                            Image(systemName: inputLogIn.passHiddenConfirm ? "eye.slash.fill" : "eye.fill")
                                                .foregroundColor(.gray)
                                        } // Button
                                    } // HStack
                                } // ZStack
                            }
                    }
                }
            } // Group(入力欄全体)
            .font(.subheadline)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            .padding(.horizontal, 25)

            Button(inputLogIn.firstSelect == .logIn ? "ログイン" : "ユーザ登録") {

                addressHidden = false
                passwordHidden = false
                passwordCountError = false
                passwordConfirmHidden = false
                passwordConfirmError = false
                signUperrorMessage = ""

                addressCheck = .start

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if inputLogIn.address.isEmpty { addressHidden.toggle() }
                    if inputLogIn.password.isEmpty { passwordHidden.toggle() }
                    if inputLogIn.password.count < 6 { passwordCountError.toggle() }
                    if inputLogIn.passwordConfirm.isEmpty { passwordConfirmHidden.toggle() }
                    if inputLogIn.password != inputLogIn.passwordConfirm { passwordConfirmError.toggle() }

                    if addressHidden || passwordHidden || passwordCountError || passwordConfirmHidden || passwordConfirmError {
                        print("ユーザ登録記入欄に不備あり")
                        addressCheck = .failure
                        return
                    } else {
                        switch inputLogIn.firstSelect {
                        case .start: return
                        case .signAp:
                            Task {
                                let uid: String? = await userVM.signUpAndGetUid(email: inputLogIn.address, password: inputLogIn.password)

                                if let uid = uid {
                                    let userData = User(id: uid,
                                                        name: inputLogIn.createUserNameText,
                                                        address: inputLogIn.address,
                                                        password: inputLogIn.password,
                                                        iconURL: inputLogIn.uploadImageData.url,
                                                        iconPath: inputLogIn.uploadImageData.filePath,
                                                        joins: [])
                                    userVM.addUser(userData: userData)
                                    withAnimation(.spring(response: 0.5)) {
                                        addressCheck = .succsess
                                    }
                                } else {
                                    print("uidがnilです")
                                    withAnimation(.spring(response: 0.5)) {
                                        addressCheck = .failure
                                    }
                                }
                            }

                        case .logIn:
                            inputLogIn.startFetchContents.toggle()
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(addressCheck == .start ? true : false)
            .overlay(alignment: .top) {
                HStack {
                    if addressCheck == .start {
                        ProgressView().frame(width: 10, height: 10)
                    } else {
                        addressCheck.icon.foregroundColor(addressCheck == .failure ? .red : .green)
                    }
                    Text(addressCheck.text).foregroundColor(.white.opacity(0.5))
                }
                .font(.caption)
                .offset(y: -30)
            }
            .padding(.top, 20)

            Text(signUperrorMessage).font(.subheadline).foregroundColor(.red.opacity(0.8))

        }.padding() // VStack

    } // body

} // View

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
