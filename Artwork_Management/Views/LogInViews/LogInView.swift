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
    var addressCheck: AddressCheck = .stop
}

// ✅ ログイン画面の親Viewです。
struct LogInView: View {

    @Binding var rootNavigation: RootNavigation
    @StateObject var logInVM: LogInViewModel = LogInViewModel()

    @State private var logInNavigationPath: [Navigation] = []
    @State private var inputLogIn: InputLogIn = InputLogIn()
    @State private var selectMemberColor: MemberColor = .gray
    @State private var createFaseLineImprove: CGFloat = 0.0

    @FocusState private var createNameFocused: CreateFocused?

    var body: some View {

        ZStack {

            GradientBackbround(color1: selectMemberColor.color1,
                               color2: selectMemberColor.colorAccent)
            .onTapGesture { createNameFocused = nil }

            Group {
                if let iconURL = inputLogIn.uploadImageData.url {
                    CircleIcon(photoURL: iconURL, size: 60)
                } else {
                    Image(systemName: "person.circle.fill").resizable().scaledToFit()
                        .foregroundColor(.white.opacity(0.5)).frame(width: 60)
                }
            }
            .offset(x: -getRect().width / 3, y: -getRect().height / 2.5)
            .offset(x: inputLogIn.createAccount == .fase3 || inputLogIn.createAccount == .fase3 ? 0 : 30)
            .opacity(inputLogIn.createAccount == .fase3 || inputLogIn.createAccount == .fase3 ? 1.0 : 0.0)
            .onTapGesture { inputLogIn.isShowPickerView.toggle() }

            RogoMark()
                .scaleEffect(inputLogIn.firstSelect == .signAp ? 0.4 : 1.0)
                .offset(y: inputLogIn.firstSelect == .signAp ? -getRect().height / 2.5 : -getRect().height / 4)
                .offset(x: inputLogIn.firstSelect == .signAp ? getRect().width / 3 : 0)
                .opacity(inputLogIn.firstSelect == .signAp ? 0.4 : 1.0)

            firstSelectButtons()
                .offset(y: getRect().height / 8)
                .opacity(inputLogIn.firstSelect == .start ? 1.0 : 0.0)

            if inputLogIn.firstSelect == .logIn {
                VStack {
                    signInTitle(title: "ログイン")
                        .padding(.bottom)

                    ZStack {
                        logInSelectButtons()
                            .opacity(inputLogIn.selectSignInType == .mailAddress ? 0.0 : 1.0)
                        if inputLogIn.selectSignInType == .mailAddress {
                            MailAddressInfomation(logInVM: logInVM, inputLogIn: $inputLogIn)
                                .opacity(inputLogIn.selectSignInType == .mailAddress ? 1.0 : 0.0)
                        }
                    }
                }
                .offset(y: getRect().height / 10)
                .opacity(inputLogIn.firstSelect == .logIn ? 1.0 : 0.0)
            }

            if inputLogIn.createAccount != .start {
                createAccountViews()
                    .offset(y: inputLogIn.createAccount == .fase3 && inputLogIn.selectSignInType != .mailAddress ? -20 : 0)
            }

            // Back Button...
            if inputLogIn.firstSelect != .start {
                Button {
                    withAnimation(.spring(response: 0.5)) {

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
                            if inputLogIn.createUserNameText == "名無し" { inputLogIn.createUserNameText = ""
                            }
                        }

                    }
                } label: {
                    Text("< 戻る")
                        .foregroundColor(.white.opacity(0.7))
                }
                .disabled(inputLogIn.addressCheck == .start || inputLogIn.addressCheck == .succsess ? true : false)
                .opacity(inputLogIn.addressCheck == .start || inputLogIn.addressCheck == .succsess ? 0.2 : 1.0)
                .offset(y: getRect().height / 3)
            }

            if inputLogIn.firstSelect == .signAp {
                createAccountIndicator()
                    .offset(y: -getRect().height / 3 + 30)
                    .padding(.bottom)
            }

            // Home Back...
            if inputLogIn.firstSelect != .start {
                Button {
                    withAnimation(.spring(response: 1.0)) {
                        inputLogIn.selectSignInType = .start
                        inputLogIn.firstSelect = .start
                        inputLogIn.createAccount = .start
                        inputLogIn.createAccountTitle = false
                        inputLogIn.createAccountContents = false
                        if inputLogIn.createUserNameText == "名無し" { inputLogIn.createUserNameText = "" }
                    }
                } label: {
                    HStack {
                        Text("<<")
                        Image(systemName: "house.fill")
                    }
                }
                .disabled(inputLogIn.addressCheck == .start || inputLogIn.addressCheck == .succsess ? true : false)
                .opacity(inputLogIn.addressCheck == .start || inputLogIn.addressCheck == .succsess ? 0.2 : 1.0)
                .foregroundColor(.white.opacity(0.5))
                .offset(x: -getRect().width / 2 + 40, y: getRect().height / 2 - 60 )
            }

            // ProgressView...
            if inputLogIn.isShowProgressView {
                CustomProgressView()
            }

        } // ZStack

        .onChange(of: inputLogIn.captureImage) { newImage in
            Task {
                if let path = inputLogIn.uploadImageData.filePath {
                    await logInVM.deleteImage(path: path)
                    inputLogIn.uploadImageData.url = nil
                    print("以前の画像削除")
                }

                await inputLogIn.uploadImageData = logInVM.uploadImage(newImage)
                print("新規画像登録")
            }
        }

        .onChange(of: inputLogIn.createAccount) { newFase in
            withAnimation(.spring(response: 1.0)) {
                switch newFase {
                case .start:
                    createFaseLineImprove = 0
                case .fase1:
                    createFaseLineImprove = 0
                case .fase2:
                    createFaseLineImprove = 100
                case .fase3:
                    createFaseLineImprove = 200
                }
            }
        }

        // LogIn Sucsess fetch Data...
        .onChange(of: inputLogIn.addressCheck) { check in
            if check == .succsess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // RootViewへ移動
                    withAnimation(.spring(response: 0.5)) {
                        rootNavigation = .fetch
                    }
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
                        .background(BlurView(style: .systemMaterialDark))
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
                    withAnimation(.spring(response: 1.0)) {
                        inputLogIn.createAccountTitle = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                    withAnimation(.spring(response: 1.0)) {
                        inputLogIn.createAccountContents = true
                    }
                }

            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.black.opacity(0.1))
                        .frame(width: 250, height: 60)
                        .background(BlurView(style: .systemMaterialDark))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 10, x: 5, y: 5)
                    Text("いいえ、初めてです")
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
                        Text("あなたの色は？").tracking(10)
                    }

                case .fase2:

                        VStack(spacing: 10) {
                            Text("unicoへようこそ").tracking(10)
                            Text("あなたのことを教えてください")
                        }

                case .fase3:

                    if inputLogIn.selectSignInType != .mailAddress {
                        VStack(spacing: 10) {
                            Text("初めまして、\(inputLogIn.createUserNameText)さん")
                            Text("どちらから登録しますか？")
                        }
                        .frame(width: 250)
                    }
                }
            } // Group
            .tracking(5)
            .font(.subheadline).foregroundColor(.white.opacity(0.6))
            .opacity(inputLogIn.createAccountTitle ? 1.0 : 0.0)

            Group {
                switch inputLogIn.createAccount {

                case .start: Text("")

                case .fase1:

                    ColorCubeView(colorSet: $selectMemberColor)
                        .padding()

                    Button {
                        withAnimation(.spring(response: 1.0)) {
                            inputLogIn.createAccountTitle = false
                            inputLogIn.createAccountContents = false
                            inputLogIn.createAccount = .fase2
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.spring(response: 0.8)) {
                                inputLogIn.createAccountTitle = true
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.spring(response: 0.8)) {
                                inputLogIn.createAccountContents = true
                            }
                        }

                    } label: {
                        Text("次へ")
                    }
                    .buttonStyle(.borderedProminent)

                case .fase2:

                    Group {
                        if let iconURL = inputLogIn.uploadImageData.url {
                            CircleIcon(photoURL: iconURL, size: 150)
                        } else {
                            Image(systemName: "photo.circle.fill").resizable().scaledToFit()
                                .foregroundColor(.white.opacity(0.5)).frame(width: 150)
                        }
                    }
                    .onTapGesture { inputLogIn.isShowPickerView.toggle() }
                    .overlay(alignment: .top) {
                        Text("ユーザ情報は後から変更できます。").font(.caption)
                        .foregroundColor(.white.opacity(0.3))
                        .frame(width: 200)
                        .offset(y: -30)
                    }
                    .offset(y: 20)

                    TextField("", text: $inputLogIn.createUserNameText)
                        .frame(width: 230)
                        .focused($createNameFocused, equals: .check)
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.center)
                        .background {
                            ZStack {
                                Text(createNameFocused == nil && inputLogIn.createUserNameText.isEmpty ? "名前を入力" : "")
                                    .foregroundColor(.white.opacity(0.3))
                                Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                                    .offset(y: 20)
                            }
                        }

                    Button {
                        withAnimation(.spring(response: 0.7)) {
                            inputLogIn.createAccountTitle = false
                            inputLogIn.createAccountContents = false
                            inputLogIn.createAccount = .fase3
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            if inputLogIn.createUserNameText.isEmpty { inputLogIn.createUserNameText = "名無し"
                            }
                            withAnimation(.spring(response: 0.7)) {
                                inputLogIn.createAccountTitle = true
                                inputLogIn.createAccountContents = true
                            }
                        }

                    } label: {
                        Text("次へ")
                    }
                    .buttonStyle(.borderedProminent)

                case .fase3:

                    VStack {
                        signInTitle(title: inputLogIn.selectSignInType != .mailAddress ? "新規登録" : "メールアドレス登録")

                        ZStack {
                            logInSelectButtons()
                                .opacity(inputLogIn.selectSignInType == .mailAddress ? 0.0 : 1.0)
                            if inputLogIn.selectSignInType == .mailAddress {
                                MailAddressInfomation(logInVM: logInVM, inputLogIn: $inputLogIn)
                                    .opacity(inputLogIn.selectSignInType == .mailAddress ? 1.0 : 0.0)
                            }
                        }
                        .offset(y: 50)
                    }
                }
            }
            .opacity(inputLogIn.createAccountContents ? 1.0 : 0.0)

        } // VStack
    }
    // create fase line...
    func createAccountIndicator() -> some View {
        Rectangle()
            .frame(width: 200, height: 2, alignment: .leading)
            .foregroundColor(.white)
            .overlay(alignment: .leading) {
                Rectangle()
                    .frame(width: createFaseLineImprove, height: 2)
                    .foregroundColor(.green)
            }

            .overlay(alignment: .leading) {
                Circle().frame(width: 12, height: 12)
                    .foregroundColor(inputLogIn.createAccount != .fase1 ? .green : .white)
                    .scaleEffect(inputLogIn.createAccount == .fase1 && inputLogIn.createAccountContents ? 1.5 : 1.0)
                    .overlay(alignment: .top) {
                        Text("Check!")
                            .font(.caption2).foregroundColor(.white.opacity(0.5))
                            .frame(width: 50)
                            .opacity(inputLogIn.createAccount == .fase1 && inputLogIn.createAccountContents ? 1.0 : 0.0)
                            .offset(y: -20)
                    }
            }

            .overlay {
                Circle().frame(width: 12, height: 12)
                    .foregroundColor(inputLogIn.createAccount != .fase1 &&
                                     inputLogIn.createAccount != .fase2 ? .green : .white)
                    .scaleEffect(inputLogIn.createAccount == .fase2 && inputLogIn.createAccountContents ? 1.5 : 1.0)
                    .overlay(alignment: .top) {
                        Text("Check!")
                            .font(.caption2).foregroundColor(.white.opacity(0.5))
                            .frame(width: 50)
                            .opacity(inputLogIn.createAccount == .fase2 && inputLogIn.createAccountContents ? 1.0 : 0.0)
                            .offset(y: -20)
                    }

            }

            .overlay(alignment: .trailing) {
                Circle().frame(width: 12, height: 12)
                    .foregroundColor(inputLogIn.createAccount != .fase1 &&
                                     inputLogIn.createAccount != .fase2 &&
                                     inputLogIn.createAccount != .fase3 ? .green : .white)
                    .scaleEffect(inputLogIn.createAccount == .fase3 && inputLogIn.createAccountContents ? 1.5 : 1.0)
                    .overlay(alignment: .top) {
                        Text("Check!")
                            .font(.caption2).foregroundColor(.white.opacity(0.5))
                            .frame(width: 50)
                            .opacity(inputLogIn.createAccount == .fase3 && inputLogIn.createAccountContents ? 1.0 : 0.0)
                            .offset(y: -20)
                    }
            }
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

    @StateObject var logInVM: LogInViewModel
    @Binding var inputLogIn: InputLogIn

    @State private var addressHidden: Bool = false
    @State private var passwordHidden: Bool = false
    @State private var passwordCount6Lower: Bool = false
    @State private var passwordConfirmIsEmpty: Bool = false
    @State private var passwordConfirmDifference: Bool = false
    @State private var disabledButton: Bool = false
    @State private var signUpErrorMessage: String = ""

    @FocusState private var createAccountFocused: CreateFocused?

    var body: some View {

        ZStack {

            Color.white.opacity(0.001).frame(width: getRect().width, height: getRect().height / 3)
                .onTapGesture { createAccountFocused = nil }

            VStack(spacing: 25) {

                // 入力欄全体
                Group {

                    // Mail address...
                    VStack {
                        HStack {
                            Text("メールアドレス")
                                .foregroundColor(.white.opacity(0.7))
                            if addressHidden && inputLogIn.addressCheck == .failure {
                                Text("※アドレスが未入力です").font(.caption).foregroundColor(.red.opacity(0.7))
                            }
                        }
                        .frame(width: getRect().width * 0.7, alignment: .leading)

                        TextField("unico@gmail.com", text: $inputLogIn.address)
                            .foregroundColor(.white)
                            .focused($createAccountFocused, equals: .check)
                            .padding()
                            .frame(width: getRect().width * 0.7, height: 30)
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.2)).frame(height: 30))
                    }

                    // Password...
                    VStack {
                        HStack {
                            Text("パスワード")
                                .foregroundColor(.white.opacity(0.7))
                            if passwordHidden && inputLogIn.addressCheck == .failure {
                                Text("※パスワードが未入力です").font(.caption).foregroundColor(.red.opacity(0.7))
                            } else if passwordCount6Lower && inputLogIn.addressCheck == .failure {
                                Text("※パスワードは6文字以上必要です").font(.caption).foregroundColor(.red.opacity(0.7))
                            } else {
                                Text("(※6文字以上)").font(.caption).foregroundColor(.white.opacity(0.4))
                            }
                            Button {
                                logInVM.passwordUpdate(email: inputLogIn.address)
                            } label: {
                                Text("パスワードを忘れた").font(.caption)
                            }
                        }
                        .frame(width: getRect().width * 0.7, alignment: .leading)

                        Group {
                            if inputLogIn.passHidden {
                                SecureField("●●●●●●●●", text: $inputLogIn.password)
                            } else {
                                TextField("●●●●●●●●", text: $inputLogIn.password)
                            }
                        }
                        .foregroundColor(.white)
                        .focused($createAccountFocused, equals: .check)
                        .padding()
                        .frame(width: getRect().width * 0.7, height: 30)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.2)).frame(height: 30))
                        .overlay(alignment: .trailing) {
                            Button {
                                inputLogIn.passHidden.toggle()
                            } label: {
                                Image(systemName: inputLogIn.passHidden ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            } // Button
                        }
                    }
                    // Password確認...
                    if inputLogIn.firstSelect == .signAp {
                        VStack {
                            HStack {
                                Text("パスワード確認")
                                    .foregroundColor(.white.opacity(0.7))
                                if passwordConfirmDifference && inputLogIn.addressCheck == .failure {
                                    Text("※パスワードが一致しません").font(.caption).foregroundColor(.red.opacity(0.7))
                                }
                            }
                            .frame(width: getRect().width * 0.7, alignment: .leading)

                            Group {
                                if inputLogIn.passHidden {
                                    SecureField("●●●●●●●●", text: $inputLogIn.passwordConfirm)
                                } else {
                                    TextField("●●●●●●●●", text: $inputLogIn.passwordConfirm)
                                }
                            }
                            .foregroundColor(.white)
                            .focused($createAccountFocused, equals: .check)
                            .padding()
                            .frame(width: getRect().width * 0.7, height: 30)
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.2)).frame(height: 30))
                            .overlay(alignment: .trailing) {
                                Button {
                                    inputLogIn.passHidden.toggle()
                                } label: {
                                    Image(systemName: inputLogIn.passHidden ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                } // Button
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
                    passwordCount6Lower = false
                    passwordConfirmIsEmpty = false
                    passwordConfirmDifference = false
                    logInVM.logInErrorMessage = ""

                    inputLogIn.addressCheck = .start

                    if inputLogIn.address.isEmpty { addressHidden.toggle() }
                    if inputLogIn.password.isEmpty { passwordHidden.toggle() }
                    if inputLogIn.firstSelect == .signAp && inputLogIn.passwordConfirm.isEmpty { passwordConfirmIsEmpty.toggle() }
                    if inputLogIn.firstSelect == .signAp && inputLogIn.password != inputLogIn.passwordConfirm { passwordConfirmDifference.toggle() }

                    if addressHidden || passwordHidden || passwordCount6Lower || passwordConfirmIsEmpty || passwordConfirmDifference {
                        print("ユーザ登録記入欄に不備あり")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 0.5)) { inputLogIn.addressCheck = .failure }
                        }
                        return

                    } else {

                        switch inputLogIn.firstSelect {
                        case .start: return

                        case .signAp:
                            Task {
                                let checkSignUp = await logInVM.signUp(email: inputLogIn.address,
                                                                       password: inputLogIn.password)

                                if !checkSignUp { inputLogIn.addressCheck = .failure; return }

                                let uid = Auth.auth().currentUser!.uid

                                    let newUserData = User(id: uid,
                                                        name: inputLogIn.createUserNameText,
                                                        address: inputLogIn.address,
                                                        password: inputLogIn.password,
                                                        iconURL: inputLogIn.uploadImageData.url,
                                                        iconPath: inputLogIn.uploadImageData.filePath,
                                                        joins: [])

                                    let checkAddUser = await logInVM.addUser(userData: newUserData)


                                if checkSignUp, checkAddUser {
                                    // サインアップ成功
                                    withAnimation(.spring(response: 0.5)) { inputLogIn.addressCheck = .succsess }
                                } else {
                                    // サインアップ失敗
                                    withAnimation(.spring(response: 0.5)) { inputLogIn.addressCheck = .failure }
                                }
                            }

                        case .logIn:
                            Task {
                                let checkSignIn = await logInVM.signIn(email: inputLogIn.address,
                                                                       password: inputLogIn.password)
                                if checkSignIn {
                                    // ログイン成功
                                    withAnimation(.spring(response: 0.5)) { inputLogIn.addressCheck = .succsess }
                                } else {
                                    // ログイン失敗
                                    withAnimation(.spring(response: 0.5)) { inputLogIn.addressCheck = .failure }
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputLogIn.addressCheck == .start || inputLogIn.addressCheck == .succsess ? true : false)
                .overlay(alignment: .top) {
                    HStack {
                        if inputLogIn.addressCheck == .start {
                            ProgressView().frame(width: 10, height: 10)
                        } else {
                            inputLogIn.addressCheck.icon.foregroundColor(inputLogIn.addressCheck == .failure ? .red : .green)
                        }
                        Text(inputLogIn.addressCheck.text).foregroundColor(.white.opacity(0.5))
                    }
                    .font(.caption)
                    .offset(y: -30)
                }
                .overlay(alignment: .bottomTrailing) {
                    Button("やり直す") {
                        addressHidden = false
                        passwordHidden = false
                        passwordCount6Lower = false
                        passwordConfirmIsEmpty = false
                        passwordConfirmDifference = false
                        logInVM.logInErrorMessage = ""

                        inputLogIn.addressCheck = .stop
                    }
                    .overlay(alignment: .bottom) {(Rectangle().frame(height: 1)) }
                    .font(.caption)
                    .foregroundColor(.white)
                    .offset(x: 100)
                    .opacity(inputLogIn.addressCheck == .failure ? 1.0 : 0.0)
                }
                .padding(.top, 20)

                Text(inputLogIn.addressCheck == .failure ? logInVM.logInErrorMessage :
                        inputLogIn.addressCheck == .succsess ? inputLogIn.firstSelect == .logIn ?
                     "ログインに成功しました！"  : "ユーザ登録が完了しました！" : "")
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(inputLogIn.addressCheck == .failure ? .red : .white).opacity(0.8)
                    .opacity(inputLogIn.addressCheck == .failure || inputLogIn.addressCheck == .succsess ? 1.0 : 0.0)
                    .frame(height: 20)

            } // VStack

            .onDisappear {
                addressHidden = false
                passwordHidden = false
                passwordCount6Lower = false
                passwordConfirmIsEmpty = false
                passwordConfirmDifference = false
                logInVM.logInErrorMessage = ""
                inputLogIn.addressCheck = .stop
            }
        }
    } // body
} // View

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView(rootNavigation: .constant(.logIn))
    }
}
