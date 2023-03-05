//
//  LogInView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

enum Navigation: Hashable {
    case home
}

enum FirstSelect {
    case logIn, signAp, start
}

enum SelectSignInType {
    case apple, google, mailAddress, trial, start
}

enum CreateAccountFase {
    case start, fase1, fase2, fase3, success
}

enum ShowKyboard {
    case check
}

enum InputAddressFocused {
    case check
}

enum AddressCheck {
    case start, check, failure, success
    
    var checkIcon: Image {
        switch self {
        case .start: return Image(systemName: "")
        case .check: return Image(systemName: "")
        case .failure: return Image(systemName: "multiply.circle.fill")
        case .success: return Image(systemName: "checkmark.seal.fill")
        }
    }
    
    var humanIconBadge: Image {
        switch self {
        case .start: return Image(systemName: "")
        case .check: return Image(systemName: "")
        case .failure: return Image(systemName: "xmark.circle.fill")
        case .success: return Image(systemName: "checkmark.circle.fill")
        }
    }
    
    var checkText: String {
        switch self {
        case .start: return ""
        case .check: return "check..."
        case .failure: return "failure!!"
        case .success: return "succsess!!"
        }
    }
    
    var messageText: (text1: String, text2: String) {
        switch self {
        case .start: return ("メールアドレスを入力してください。",
                             "入力したアドレスに、本人確認メールを送ります。")
        case .check: return ("メールアドレスをチェックしています...", "")
        case .failure: return ("メールの送信ができませんでした。", "アドレスを確認して、再度試してみてください。")
        case .success: return ("入力アドレスに認証メールを送信しました！", "届いたメールからサインインしてください。")
        }
    }
}

struct InputLogIn {
    var createUserNameText: String = ""
    var captureImage: UIImage? = nil
    var captureError: Bool = false
    var uploadImageData: (url: URL?, filePath: String?) = (url: nil, filePath: nil)
    var address: String = ""
    var password: String = ""
    var passwordConfirm: String = ""
    var passHidden: Bool = true
    var passHiddenConfirm: Bool = true
    var createAccountTitle: Bool = false
    var createAccountShowContents: Bool = false
    var startFetchContents: Bool = false
    var isShowProgressView: Bool = false
    var isShowPickerView: Bool = false
    var isShowGoBackLogInAlert: Bool = false
    var showHalfSheet: Bool = false
    var showSheetBackground: Bool = false
    var keyboardOffset: CGFloat = 0.0
    var repeatAnimation: Bool = false
    var showHalfSheetOffset: CGFloat = UIScreen.main.bounds.height / 2
    var sendAddressButtonDisabled: Bool = true
    var firstSelect: FirstSelect = .start
    var selectSignInType: SelectSignInType = .start
    var createAccountFase: CreateAccountFase = .start
    var addressCheck: AddressCheck = .start
    var selectUserColor: MemberColor = .gray
}

// ✅ ログイン画面の親Viewです。

struct LogInView: View { // swiftlint:disable:this type_body_length
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @StateObject var logInVM: LogInViewModel
    @StateObject var teamVM: TeamViewModel
    
    @State private var logInNavigationPath: [Navigation] = []
    @State private var inputLogIn: InputLogIn = InputLogIn()
    @State private var createFaseLineImprove: CGFloat = 0.0
    
    @FocusState private var showKyboard: ShowKyboard?
    
    var body: some View {
        
        ZStack {
            
            GradientBackbround(color1: inputLogIn.selectUserColor.color1,
                               color2: inputLogIn.selectUserColor.colorAccent)
            .onTapGesture { showKyboard = nil }
            
            Group {
                if let captureImage = inputLogIn.captureImage {
                    UIImageCircleIcon(photoImage: captureImage, size: 60)
                } else {
                    Image(systemName: "person.circle.fill").resizable().scaledToFit()
                        .foregroundColor(.white.opacity(0.5)).frame(width: 60)
                }
            }
            .offset(x: -getRect().width / 3, y: -getRect().height / 2.5 - 5)
            .offset(x: inputLogIn.createAccountFase == .fase3 || inputLogIn.createAccountFase == .fase3 ? 0 : 30)
            .opacity(inputLogIn.createAccountFase == .fase3 || inputLogIn.createAccountFase == .fase3 ? 1.0 : 0.0)
            .onTapGesture { inputLogIn.isShowPickerView.toggle() }
            
            LogoMark()
                .scaleEffect(inputLogIn.firstSelect == .signAp ? 0.4 : 1.0)
                .offset(y: inputLogIn.firstSelect == .signAp ? -getRect().height / 2.5 : -getRect().height / 4)
                .offset(x: inputLogIn.firstSelect == .signAp ? getRect().width / 3 : 0)
                .opacity(inputLogIn.firstSelect == .signAp ? 0.4 : 1.0)
            
            /// ログインフロー全体的なコンテンツをまとめたGroup
            /// View数が多いとコンパイルが通らないため現状こうしている
            Group {
                
                // 起動時最初のログイン画面で表示される「ログイン」「いえ、初めてです」ボタン
                firstSelectButtons()
                    .offset(y: getRect().height / 8)
                    .opacity(inputLogIn.firstSelect == .start ? 1.0 : 0.0)
                
                // ログイン画面最初のページで「ログイン」を選んだ時のコンテンツView
                if inputLogIn.firstSelect == .logIn {
                    VStack {
                        signInTitle(title: "ログイン")
                            .padding(.bottom)
                        
                        ZStack {
                            logInSelectButtons()
                        }
                    }
                    .offset(y: getRect().height / 10)
                    .opacity(inputLogIn.firstSelect == .logIn ? 1.0 : 0.0)
                }
                
                // アカウント登録フローで用いるコンテンツ全体のView
                if inputLogIn.createAccountFase != .start {
                    createAccountViews()
                }
                
                // アカウント登録の進捗を表すインジケーター
                if inputLogIn.firstSelect == .signAp {
                    createAccountIndicator()
                        .offset(y: -getRect().height / 3 + 30)
                        .padding(.bottom)
                }
                
                // アカウント登録フロー時、前のフェーズに戻るボタン
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
                            
                            switch inputLogIn.createAccountFase {
                            case .start: print("")
                            case .fase1:
                                inputLogIn.firstSelect = .start
                                inputLogIn.createAccountFase = .start
                                inputLogIn.createAccountTitle = false
                                inputLogIn.createAccountShowContents = false
                            case .fase2:
                                inputLogIn.createAccountFase = .fase1
                            case .fase3:
                                inputLogIn.createAccountFase = .fase2
                                if inputLogIn.createUserNameText == "名無し" { inputLogIn.createUserNameText = ""
                                }
                            case .success: print("")
                            }
                            
                        }
                    } label: {
                        Text("< 戻る")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .disabled(inputLogIn.addressCheck == .success ? true : false)
                    .opacity(inputLogIn.addressCheck == .success ? 0.2 : 1.0)
                    .opacity(inputLogIn.createAccountFase == .fase1 && !inputLogIn.createAccountShowContents ? 0.0 : 1.0)
                    .offset(y: getRect().height / 3)
                }
                
                // ログイン画面最初のページまで戻るボタン
                if inputLogIn.firstSelect != .start {
                    Button {
                        inputLogIn.isShowGoBackLogInAlert.toggle()
                    } label: {
                        HStack {
                            Text("<<")
                            Image(systemName: "house.fill")
                        }
                    }
                    .disabled(inputLogIn.addressCheck == .start || inputLogIn.addressCheck == .success ? true : false)
                    .opacity(inputLogIn.addressCheck == .start || inputLogIn.addressCheck == .success ? 0.2 : 1.0)
                    .opacity(inputLogIn.createAccountFase == .start ||
                             inputLogIn.createAccountFase == .fase1 ||
                             inputLogIn.createAccountFase == .success ? 0.0 : 1.0)
                    .foregroundColor(.white.opacity(0.5))
                    .offset(x: -getRect().width / 2 + 40, y: getRect().height / 2 - 60 )
                    .alert("確認", isPresented: $inputLogIn.isShowGoBackLogInAlert) {
                        
                        Button {
                            inputLogIn.isShowGoBackLogInAlert.toggle()
                        } label: {
                            Text("いいえ")
                        }
                        
                        Button {
                            withAnimation(.spring(response: 0.7)) {
                                inputLogIn.selectSignInType = .start
                                inputLogIn.firstSelect = .start
                                inputLogIn.createAccountFase = .start
                                inputLogIn.createAccountTitle = false
                                inputLogIn.createAccountShowContents = false
                                if inputLogIn.createUserNameText == "名無し" { inputLogIn.createUserNameText = "" }
                            }
                            
                        } label: {
                            Text("はい")
                        }
                    } message: {
                        Text("ログイン画面に戻ります。よろしいですか？")
                    } // alert
                    
                    // Anonymous Started button...
                    Button {
                        // Open navigate tab srideView...
                        Task {
                            logInVM.signInAnonymously()
                            logInVM.currentUserCheckListener()
                        }
                    } label: {
                        HStack {
                            Text("始めてみる")
                            Text(">>")
                        }
                        .font(.subheadline).tracking(2).opacity(0.8)
                    }
                    .disabled(inputLogIn.createAccountFase == .success ? true : false)
                    .foregroundColor(.white.opacity(0.6))
                    .opacity(inputLogIn.createAccountFase == .success || inputLogIn.createAccountShowContents == false ? 0.0 : 1.0)
                    .offset(x: getRect().width / 2 - 80, y: getRect().height / 2 - 60 )
                }
                
                // メールアドレス登録選択時に出現するアドレス入力ハーフシートView
                inputAdressHalfSheet()
                
                // 処理中を表すプログレスView
                if inputLogIn.isShowProgressView {
                    CustomProgressView()
                }
                
            }
            
        } // ZStack
        .sheet(isPresented: $inputLogIn.isShowPickerView) {
            PHPickerView(captureImage: $inputLogIn.captureImage, isShowSheet: $inputLogIn.isShowPickerView, isShowError: $inputLogIn.captureError)
        }
        .onChange(of: inputLogIn.createAccountFase) { newFase in
            withAnimation(.spring(response: 1.0)) {
                switch newFase {
                case .start: createFaseLineImprove = 0
                case .fase1: createFaseLineImprove = 0
                case .fase2: createFaseLineImprove = 100
                case .fase3: createFaseLineImprove = 200
                case .success: createFaseLineImprove = 200
                }
            }
        }
        
        // currentUserを監視するリスナーによってサインインが検知されたら、各項目ごとに次のフェーズへ移行
        .onChange(of: logInVM.successSignInAccount) { signInCheck in
            print("logInVM.successCreateAccount更新を検知")
            if !signInCheck { return }
            switch inputLogIn.firstSelect {
            case .start: print("")
            case .logIn: withAnimation(.spring(response: 0.5)) { logInVM.rootNavigation = .fetch }
            case .signAp:
                Task {
                    let addUserFirestoreCheck = await logInVM.addNewUserSetData(name: inputLogIn.createUserNameText,
                                                                                password: inputLogIn.password,
                                                                                imageData: inputLogIn.captureImage,
                                                                                color: inputLogIn.selectUserColor)
                    if addUserFirestoreCheck {
                        withAnimation(.spring(response: 0.5)) {
                            logInVM.rootNavigation = .fetch
                        }
                    }
                }
            }
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
                
                inputLogIn.createAccountFase = .fase1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.spring(response: 1.0)) {
                        inputLogIn.createAccountTitle = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                    withAnimation(.spring(response: 1.0)) {
                        inputLogIn.createAccountShowContents = true
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
            
            // Sign In With Apple...
            SignInWithAppleButton(.signIn) { request in
                inputLogIn.selectSignInType = .apple
                logInVM.handleSignInWithAppleRequest(request)
            } onCompletion: { result in
                logInVM.handleSignInWithAppleCompletion(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(width: 250, height: 50)
            .cornerRadius(8)
            .shadow(radius: 10, x: 5, y: 5)
            
            Text("または")
                .foregroundColor(.white).opacity(0.7)
                .tracking(2)
            
            Button {
                withAnimation(.easeIn(duration: 0.25)) {
                    inputLogIn.showSheetBackground.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                        inputLogIn.showHalfSheet.toggle()
                    }
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
                switch inputLogIn.createAccountFase {
                case .start: Text("")
                case .fase1:
                    
                    VStack(spacing: 10) {
                        Text("あなたの色は？")
                            .tracking(10)
                        
                    }
                    
                case .fase2:
                    
                    VStack(spacing: 10) {
                        Text("unicoへようこそ").tracking(10)
                        Text("あなたのことを教えてください")
                    }
                    
                case .fase3:
                    
                    //                    if inputLogIn.selectSignInType != .mailAddress {
                    VStack(spacing: 10) {
                        Text("初めまして、\(inputLogIn.createUserNameText)さん")
                        Text("どちらから登録しますか？")
                    }
                    .frame(width: 250)
                    //                    }
                case .success:
                    VStack(spacing: 10) {
                        Text("アカウント登録が完了しました！")
                            .frame(width: 250)
                    }
                }
            } // Group
            .tracking(5)
            .font(.subheadline).foregroundColor(.white.opacity(0.6))
            .opacity(inputLogIn.createAccountTitle ? 1.0 : 0.0)
            
            Group {
                switch inputLogIn.createAccountFase {
                    
                case .start: Text("")
                    
                case .fase1:
                    
                    VStack {
                        Label("Tap!", systemImage: "hand.tap.fill")
                            .foregroundColor(.white)
                            .opacity(inputLogIn.createAccountShowContents ? 0.5 : 0.0)
                            .tracking(3)
                            .offset(y: -10)
                        
                        ColorCubeView(colorSet: $inputLogIn.selectUserColor)
                            .padding()
                    }
                    .offset(y: 20)
                    
                    Button {
                        withAnimation(.spring(response: 1.0)) {
                            inputLogIn.createAccountTitle = false
                            inputLogIn.createAccountShowContents = false
                            inputLogIn.createAccountFase = .fase2
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.spring(response: 0.8)) {
                                inputLogIn.createAccountTitle = true
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.spring(response: 0.8)) {
                                inputLogIn.createAccountShowContents = true
                            }
                        }
                        
                    } label: {
                        Text("次へ")
                    }
                    .buttonStyle(.borderedProminent)
                    .offset(y: 20)
                    
                case .fase2:
                    
                    Group {
                        if let captureImage = inputLogIn.captureImage {
                            UIImageCircleIcon(photoImage: captureImage, size: 150)
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
                        .foregroundColor(.white)
                        .focused($showKyboard, equals: .check)
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.center)
                        .background {
                            ZStack {
                                Text(showKyboard == nil && inputLogIn.createUserNameText.isEmpty ? "名前を入力" : "")
                                    .foregroundColor(.white.opacity(0.3))
                                Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                                    .offset(y: 20)
                            }
                        }
                    
                    Button {
                        
                        withAnimation(.spring(response: 0.9)) {
                            inputLogIn.createAccountTitle = false
                            inputLogIn.createAccountShowContents = false
                            inputLogIn.createAccountFase = .fase3
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            if inputLogIn.createUserNameText.isEmpty { inputLogIn.createUserNameText = "名無し"
                            }
                            withAnimation(.spring(response: 0.7)) {
                                inputLogIn.createAccountTitle = true
                                inputLogIn.createAccountShowContents = true
                            }
                        }
                    } label: {
                        Text("次へ")
                    }
                    .buttonStyle(.borderedProminent)
                    
                case .fase3:
                    
                    VStack(spacing: 30) {
                        signInTitle(title: "新規登録")
                        logInSelectButtons()
                    }
                case .success:
                    EmptyView()
                }
            }
            .opacity(inputLogIn.createAccountShowContents ? 1.0 : 0.0)
            
        } // VStack
    }
    func inputAdressHalfSheet() -> some View {
        VStack {
            Spacer()
            RoundedRectangle(cornerRadius: 40)
                .frame(width: getRect().width, height: getRect().height / 2)
                .foregroundColor(colorScheme == .light ? .customHalfSheetForgroundLight : .customHalfSheetForgroundDark)
                .onTapGesture { showKyboard = nil }
                .overlay {
                    VStack {
                        HStack {
                            Text("Mail Address")
                                .font(.title2).fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                                    inputLogIn.showHalfSheet.toggle()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    inputLogIn.showSheetBackground.toggle()
                                    inputLogIn.addressCheck = .start
                                }
                            } label: {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray.opacity(0.2))
                                    .overlay {
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary.opacity(0.7))
                                            .frame(width: 10, height: 10)
                                    }
                            }
                            .disabled(inputLogIn.addressCheck == .check ? true : false)
                            .opacity(inputLogIn.addressCheck == .check ? 0.3 : 1.0)
                        }
                        .padding([.horizontal, .top], 20)
                        .padding(.bottom, 10)
                        
                        HStack(spacing: 10) {
                            if inputLogIn.addressCheck == .check {
                                ProgressView()
                            } else {
                                inputLogIn.addressCheck.checkIcon
                                    .foregroundColor(inputLogIn.addressCheck == .failure ? .red : .green)
                            }
                            Text(inputLogIn.addressCheck.checkText)
                                .tracking(5)
                                .opacity(0.5)
                                .fontWeight(.semibold)
                        }
                        .frame(width: 300, height: 30)
                        .opacity(inputLogIn.addressCheck != .start ? 1.0 : 0.0)
                        
                        HStack(spacing: 35) {
                            
                            Image(systemName: "envelope.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                                .scaleEffect(inputLogIn.addressCheck == .check ? 1.0 :
                                                inputLogIn.addressCheck == .success ? 1.4 :
                                                1.0)
                                .opacity(inputLogIn.addressCheck == .check ? 0.8 :
                                            inputLogIn.addressCheck == .failure ? 0.8 :
                                            inputLogIn.addressCheck == .success ? 1.0 :
                                            0.8)
                                .overlay(alignment: .topTrailing) {
                                    Image(systemName: "questionmark")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .opacity(inputLogIn.addressCheck == .failure ? 0.5 : 0.0)
                                        .offset(x: 15, y: -15)
                                }
                            
                            if inputLogIn.addressCheck != .success {
                                Image(systemName: "arrowshape.turn.up.right.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .opacity(inputLogIn.addressCheck == .check ? 1.0 :
                                                inputLogIn.addressCheck == .failure ? 0.2 :
                                                0.4)
                                    .scaleEffect(inputLogIn.repeatAnimation ? 1.3 : 1.0)
                                    .animation(.default.repeat(while: inputLogIn.repeatAnimation),
                                               value: inputLogIn.repeatAnimation)
                            }
                            
                            if inputLogIn.addressCheck != .success {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                    .opacity(inputLogIn.addressCheck == .check ? 0.4 :
                                                inputLogIn.addressCheck == .failure ? 0.2 :
                                                0.8)
                                    .scaleEffect(inputLogIn.addressCheck == .check ? 0.8 : 1.0)
                            }
                        }
                        .frame(height: 60)
                        .padding(.bottom)
                        // リピートスケールアニメーションの発火トリガー
                        .onChange(of: inputLogIn.addressCheck) { newValue in
                            if newValue == .check {
                                inputLogIn.repeatAnimation = true
                            } else {
                                inputLogIn.repeatAnimation = false
                            }
                        }
                        
                        VStack(spacing: 5) {
                            Text(inputLogIn.addressCheck.messageText.text1)
                            Text(inputLogIn.addressCheck.messageText.text2)
                        }
                        .font(.subheadline)
                        .tracking(1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        
                        
                        TextField("メールアドレスを入力", text: $inputLogIn.address)
                            .focused($showKyboard, equals: .check)
                            .autocapitalization(.none)
                            .padding()
                            .frame(width: getRect().width * 0.8, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(colorScheme == .dark ? .gray.opacity(0.2) : .white)
                                    .frame(height: 30)
                                    .shadow(color: showKyboard == .check ? .blue : .clear, radius: 3)
                            )
                            .padding(20)
                            .onChange(of: inputLogIn.address) { newValue in
                                if newValue.isEmpty {
                                    inputLogIn.sendAddressButtonDisabled = true
                                } else {
                                    inputLogIn.sendAddressButtonDisabled = false
                                }
                            }
                        
                        // アドレス認証を行うボタン
                        Button(inputLogIn.addressCheck == .start ||
                               inputLogIn.addressCheck == .check ? "メールを送信" : "もう一度送る") {
                            
                            withAnimation(.easeInOut(duration: 0.3)) {
                                inputLogIn.addressCheck = .check
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    inputLogIn.addressCheck = .success
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(inputLogIn.sendAddressButtonDisabled)
                        .opacity(inputLogIn.addressCheck == .check ? 0.3 : 1.0)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                }
        }
        .offset(y: inputLogIn.showHalfSheet ? 0 : getRect().height / 2)
        .offset(y: getSafeArea().bottom)
        .background {
            Color.black.opacity(inputLogIn.showSheetBackground ? 0.7 : 0.0)
                .ignoresSafeArea()
                .onTapGesture {
                    showKyboard = nil
                }
        }
    }
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
                    .foregroundColor(inputLogIn.createAccountFase != .fase1 ? .green : .white)
                    .scaleEffect(inputLogIn.createAccountFase == .fase1 && inputLogIn.createAccountShowContents ? 1.5 : 1.0)
                    .overlay(alignment: .top) {
                        Text("Check!")
                            .font(.caption2).foregroundColor(.white.opacity(0.5))
                            .frame(width: 50)
                            .opacity(inputLogIn.createAccountFase == .fase1 && inputLogIn.createAccountShowContents ? 1.0 : 0.0)
                            .offset(y: -20)
                    }
            }
        
            .overlay {
                Circle().frame(width: 12, height: 12)
                    .foregroundColor(inputLogIn.createAccountFase != .fase1 &&
                                     inputLogIn.createAccountFase != .fase2 ? .green : .white)
                    .scaleEffect(inputLogIn.createAccountFase == .fase2 && inputLogIn.createAccountShowContents ? 1.5 : 1.0)
                    .overlay(alignment: .top) {
                        Text("Check!")
                            .font(.caption2).foregroundColor(.white.opacity(0.5))
                            .frame(width: 50)
                            .opacity(inputLogIn.createAccountFase == .fase2 && inputLogIn.createAccountShowContents ? 1.0 : 0.0)
                            .offset(y: -20)
                    }
            }
        
            .overlay(alignment: .trailing) {
                Circle().frame(width: 12, height: 12)
                    .foregroundColor(inputLogIn.createAccountFase != .fase1 &&
                                     inputLogIn.createAccountFase != .fase2 &&
                                     inputLogIn.createAccountFase != .fase3 ? .green : .white)
                    .scaleEffect(inputLogIn.createAccountFase == .fase3 && inputLogIn.createAccountShowContents ? 1.5 : 1.0)
                    .overlay(alignment: .top) {
                        Text("Check!")
                            .font(.caption2).foregroundColor(.white.opacity(0.5))
                            .frame(width: 50)
                            .opacity(inputLogIn.createAccountFase == .fase3 && inputLogIn.createAccountShowContents ? 1.0 : 0.0)
                            .offset(y: -20)
                    }
            }
    }
    
} // View

struct InputAddressAndPasswordField: View {
    
    @StateObject var logInVM: LogInViewModel
    @Binding var inputLogIn: InputLogIn
    
    @State private var addressHidden: Bool = false
    @State private var passwordHidden: Bool = false
    @State private var passwordCount6Lower: Bool = false
    @State private var passwordConfirmIsEmpty: Bool = false
    @State private var passwordConfirmDifference: Bool = false
    @State private var disabledButton: Bool = false
    @State private var signUpErrorMessage: String = ""
    
    @FocusState private var createAccountFocused: ShowKyboard?
    
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
                    createAccountFocused = nil
                    
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
                                // メールアドレスを用いてユーザを登録する
                                let checkSignUp = await logInVM.signUpEmailAdress(email: inputLogIn.address,
                                                                                  password: inputLogIn.password)
                                if !checkSignUp { inputLogIn.addressCheck = .failure; return }
                                
                                let uplaodImageData = await  logInVM.uploadImage(inputLogIn.captureImage)
                                let newUserData = User(id: logInVM.uid!,
                                                       name: inputLogIn.createUserNameText,
                                                       address: inputLogIn.address,
                                                       password: inputLogIn.password,
                                                       iconURL: uplaodImageData.url,
                                                       iconPath: uplaodImageData.filePath,
                                                       userColor: inputLogIn.selectUserColor,
                                                       joins: [])
                                
                                let checkAddUser = await logInVM.addUserMailAdress(userData: newUserData)
                                
                                if checkSignUp, checkAddUser {
                                    // サインアップ成功
                                    withAnimation(.spring(response: 0.5)) { inputLogIn.addressCheck = .success }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        // RootViewのfetch処理へ移動
                                        withAnimation(.spring(response: 0.5)) {
                                            logInVM.rootNavigation = .fetch
                                        }
                                    }
                                    
                                } else {
                                    // サインアップ失敗
                                    withAnimation(.spring(response: 0.5)) { inputLogIn.addressCheck = .failure }
                                }
                            }
                            
                        case .logIn:
                            Task {
                                let checkSignIn = await logInVM.signInEmailAdress(email: inputLogIn.address,
                                                                                  password: inputLogIn.password)
                                if checkSignIn {
                                    // ログイン成功
                                    withAnimation(.spring(response: 0.5)) { inputLogIn.addressCheck = .success }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        // RootViewのfetch処理へ移動
                                        withAnimation(.spring(response: 0.5)) {
                                            logInVM.rootNavigation = .fetch
                                        }
                                    }
                                } else {
                                    // ログイン失敗
                                    withAnimation(.spring(response: 0.5)) { inputLogIn.addressCheck = .failure }
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputLogIn.addressCheck == .start || inputLogIn.addressCheck == .success ? true : false)
                .overlay(alignment: .top) {
                    HStack {
                        if inputLogIn.addressCheck == .start {
                            ProgressView().frame(width: 10, height: 10)
                        } else {
                            inputLogIn.addressCheck.checkIcon.foregroundColor(inputLogIn.addressCheck == .failure ? .red : .green)
                        }
                        Text(inputLogIn.addressCheck.checkText).foregroundColor(.white.opacity(0.5))
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
                        
                        inputLogIn.addressCheck = .start
                    }
                    .overlay(alignment: .bottom) {(Rectangle().frame(height: 1)) }
                    .font(.caption)
                    .foregroundColor(.white)
                    .offset(x: 100)
                    .opacity(inputLogIn.addressCheck == .failure ? 1.0 : 0.0)
                }
                .padding(.top, 20)
                
                Text(inputLogIn.addressCheck == .failure ? logInVM.logInErrorMessage :
                        inputLogIn.addressCheck == .success ? inputLogIn.firstSelect == .logIn ?
                     "ログインに成功しました！"  : "ユーザ登録が完了しました！" : "")
                .font(.subheadline).fontWeight(.bold)
                .foregroundColor(inputLogIn.addressCheck == .failure ? .red : .white).opacity(0.8)
                .opacity(inputLogIn.addressCheck == .failure || inputLogIn.addressCheck == .success ? 1.0 : 0.0)
                .frame(height: 20)
                
            } // VStack
            
            .onDisappear {
                addressHidden = false
                passwordHidden = false
                passwordCount6Lower = false
                passwordConfirmIsEmpty = false
                passwordConfirmDifference = false
                logInVM.logInErrorMessage = ""
                inputLogIn.addressCheck = .start
            }
        }
    } // body
} // View

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView(logInVM: LogInViewModel(), teamVM: TeamViewModel())
    }
}
