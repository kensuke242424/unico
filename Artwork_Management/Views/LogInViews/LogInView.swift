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

enum UserSelectedSignInType {
    case logIn, signUp, start
}

enum SelectProviderType {
    case apple, google, mailAddress, trial, start
}

enum CreateAccountFase {
    case start, fase1, fase2, fase3, check, success
}

/// 「サインアップしようとしたが既存のアカウントがあった」などで、最終的に決まったログイン方法
enum ResultSignInType {
    case signIn, signUp
}

enum ShowKeyboard {
    case check
}

enum InputAddressFocused {
    case check
}

enum AddressSignInFase {
    case start, check, failure, exist, notExist, success
    
    var checkIcon: Image {
        switch self {
        case .start: return Image(systemName: "")
        case .check: return Image(systemName: "")
        case .failure: return Image(systemName: "multiply.circle.fill")
        case .exist: return Image(systemName: "multiply.circle.fill")
        case .notExist: return Image(systemName: "multiply.circle.fill")
        case .success: return Image(systemName: "checkmark.seal.fill")
        }
    }
    
    var humanIconBadge: Image {
        switch self {
        case .start: return Image(systemName: "")
        case .check: return Image(systemName: "")
        case .failure: return Image(systemName: "xmark.circle.fill")
        case .exist: return Image(systemName: "xmark.circle.fill")
        case .notExist: return Image(systemName: "xmark.circle.fill")
        case .success: return Image(systemName: "checkmark.circle.fill")
        }
    }
    
    var checkText: String {
        switch self {
        case .start: return ""
        case .check: return "check..."
        case .failure: return "failure!!"
        case .exist: return "exist Account!!"
        case .notExist: return "not Account!!"
        case .success: return "succsess!!"
        }
    }
    
    var messageText: (text1: String, text2: String) {
        switch self {
        case .start   : return ("メールアドレス宛に認証メールを送ります。"  ,
                                "届いたメールからunicoへアクセスしてください。")
            
        case .check   : return ("メールアドレスをチェックしています..."          ,
                                ""                                        )
            
        case .failure : return ("認証メールの送信に失敗しました。"              ,
                                "アドレスを確認して、再度試してみてください。"     )

        case .exist   : return ("このアドレスにはすでにアカウントが存在します。" ,
                                ""                                        )
            
        case .notExist: return ("このアドレスにはアカウントが存在しませんでした。" ,
                                ""                                        )
            
        case .success : return ("認証メールを送信しました！"                   ,
                                "※届くまで少し時間がかかる場合があります。"       )
        }
    }
}

enum LogInAlert {
    case start
    case sendMailLinkUpperLimit
    case invalidLink
    case emailImproper
    case existsUserDocument
    case existEmailAddressAccount
    case notExistEmailAddressAccount
    case notEmailCurrentMatches
    case other
    
    var title: String {
        switch self {
        case .start                   :
            return ""
        case .sendMailLinkUpperLimit  :
            return "送信の上限"
        case .invalidLink:
            return "エラー"
        case .emailImproper           :
            return "エラー"
        case .existsUserDocument      :
            return "ログイン"
        case .existEmailAddressAccount:
            return "ログイン"
        case .notExistEmailAddressAccount:
            return "アカウント無し"
        case .notEmailCurrentMatches:
            return "エラー"
            
        case .other:
            return "エラー"
        }
    }
    
    var text: String {
        switch self {
        case .start                   :
            return ""
        case .sendMailLinkUpperLimit  :
            return "認証メールの送信上限に達しました。日にちを置いてアクセスしてください。"
        case .invalidLink             :
            return "お使いのリンクは使用期限が切れている可能性があります。再度試してみてください。"
        case .emailImproper           :
            return "アドレスの書式が正しくありません。"
        case .existsUserDocument      :
            return "あなたのアカウントには以前作成したunicoのデータが存在します。ログインしますか？"
        case .existEmailAddressAccount:
            return "入力したアドレスには以前作成したunicoデータが存在します。ログインしますか？"
        case .notExistEmailAddressAccount:
            return "入力したメールアドレスのアカウントは存在しませんでした。ユーザの新規登録をしてください。"
        case .notEmailCurrentMatches  :
            return "入力したメールアドレスは登録されているアドレスと異なります。"
        case .other                   :
            return "処理に失敗しました。再度試してみてください。"
        }
    }
}

struct InputLogIn {
    /// 新規ユーザーデータの入力用プロパティ
    var createUserNameText      : String = ""
    var address                 : String = ""
    var password                : String = ""
    var captureUserIconImage    : UIImage?
    var captureBackgroundImage  : UIImage?
    var croppedUserIconImage    : UIImage?
    var croppedBackgroundImage  : UIImage?
    var selectUserColor         : ThemeColor = .blue
    
    /// Viewの表示・非表示やアニメーションをコントロールするプロパティ
    var checkBackgroundOpacity      : CGFloat = 1.0
    var keyboardOffset              : CGFloat = 0.0
    var checkBackgroundEffect       : Bool = false
    var checkBackgroundOpacityToggle: Bool = false
    var createAccountTitle          : Bool = false
    var createAccountShowContents   : Bool = false
    var repeatAnimation             : Bool = false
    var sendAddressButtonDisabled   : Bool = true
    var selectBackground            : BackgroundCategory = .music
    
    /// Sheetやアラートなどのプレゼンテーションを管理するプロパティ
    var showPicker                 : Bool = false
    var isShowAnonymousEntryRecomendation: Bool = false
    var isShowGoBackLogInAlert           : Bool = false
    var captureError                     : Bool = false

    var checkTermsAgree: Bool = true
    var showNotYetAgreeAlert: Bool = false

}

// ✅ ログイン画面の親Viewです。

struct LogInView: View { // swiftlint:disable:this type_body_length
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.isPresented) private var isPresented

    @EnvironmentObject var progress: ProgressViewModel
    
    @EnvironmentObject var logInVM: LogInViewModel
    @EnvironmentObject var teamVM : TeamViewModel
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var tagVM : TagViewModel

    @EnvironmentObject var backgroundVM: BackgroundViewModel
    
    @State private var logInNavigationPath: [Navigation] = []
    @State private var inputLogIn: InputLogIn = InputLogIn()
    @State private var createFaseLineImprove: CGFloat = 0.0

    // バックグラウンド選択フェーズで用いるプロパティ
    @State private var checkBackgroundToggle   : Bool = false
    @State private var checkBackgroundAnimation: Bool = false
    @AppStorage("applicationDarkMode") var applicationDarkMode: Bool = true
    
    @FocusState private var showEmailKeyboard: ShowKeyboard?

    @FocusState private var showUserNameKeyboard: ShowKeyboard?
    @State private var textFieldOffset: Bool = false
    
    var body: some View {
        
        ZStack {
            Group {
                if let captureImage = inputLogIn.croppedUserIconImage {
                    UIImageCircleIcon(photoImage: captureImage, size: 60)
                } else {
                    Image(systemName: "person.circle.fill").resizable().scaledToFit()
                        .foregroundColor(.white.opacity(0.5)).frame(width: 60)
                }
            }
            .offset(x: -getRect().width / 3, y: -getRect().height / 2.5 - 5)
            .offset(x: logInVM.createAccountFase == .fase3 ? 0 : 30)
            .opacity(logInVM.createAccountFase == .fase3 ? 1.0 : 0.0)
            .onTapGesture { inputLogIn.showPicker.toggle() }
            
            LargeLogoMark()
                .scaleEffect(logInVM.userSelectedSignInType == .signUp ? 0.4 : 1.0)
                .offset(y: logInVM.userSelectedSignInType == .signUp ? -getRect().height / 2.5 : -getRect().height / 4.5)
                .offset(x: logInVM.userSelectedSignInType == .signUp ? getRect().width / 3 : 0)
                .opacity(logInVM.userSelectedSignInType == .signUp ? 0.4 : 1.0)
            
            /// ログインフロー全体的なコンテンツをまとめたGroup
            /// View数が多いとコンパイルが通らないため、Groupで囲むことで対応
            Group {
                // 起動時最初のログイン画面で表示される「ログイン」「いえ、初めてです」ボタン
                firstSelectButtons()
                    .offset(y: getRect().height / 8)
                    .opacity(logInVM.userSelectedSignInType == .start ? 1.0 : 0.0)
                
                // ログイン画面最初のページで「ログイン」を選んだ時のコンテンツView
                if logInVM.userSelectedSignInType == .logIn {
                    VStack {
                        signInTitle(title: "ログイン")
                            .padding(.bottom)
                        
                        logInSelectButtons()
                    }
                    .offset(y: getRect().height / 10)
                    .opacity(logInVM.userSelectedSignInType == .logIn ? 1.0 : 0.0)
                }
                
                // アカウント登録フローで用いるコンテンツ全体のView
                if logInVM.createAccountFase != .start {
                    createAccountViews()
                }
                
                // アカウント登録の進捗を表すインジケーター
                if logInVM.userSelectedSignInType == .signUp {
                    createAccountIndicator()
                        .scaleEffect(userDeviseSize == .small ? 0.8 : 1)
                        .opacity(backgroundVM.checkMode ? 0 : 1)
                        .opacity(logInVM.createAccountFase == .check ||
                                 logInVM.createAccountFase == .success ? 0 : 1)
                        .offset(y: -getRect().height / 3 + 30)
                        .offset(y: userDeviseSize == .small ? -20 : 0)
                        .padding(.bottom)
                }
                
                // アカウント登録フロー時、前のフェーズに戻るボタン
                if logInVM.userSelectedSignInType != .start {
                    Button {
                        withAnimation(.spring(response: 0.5)) {
                            
                            switch logInVM.userSelectedSignInType {
                            case .start: print("")
                            case .logIn: logInVM.userSelectedSignInType = .start
                            case .signUp: print("")
                            }
                            
                            switch logInVM.createAccountFase {
                            case .start:
                                print("戻るボタンは非表示")
                                
                            case .fase1:
                                logInVM.userSelectedSignInType = .start
                                logInVM.createAccountFase = .start
                                inputLogIn.createAccountTitle = false
                                inputLogIn.createAccountShowContents = false
                                
                            case .fase2:
                                logInVM.createAccountFase = .fase1
                                
                            case .fase3:
                                logInVM.createAccountFase = .fase2
                                if inputLogIn.createUserNameText == "名無し" {
                                    inputLogIn.createUserNameText = ""
                                }
                                
                            case .check:
                                return
                                
                            case .success:
                                return
                            }
                            
                        }
                    } label: {
                        Text("< 戻る")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .opacity(0.7)
                    }
                    .buttonStyle(.bordered)
                    .disabled(logInVM.addressSignInFase == .success ||
                              logInVM.addressSignInFase == .check ? true : false)
                    .disabled(logInVM.createAccountFase == .success ||
                              logInVM.createAccountFase == .check ? true : false)
                    .opacity(logInVM.addressSignInFase == .success ||
                             logInVM.addressSignInFase == .check ? 0.2 : 1.0)
                    .opacity(logInVM.createAccountFase == .success ||
                             logInVM.createAccountFase == .check ? 0.0 : 1.0)
                    .opacity(logInVM.createAccountFase == .fase1 &&
                             !inputLogIn.createAccountShowContents ? 0.0 : 1.0)
                    .opacity(backgroundVM.checkMode ? 0 : 1)
                    .offset(y: getRect().height / 2 - 100)
                    .offset(y: userDeviseSize == .small ? 30 : 0)
                }
                
                // ログイン画面最初のページまで戻るボタン
                if logInVM.createAccountFase == .fase2 || logInVM.createAccountFase == .fase3 {
                    Button {
                        inputLogIn.isShowGoBackLogInAlert.toggle()
                    } label: {
                        HStack {
                            Text("<<")
                            Image(systemName: "house.fill")
                        }
                        .foregroundColor(.white)
                        .opacity(0.6)
                    }
                    .buttonStyle(.bordered)
                    .offset(x: -getRect().width / 2 + 40, y: getRect().height / 2 - 60 )
                    .alert("", isPresented: $inputLogIn.isShowGoBackLogInAlert) {
                        
                        Button {
                            inputLogIn.isShowGoBackLogInAlert.toggle()
                        } label: {
                            Text("いいえ")
                        }
                        
                        Button {
                            withAnimation(.spring(response: 0.7)) {
                                logInVM.userSelectedSignInType = .start
                                logInVM.selectProviderType = .start
                                logInVM.createAccountFase = .start
                                inputLogIn.createAccountTitle = false
                                inputLogIn.createAccountShowContents = false
                                if inputLogIn.createUserNameText == "名無し" { inputLogIn.createUserNameText = "" }
                            }
                            
                        } label: {
                            Text("はい")
                        }
                    } message: {
                        Text("最初の画面に戻りますか？")
                    } // alert
                    
                }
                // メールアドレス入力ハーフシートView
                if logInVM.showEmailHalfSheet {
                    switch logInVM.userSelectedSignInType {
                    case .start:
                        EmptyView()
                    case .logIn:
                        LogInAddressSheetView(useType: .signIn)
                    case .signUp:
                        LogInAddressSheetView(useType: .signUp)
                    }
                }

            } // Group
            .offset(y: textFieldOffset ? -100 : 0)
            .onChange(of: showUserNameKeyboard) { newValue in
                if newValue == .check {
                    withAnimation { textFieldOffset = true }
                } else {
                    withAnimation { textFieldOffset = false }
                }
            }
            
        } // ZStack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if inputLogIn.isShowAnonymousEntryRecomendation {
                AnonymousEntryRecomendationView(isShow: $inputLogIn.isShowAnonymousEntryRecomendation)
                    .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
            }
        }
        .ignoresSafeArea()
        
        // ログインフロー全体のアラートを管理
        .alert(logInVM.logInAlertMessage.title,
               isPresented: $logInVM.isShowLogInFlowAlert) {

            switch logInVM.logInAlertMessage {
                
            case .start                      :
                EmptyView()
                
            case .emailImproper              :
                Button("OK") {}
                
            case .sendMailLinkUpperLimit     :
                Button("OK") {}
                
            case .invalidLink                :
                Button("OK") {}
                
            case .existsUserDocument         :
                Button("戻る") {
                    logInVM.signedInOrNotResult = false
                    logInVM.logOut()
                }
                Button("ログイン") {
                    withAnimation(.spring(response: 0.5)) {
                        logInVM.resultSignInType = .signIn
                        logInVM.rootNavigation = .fetch
                    }
                }
                
            case .existEmailAddressAccount   :
                Button("戻る") {
                    logInVM.signedInOrNotResult = false
                    logInVM.addressSignInFase = .start
                }
                Button("ログイン") {
                    withAnimation(.spring(response: 0.5)) {
                        logInVM.resultSignInType = .signIn
                        logInVM.sendEmailLink(email: inputLogIn.address, useType: .signIn)
                    }
                }
                
            case .notExistEmailAddressAccount:
                Button("OK") {}
                
            case .notEmailCurrentMatches     :
                Button("OK") {}
                
            case .other                      :
                Button("OK") {}
            }
                    
        } message: {
            Text(logInVM.logInAlertMessage.text)
        }
        // ユーザーアイコンの写真ピッカー&クロップビュー
        .cropImagePicker(option: .circle,
                         show: $inputLogIn.showPicker,
                         croppedImage: $inputLogIn.croppedUserIconImage)
        // 背景の写真ピッカー&クロップビュー
        .cropImagePicker(option: .rectangle,
                         show: $backgroundVM.showPicker,
                         croppedImage: $inputLogIn.croppedBackgroundImage)

        .onChange(of: inputLogIn.croppedBackgroundImage) { newImage in
            guard let newImage else { return }
            Task {
                let resizedImage = backgroundVM.resizeUIImage(image: newImage)
                let uploadImage = await backgroundVM.uploadUserBackgroundAtSignUp(resizedImage)
                let myBackground = Background(category: "original",
                                               imageName: "",
                                               imageURL: uploadImage.url,
                                               imagePath: uploadImage.filePath)
                withAnimation {
                    backgroundVM.pickMyBackgroundsAtSignUp.append(myBackground)
                }
            }
        }
        .background {
            ZStack {
                GeometryReader { proxy in
                    Color.black.ignoresSafeArea()

                        SDWebImageBackgroundView(
                            imageURL: backgroundVM.selectBackground?.imageURL ??
                                      backgroundVM.sampleBackground.imageURL,
                            width: proxy.size.width,
                            height: proxy.size.height
                        )
                        .blur(radius: backgroundVM.checkMode ? 0 : 4, opaque: true)

                    Color(.black)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .opacity(backgroundVM.checkMode ? 0.0 :
                                 logInVM.createAccountFase == .success ? 0.5 :
                                 0.2)
                        .ignoresSafeArea()
                        .onTapGesture(perform: { showUserNameKeyboard = nil })
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: logInVM.createAccountFase) { newFaseValue in
            withAnimation(.spring(response: 1.0)) {
                switch newFaseValue {
                case .start  : createFaseLineImprove = 0
                case .fase1  : createFaseLineImprove = 0
                case .fase2  : createFaseLineImprove = 100
                case .fase3  : createFaseLineImprove = 200
                case .check  : createFaseLineImprove = 200
                case .success: createFaseLineImprove = 200
                }
            }
        }
        
        /// currentUserを監視するリスナーによってサインインが検知されたら、
        /// ユーザが選択したサインインフローに分岐して処理
        /// (ログイン or サインアップ)
        .onChange(of: logInVM.signedInOrNotResult) { resultValue in
            
            print("logInVM.signedInOrNotResultの更新を検知")
            if !resultValue {
                print("signedInOrNotResultがfalseでした。サインイン処理を終了します。")
                return
            }
            /// 🔰ログインボタンの先からお試しログインを選んだ場合、
            /// サインアップフローまで一気に飛ばして、各要素TitleとContentsをトグルして表示する
            if logInVM.selectProviderType == .trial {
                withAnimation(.easeInOut(duration: 0.5)) {
                    inputLogIn.createAccountTitle = true
                    inputLogIn.createAccountShowContents = true
                }
            }
            
            /// ✅ 「.signIn」ならfetch開始。「.signUp」なら各データの生成後にfetch開始 ✅
            switch logInVM.resultSignInType {

            case .signIn:
                withAnimation(.spring(response: 0.5)) {
                logInVM.rootNavigation = .fetch
                }
            
            case .signUp:
                
                Task {
                    do {
                        /// 以前に作った既存のuserDocumentデータがあるかどうかをチェック
                        /// もし存在したら、関数内で既存データへのログインを促すアラートを発火し、処理終了
                        try await logInVM.existUserDocumentCheck()
                        
                        withAnimation(.spring(response: 0.8).delay(0.5)) {
                            logInVM.createAccountFase = .check
                        }
                        // 保存対象のアイコン画像データ容器
                        var iconImageContainer: UIImage?
                        /// オリジナルアイコン画像が入力されている場合は、リサイズ処理しコンテナに格納
                        if let captureIconUIImage = inputLogIn.croppedUserIconImage {
                            iconImageContainer = logInVM.resizeUIImage(image: captureIconUIImage,
                                                                       width: 60)
                        }
                        /// ーーーーアイコンデータのアップロード処理ーーーー
                        let uplaodIconImageData = await userVM.uploadUserImage(iconImageContainer)

                        if inputLogIn.createUserNameText == "" { inputLogIn.createUserNameText = "名無し" }

                        /// ユーザーの入力値をもとにユーザーデータを作成し、Firestoreに保存⬇︎
                        try await logInVM.setNewUserDocumentToFirestore(name     : inputLogIn.createUserNameText,
                                                             password : inputLogIn.password,
                                                             imageData: uplaodIconImageData,
                                                             color    : inputLogIn.selectUserColor)

                        // Firestoreに保存したデータをローカルに引っ張ってくる
                        try await userVM.fetchUser()
                        guard let user = userVM.user else { return }

                        /// データ生成の成功を知らせるアニメーションの後、データのフェッチとログイン開始
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.spring(response: 1.3)) {
                                hapticSuccessNotification()
                                logInVM.createAccountFase = .success
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation(.spring(response: 0.7)) {
                                logInVM.rootNavigation = .fetch
                            }
                        }
                    } catch {
                        print("ユーザーデータの作成に失敗しました")
                        logInVM.isShowLogInFlowAlert.toggle()
                        logInVM.logInAlertMessage = .other
                        withAnimation(.spring(response: 0.5)) {
                            hapticErrorNotification()
                            logInVM.createAccountFase = .fase3
                        }
                    }
                } // Task end
            }
        }
        .onDisappear {
            resetLogInFase()
        }
    } // body
    /// ログイン画面の進行フローをリセットするメソッド。
    /// ログインビューが破棄された時に使用する。
    fileprivate func resetLogInFase() {
        logInVM.addressSignInFase = .start
        logInVM.createAccountFase = .start
        logInVM.selectProviderType = .start
        logInVM.resultSignInType = .signIn
        logInVM.userSelectedSignInType = .start
    }
    
    @ViewBuilder
    func signInTitle(title: String) -> some View {
        HStack {
            Rectangle()
                .opacity(0.4)
                .frame(width: 60, height: 1)
            Text(title)
                .tracking(10)
                .font(.subheadline)
                .opacity(0.7)
                .padding(.horizontal)
            Rectangle()
                .opacity(0.4)
                .frame(width: 60, height: 1)
        }
        .foregroundColor(.white)
    }
    @ViewBuilder
    func firstSelectButtons() -> some View {

        var buttonSize: CGSize {
            let buttonWidth: CGFloat = 250
            let buttonHeight: CGFloat = 60
            return CGSize(width: buttonWidth, height: buttonHeight)
        }
        
        VStack(spacing: 20) {
            Text("アカウントをお持ちですか？")
                .tracking(10)
                .foregroundColor(.white)
                .font(.subheadline)
                .opacity(0.8)
                .padding(.bottom, 40)
            
            Button {
                withAnimation(.easeIn(duration: 0.3)) {
                    logInVM.userSelectedSignInType = .logIn
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.black.opacity(0.1))
                        .frame(width: buttonSize.width, height: buttonSize.height)
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
                    logInVM.userSelectedSignInType = .signUp
                }
                
                logInVM.createAccountFase = .fase1
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
    @ViewBuilder
    func logInSelectButtons() -> some View {
        VStack(spacing: 25) {

            if logInVM.userSelectedSignInType == .signUp {
                TermsAndPrivacyView(isCheck: $inputLogIn.checkTermsAgree)
            }
            
            Button {
                if logInVM.userSelectedSignInType == .signUp && !inputLogIn.checkTermsAgree {
                    inputLogIn.showNotYetAgreeAlert.toggle()
                    return
                }

                withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                    logInVM.showEmailHalfSheet.toggle()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.blue.gradient)
                        .frame(width: 250, height: 50)
                        .shadow(radius: 10, x: 5, y: 5)
                    Label("メールアドレス", systemImage: "envelope.fill")
                        .fontWeight(.semibold)
                        .tracking(2)
                        .foregroundColor(.white)
                }
            }
            .alert("", isPresented: $inputLogIn.showNotYetAgreeAlert) {
                Button("OK") {}
            } message: {
                Text("利用規約とプライバシーポリシーの同意が必要です。")
            }
            
            Text("または")
                .tracking(2)
                .foregroundColor(.white)
                .opacity(0.7)

            Button {
                // お試しログイン選択時の処理
                hapticSuccessNotification()
                withAnimation(.easeInOut(duration: 0.4)) {
                    inputLogIn.isShowAnonymousEntryRecomendation.toggle()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.gray.gradient)
                        .frame(width: 250, height: 50)
                        .shadow(radius: 10, x: 5, y: 5)
                    Label("お試しでログイン", systemImage: "person.crop.circle.fill")
                        .fontWeight(.semibold)
                        .tracking(2)
                        .foregroundColor(.white)
                }
            }
        }
    }
    @ViewBuilder
    func createAccountViews() -> some View {
        
        VStack(spacing: 50) {
            
            Group {
                switch logInVM.createAccountFase {
                case .start:
                    Text("")
                    
                case .fase1:
                    VStack(spacing: 10) {
                        Text("お好きな壁紙を選んでください")
                    }
                    .tracking(5)
                    .offset(y: 30)
                    
                case .fase2:
                    VStack(spacing: 10) {
                        Text("unicoへようこそ")
                            .tracking(10)
                        Text("あなたのことを教えてください")
                    }
                    .frame(maxWidth: .infinity)
                    
                case .fase3:
                    VStack(spacing: 10) {
                        Text("初めまして、\(inputLogIn.createUserNameText)さん")
                        Text("どちらから登録しますか？")
                    }
                    .frame(maxWidth: .infinity)
                    
                case .check:
                    VStack(spacing: 10) {
                        Text("データを生成しています。")
                        Text("少しお時間いただきます...")
                    }
                    .frame(maxWidth: .infinity)

                case .success:
                    VStack(spacing: 10) {
                        Text("unicoの準備が完了しました！")
                        Text("ようこそ、\(inputLogIn.createUserNameText)さん")
                    }
                    .frame(maxWidth: .infinity)
                }
            } // Group
            .tracking(5)
            .font(userDeviseSize == .small ? .footnote : .subheadline)
            .foregroundColor(.white)
            .opacity(backgroundVM.checkMode ? 0 : 1)
            .opacity(inputLogIn.createAccountTitle ? 1.0 : 0.0)
            
            Group {
                switch logInVM.createAccountFase {
                    
                case .start: Text("")
                    
                // Fase1: 背景写真を選んでもらうフェーズ
                case .fase1:

                    VStack {
                        BackgroundCategoriesTagView()
                            .opacity(backgroundVM.checkMode ? 0 : 1)
                        SelectionBackgroundCards(showPicker: $backgroundVM.showPicker)
                            .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                            .opacity(backgroundVM.checkMode ? 0 : 1)
                            .onChange(of: backgroundVM.selectCategory) { newCategory in
                                /// タグ「original」を選択時、joinsに保存している現在のチームの画像データ群を取り出して
                                /// backgroundVMの背景管理プロパティに橋渡しする
                                if newCategory == .original {
                                    Task {
                                        await backgroundVM.resetSelectBackgroundImages()
                                        let myBackgrounds = userVM.getCurrentTeamMyBackgrounds()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            backgroundVM.appendMyBackgrounds(images: myBackgrounds)
                                        }
                                    }
                                } else {
                                    Task {
                                        await backgroundVM.resetSelectBackgroundImages()
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        Task {
                                            await backgroundVM.fetchCategoryBackgroundImage(category: newCategory.categoryName)
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                Task {
                                    let startCategory = backgroundVM.selectCategory.categoryName
                                    await backgroundVM.fetchCategoryBackgroundImage(category: startCategory)
                                }
                            }
                        Button("次へ") {
                            withAnimation(.spring(response: 1.0)) {
                                inputLogIn.createAccountTitle = false
                                inputLogIn.createAccountShowContents = false
                                logInVM.createAccountFase = .fase2
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
                        }
                        .buttonStyle(.borderedProminent)
                        .opacity(backgroundVM.checkMode ? 0 : 1)
                        .padding(.top)
                        .overlay {
                            EditBackgroundControlButtons()
                                .offset(x: UIScreen.main.bounds.width / 3,
                                        y: UIScreen.main.bounds.height / 10
                                )
                        }
                    }
                    .padding(.top, 20)
                    
                    /// ユーザー情報「名前」「アイコン」を入力するフェーズ
                case .fase2:
                    Group {
                        if let captureImage = inputLogIn.croppedUserIconImage {
                            UIImageCircleIcon(photoImage: captureImage, size: 150)
                        } else {
                            Image(systemName: "photo.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150)
                                .foregroundColor(.white)
                        }
                    }
                    .onTapGesture { inputLogIn.showPicker.toggle() }
                    .overlay(alignment: .top) {
                        Text("ユーザ情報は後から変更できます。")
                            .font(.caption)
                            .foregroundColor(.white)
                            .opacity(0.7)
                            .frame(width: 200)
                            .offset(y: -30)
                    }
                    .offset(y: 20)
                    
                    TextField("", text: $inputLogIn.createUserNameText)
                        .frame(width: 230)
                        .focused($showUserNameKeyboard, equals: .check)
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.center)
                        .background {
                            ZStack {
                                Text(showUserNameKeyboard == nil &&
                                     inputLogIn.createUserNameText.isEmpty ? "ユーザー名を入力" : "")
                                    .opacity(0.6)
                                Rectangle()
                                    .opacity(0.7)
                                    .frame(height: 1)
                                    .offset(y: 20)
                            }
                            .foregroundColor(.white)
                        }
                    
                    Button {
                        withAnimation { showUserNameKeyboard = nil }
                        withAnimation(.spring(response: 0.9)) {
                            inputLogIn.createAccountTitle = false
                            inputLogIn.createAccountShowContents = false
                            logInVM.createAccountFase = .fase3
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
                    
                case .check:
                    ProgressView()
                    
                case .success:
                    UIImageCircleIcon(photoImage: inputLogIn.croppedUserIconImage, size: 140)
                        .transition(AnyTransition.opacity.combined(with: .offset(y: 30)))
                    
                }
            }
            .opacity(inputLogIn.createAccountShowContents ? 1.0 : 0.0)
            
        } // VStack
    }
    @ViewBuilder
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
                    .foregroundColor(logInVM.createAccountFase != .fase1 ? .green :
                                        logInVM.createAccountFase == .fase1 &&
                                     inputLogIn.createAccountShowContents ? .yellow : .white)
                    .scaleEffect(logInVM.createAccountFase == .fase1 && inputLogIn.createAccountShowContents ? 1.5 : 1.0)
                    .overlay(alignment: .top) {
                        Text("Check!")
                            .font(.caption2).foregroundColor(.white.opacity(0.5))
                            .frame(width: 50)
                            .opacity(logInVM.createAccountFase == .fase1 && inputLogIn.createAccountShowContents ? 1.0 : 0.0)
                            .offset(y: -20)
                    }
            }
        
            .overlay {
                Circle().frame(width: 12, height: 12)
                    .foregroundColor(logInVM.createAccountFase != .fase1 &&
                                     logInVM.createAccountFase != .fase2 ? .green :
                                     logInVM.createAccountFase == .fase2 &&
                                     inputLogIn.createAccountShowContents ? .yellow : .white)
                    .scaleEffect(logInVM.createAccountFase == .fase2 && inputLogIn.createAccountShowContents ? 1.5 : 1.0)
                    .overlay(alignment: .top) {
                        Text("Check!")
                            .font(.caption2).foregroundColor(.white.opacity(0.5))
                            .frame(width: 50)
                            .opacity(logInVM.createAccountFase == .fase2 && inputLogIn.createAccountShowContents ? 1.0 : 0.0)
                            .offset(y: -20)
                    }
            }
        
            .overlay(alignment: .trailing) {
                Circle().frame(width: 12, height: 12)
                    .foregroundColor(logInVM.createAccountFase != .fase1 &&
                                     logInVM.createAccountFase != .fase2 &&
                                     logInVM.createAccountFase != .fase3 ? .green :
                                        logInVM.createAccountFase == .fase3 &&
                                     inputLogIn.createAccountShowContents ? .yellow : .white)
                    .scaleEffect(logInVM.createAccountFase == .fase3 && inputLogIn.createAccountShowContents ? 1.5 : 1.0)
                    .overlay(alignment: .top) {
                        Text("Check!")
                            .font(.caption2).foregroundColor(.white.opacity(0.5))
                            .frame(width: 50)
                            .opacity(logInVM.createAccountFase == .fase3 && inputLogIn.createAccountShowContents ? 1.0 : 0.0)
                            .offset(y: -20)
                    }
            }
    }
    
} // View

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
            .environmentObject(BackgroundViewModel())
    }
}
