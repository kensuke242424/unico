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

enum SelectSignInType {
    case logIn, signAp, start
}

enum SelectProviderType {
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

enum AddressSignInFase {
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
        case .start: return ("メールアドレスに本人確認メールを送ります。",
                             "入力に間違いがないかチェックしてください。")
        case .check: return ("メールアドレスをチェックしています...", "")
        case .failure: return ("認証メールの送信に失敗しました。", "アドレスを確認して、再度試してみてください。")
        case .success: return ("認証メールを送信しました！", "メール内のリンクからunicoへアクセスしてください。")
        }
    }
}

enum LogInAlert {
    case start
    case sendMailLinkUpperLimit
    case emailImproper
    case existsUserDocument
    case existsEmailAddress
    
    var title: String {
        switch self {
        case .start:
            return ""
        case .sendMailLinkUpperLimit:
            return "送信の上限"
        case .emailImproper:
            return "エラー"
        case .existsUserDocument:
            return "ログイン"
        case .existsEmailAddress:
            return "ログイン"
        }
    }
    
    var text: String {
        switch self {
        case .start:
            return ""
        case .sendMailLinkUpperLimit:
            return "認証メールの送信上限に達しました。日にちを置いてアクセスしてください。"
        case .emailImproper:
            return "アドレスの書式が正しくありません。"
        case .existsUserDocument:
            return "あなたのアカウントには以前作成したunicoのデータが存在します。ログインしますか？"
        case .existsEmailAddress:
            return "あなたのアカウントには以前作成したunicoデータが存在します。ログインしますか？"
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
    var showEmailHalfSheet: Bool = false
    var showSheetBackground: Bool = false
    var keyboardOffset: CGFloat = 0.0
    var repeatAnimation: Bool = false
    var showHalfSheetOffset: CGFloat = UIScreen.main.bounds.height / 2
    var sendAddressButtonDisabled: Bool = true
    var createAccountFase: CreateAccountFase = .start
    var selectUserColor: MemberColor = .gray
}

// ✅ ログイン画面の親Viewです。

struct LogInView: View { // swiftlint:disable:this type_body_length
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var progress: ProgressViewModel
    
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
                .scaleEffect(logInVM.selectSignInType == .signAp ? 0.4 : 1.0)
                .offset(y: logInVM.selectSignInType == .signAp ? -getRect().height / 2.5 : -getRect().height / 4)
                .offset(x: logInVM.selectSignInType == .signAp ? getRect().width / 3 : 0)
                .opacity(logInVM.selectSignInType == .signAp ? 0.4 : 1.0)
            
            /// ログインフロー全体的なコンテンツをまとめたGroup
            /// View数が多いとコンパイルが通らないため現状こうしている
            Group {
                
                // 起動時最初のログイン画面で表示される「ログイン」「いえ、初めてです」ボタン
                firstSelectButtons()
                    .offset(y: getRect().height / 8)
                    .opacity(logInVM.selectSignInType == .start ? 1.0 : 0.0)
                
                // ログイン画面最初のページで「ログイン」を選んだ時のコンテンツView
                if logInVM.selectSignInType == .logIn {
                    VStack {
                        signInTitle(title: "ログイン")
                            .padding(.bottom)
                        
                        ZStack {
                            logInSelectButtons()
                        }
                    }
                    .offset(y: getRect().height / 10)
                    .opacity(logInVM.selectSignInType == .logIn ? 1.0 : 0.0)
                }
                
                // アカウント登録フローで用いるコンテンツ全体のView
                if inputLogIn.createAccountFase != .start {
                    createAccountViews()
                }
                
                // アカウント登録の進捗を表すインジケーター
                if logInVM.selectSignInType == .signAp {
                    createAccountIndicator()
                        .offset(y: -getRect().height / 3 + 30)
                        .padding(.bottom)
                }
                
                // アカウント登録フロー時、前のフェーズに戻るボタン
                if logInVM.selectSignInType != .start {
                    Button {
                        withAnimation(.spring(response: 0.5)) {
                            
                            if logInVM.selectProviderType == .mailAddress {
                                logInVM.selectSignInType = .start
                                return
                            }
                            
                            switch logInVM.selectSignInType {
                            case .start: print("")
                            case .logIn: logInVM.selectSignInType = .start
                            case .signAp: print("")
                            }
                            
                            switch inputLogIn.createAccountFase {
                            case .start: print("")
                            case .fase1:
                                logInVM.selectSignInType = .start
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
                    .disabled(logInVM.addressCheck == .success ? true : false)
                    .opacity(logInVM.addressCheck == .success ? 0.2 : 1.0)
                    .opacity(inputLogIn.createAccountFase == .fase1 && !inputLogIn.createAccountShowContents ? 0.0 : 1.0)
                    .offset(y: getRect().height / 3)
                }
                
                // ログイン画面最初のページまで戻るボタン
                if logInVM.selectSignInType != .start {
                    Button {
                        inputLogIn.isShowGoBackLogInAlert.toggle()
                    } label: {
                        HStack {
                            Text("<<")
                            Image(systemName: "house.fill")
                        }
                    }
                    .disabled(logInVM.addressCheck == .start || logInVM.addressCheck == .success ? true : false)
                    .opacity(logInVM.addressCheck == .start || logInVM.addressCheck == .success ? 0.2 : 1.0)
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
                                logInVM.selectSignInType = .start
                                logInVM.selectProviderType = .start
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
//                            logInVM.startCurrentUserListener()
                            logInVM.signInAnonymously()
                        }
                    } label: {
                        HStack {
                            Text("今すぐ始める？")
                            Text(">")
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
            }
            
            
        } // ZStack
        // ログインフロー全体のアラートを管理
        .alert(logInVM.logInAlertMessage.title, isPresented: $logInVM.isShowLogInFlowAlert) {

                switch logInVM.logInAlertMessage {
                case .start:
                    EmptyView()
                    
                case .emailImproper:
                    Button("OK") { logInVM.isShowLogInFlowAlert.toggle() }
                    
                case .sendMailLinkUpperLimit:
                    Button("OK") { logInVM.isShowLogInFlowAlert.toggle() }
                    
                case .existsUserDocument:
                    Button("戻る") {
                        logInVM.isShowLogInFlowAlert.toggle()
                        logInVM.existsCurrentUserCheck = false
                        logInVM.logOut()
                    }
                    Button("ログイン") {
                        withAnimation(.spring(response: 0.5)) {
                            logInVM.selectSignInType = .logIn
                            logInVM.rootNavigation = .fetch
                        }
                    }
                    
                case .existsEmailAddress:
                    Button("戻る") {
                        logInVM.isShowLogInFlowAlert.toggle()
                        logInVM.existsCurrentUserCheck = false
                        logInVM.logOut()
                    }
                    Button("ログイン") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            logInVM.rootNavigation = .fetch
                        }
                    }
                }
        } message: {
            Text(logInVM.logInAlertMessage.text)
        }
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
        
        // currentUserを監視するリスナーによってサインインが検知されたら、ユーザが選択したサインインフローに分岐して処理
        // (ログイン or サインアップ)
        .onChange(of: logInVM.existsCurrentUserCheck) { currentCheck in
            print("logInVM.checkCurrentUserExists更新を検知")
            print("checkCurrentUserExists: \(currentCheck)")
            if !currentCheck {
                return
            }
            switch logInVM.selectSignInType {
                
            case .start: print("")

            case .logIn: withAnimation(.spring(response: 0.5)) { logInVM.rootNavigation = .fetch }
            
            case .signAp:
                // ✅ユーザーがサインアップを選択していた場合は、ユーザードキュメントが既に作られているか確認する必要がある✅
                // userドキュメントが既にある場合は、新規上書きしてしまうのを防ぐためにsetUserDocumentを止め、アラートに移行する
                Task {
                    // サインアップ実行ユーザに既にuserDocumentが存在するかチェック
                    let existsUserDocument = try await logInVM.existUserDocumentCheck()
                    // もし既にユーザドキュメントが存在した場合は、setUserDocumentを実行しない
                    // 既存のドキュメントへのログインを促すアラートを出す
                    if existsUserDocument {
                        print(".onChange(of: logInVM.checkCurrentUserExists): 既に登録されているuserドキュメントを検知")
                        logInVM.logInAlertMessage = .existsUserDocument
                        logInVM.isShowLogInFlowAlert.toggle()
                        return
                    } else {
                        // userドキュメントが存在しなかった場合は、newUserSetDocumentを実行
                        let didSetUserDocument = await logInVM.setDocumentSignUpUser(name: inputLogIn.createUserNameText,
                                                                                    password: inputLogIn.password,
                                                                                    imageData: inputLogIn.captureImage,
                                                                                    color: inputLogIn.selectUserColor)
                        if didSetUserDocument {
                            withAnimation(.spring(response: 0.5)) {
                                logInVM.rootNavigation = .fetch
                            }
                        } else {
                            print("didSetUserDocument_Error!! -新規ユーザドキュメントの作成に失敗しました-")
                        }
                    }
                } // Task end
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
                    logInVM.selectSignInType = .logIn
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
                    logInVM.selectSignInType = .signAp
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
                logInVM.selectProviderType = .apple
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
                        inputLogIn.showEmailHalfSheet.toggle()
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
                case .start:
                    Text("")
                    
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
                    VStack(spacing: 10) {
                        Text("初めまして、\(inputLogIn.createUserNameText)さん")
                        Text("どちらから登録しますか？")
                    }
                    .frame(width: 250)

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
                            if inputLogIn.createUserNameText.isEmpty {
                                inputLogIn.createUserNameText = "名無し"
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
                            Text(logInVM.selectSignInType == .logIn ?  "Mail Address  ログイン" : "Mail Address  ユーザー登録")
                                .font(.title3).fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                                    inputLogIn.showEmailHalfSheet.toggle()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    inputLogIn.showSheetBackground.toggle()
                                    logInVM.addressCheck = .start
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
                            .disabled(logInVM.addressCheck == .check ? true : false)
                            .opacity(logInVM.addressCheck == .check ? 0.3 : 1.0)
                        }
                        .padding([.horizontal, .top], 20)
                        .padding(.bottom, 10)
                        
                        HStack(spacing: 10) {
                            if logInVM.addressCheck == .check {
                                ProgressView()
                            } else {
                                logInVM.addressCheck.checkIcon
                                    .foregroundColor(logInVM.addressCheck == .failure ? .red : .green)
                            }
                            Text(logInVM.addressCheck.checkText)
                                .tracking(5)
                                .opacity(0.5)
                                .fontWeight(.semibold)
                        }
                        .frame(width: 300, height: 30)
                        .opacity(logInVM.addressCheck != .start ? 1.0 : 0.0)
                        
                        HStack(spacing: 35) {
                            
                            Image(systemName: "envelope.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                                .scaleEffect(logInVM.addressCheck == .check ? 1.0 :
                                                logInVM.addressCheck == .success ? 1.4 :
                                                1.0)
                                .opacity(logInVM.addressCheck == .check ? 0.8 :
                                            logInVM.addressCheck == .failure ? 0.8 :
                                            logInVM.addressCheck == .success ? 1.0 :
                                            0.8)
                                .overlay(alignment: .topTrailing) {
                                    Image(systemName: "questionmark")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .opacity(logInVM.addressCheck == .failure ? 0.5 : 0.0)
                                        .offset(x: 15, y: -15)
                                }
                            
                            if logInVM.addressCheck != .success {
                                Image(systemName: "arrowshape.turn.up.right.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .opacity(logInVM.addressCheck == .check ? 1.0 :
                                                logInVM.addressCheck == .failure ? 0.2 :
                                                0.4)
                                    .scaleEffect(inputLogIn.repeatAnimation ? 1.3 : 1.0)
                                    .animation(.default.repeat(while: inputLogIn.repeatAnimation),
                                               value: inputLogIn.repeatAnimation)
                            }
                            
                            if logInVM.addressCheck != .success {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                    .opacity(logInVM.addressCheck == .check ? 0.4 :
                                                logInVM.addressCheck == .failure ? 0.2 :
                                                0.8)
                                    .scaleEffect(logInVM.addressCheck == .check ? 0.8 : 1.0)
                            }
                        }
                        .frame(height: 60)
                        .padding(.bottom)
                        // リピートスケールアニメーションの発火トリガー(アドレス入力の.check時に使用)
                        .onChange(of: logInVM.addressCheck) { newValue in
                            if newValue == .check {
                                inputLogIn.repeatAnimation = true
                            } else {
                                inputLogIn.repeatAnimation = false
                            }
                        }
                        
                        VStack(spacing: 5) {
                            Text(logInVM.addressCheck.messageText.text1)
                            Text(logInVM.addressCheck.messageText.text2)
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
                        Button(logInVM.addressCheck == .start || logInVM.addressCheck == .check ? "メールを送信" : "もう一度送る") {
                            
                            withAnimation(.spring(response: 0.3)) { logInVM.addressCheck = .check }
                            
                            switch logInVM.selectSignInType {
                                
                            case .start :
                                print("処理なし")
                                
                            case .logIn :
                                // ここにアドレスからの既存アカウント探知処理
                                logInVM.existEmailAccountCheck(inputLogIn.address)
                                return
                                
                            case .signAp:
                                // 入力アドレス宛にリンクメールを送信するメソッド
                                logInVM.sendSignInLink(email: inputLogIn.address)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(inputLogIn.sendAddressButtonDisabled)
                        .opacity(logInVM.addressCheck == .check ? 0.3 : 1.0)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                }
        }
        .offset(y: inputLogIn.showEmailHalfSheet ? 0 : getRect().height / 2)
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

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView(logInVM: LogInViewModel(), teamVM: TeamViewModel())
    }
}
