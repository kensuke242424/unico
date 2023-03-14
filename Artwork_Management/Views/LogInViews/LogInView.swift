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
    case start, check, failure, notExist, success
    
    var checkIcon: Image {
        switch self {
        case .start: return Image(systemName: "")
        case .check: return Image(systemName: "")
        case .failure: return Image(systemName: "multiply.circle.fill")
        case .notExist: return Image(systemName: "multiply.circle.fill")
        case .success: return Image(systemName: "checkmark.seal.fill")
        }
    }
    
    var humanIconBadge: Image {
        switch self {
        case .start: return Image(systemName: "")
        case .check: return Image(systemName: "")
        case .failure: return Image(systemName: "xmark.circle.fill")
        case .notExist: return Image(systemName: "xmark.circle.fill")
        case .success: return Image(systemName: "checkmark.circle.fill")
        }
    }
    
    var checkText: String {
        switch self {
        case .start: return ""
        case .check: return "check..."
        case .failure: return "failure!!"
        case .notExist: return "not Account!!"
        case .success: return "succsess!!"
        }
    }
    
    var messageText: (text1: String, text2: String) {
        switch self {
        case .start   : return ("メールアドレスに本人確認メールを送ります。"  ,
                                "届いたメールからunicoへアクセスしてください。")
            
        case .check   : return ("メールアドレスをチェックしています..."          ,
                                ""                                        )
            
        case .failure : return ("認証メールの送信に失敗しました。"              ,
                                "アドレスを確認して、再度試してみてください。"     )
            
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
    case emailImproper
    case existsUserDocument
    case existEmailAddressAccount
    case notExistEmailAddressAccount
    case other
    
    var title: String {
        switch self {
        case .start                   :
            return ""
        case .sendMailLinkUpperLimit  :
            return "送信の上限"
        case .emailImproper           :
            return "エラー"
        case .existsUserDocument      :
            return "ログイン"
        case .existEmailAddressAccount:
            return "ログイン"
        case .notExistEmailAddressAccount:
            return "アカウント無し"
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
        case .emailImproper           :
            return "アドレスの書式が正しくありません。"
        case .existsUserDocument      :
            return "あなたのアカウントには以前作成したunicoのデータが存在します。ログインしますか？"
        case .existEmailAddressAccount:
            return "入力したアドレスには以前作成したunicoデータが存在します。ログインしますか？"
        case .notExistEmailAddressAccount:
            return "入力したメールアドレスのアカウントは存在しませんでした。ユーザの新規登録をしてください。"
        case .other                   :
            return "処理に失敗しました。入力に間違いがないかチェックしてください。"
        }
    }
}

enum Background: CaseIterable {
    case original, sample1, sample2, sample3, sample4
    
    var imageName: String {
        switch self {
        case .original:
            return ""
        case .sample1:
            return "background_1"
        case .sample2:
            return "background_2"
        case .sample3:
            return "background_3"
        case .sample4:
            return "background_4"
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
    var selectUserColor         : MemberColor = .blue
    
    /// Viewの表示・非表示やアニメーションをコントロールするプロパティ
    var checkBackgroundOpacity      : CGFloat = 1.0
    var keyboardOffset              : CGFloat = 0.0
    var checkBackgroundEffect       : Bool = false
    var checkBackgroundOpacityToggle: Bool = false
    var createAccountTitle          : Bool = false
    var createAccountShowContents   : Bool = false
    var repeatAnimation             : Bool = false
    var sendAddressButtonDisabled   : Bool = true
    var selectBackground            : Background = .sample1
    
    /// ログインフローの進行を管理するプロパティ
    var createAccountFase: CreateAccountFase = .start
    
    /// Sheetやアラートなどのプレゼンテーションを管理するプロパティ
    var isShowPickerView             : Bool = false
    var isShowUserEntryRecommendation: Bool = false
    var isShowGoBackLogInAlert       : Bool = false
    var captureError                 : Bool = false
}

// ✅ ログイン画面の親Viewです。

struct LogInView: View { // swiftlint:disable:this type_body_length
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var progress: ProgressViewModel
    
    @StateObject var logInVM: LogInViewModel
    @StateObject var teamVM : TeamViewModel
    @StateObject var userVM : UserViewModel
    
    @State private var logInNavigationPath: [Navigation] = []
    @State private var inputLogIn: InputLogIn = InputLogIn()
    @State private var createFaseLineImprove: CGFloat = 0.0
    
    @FocusState private var showKyboard: ShowKyboard?
    
    var body: some View {
        
        ZStack {
            
            Group {
                if let captureImage = inputLogIn.captureUserIconImage {
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
                        .opacity(inputLogIn.checkBackgroundOpacity)
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
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .disabled(logInVM.addressSignInFase == .success ? true : false)
                    .opacity(inputLogIn.checkBackgroundOpacity)
                    .opacity(logInVM.addressSignInFase == .success ? 0.2 : 1.0)
                    .opacity(inputLogIn.createAccountFase == .fase1 && !inputLogIn.createAccountShowContents ? 0.0 : 1.0)
                    .offset(y: getRect().height / 2 - 100)
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
                    .disabled(logInVM.addressSignInFase == .success ? true : false)
                    .opacity(logInVM.addressSignInFase == .success ? 0.2 : 1.0)
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
                        Text("最初の画面に戻ります。よろしいですか？")
                    } // alert
                    
                }
                
                // メールアドレス登録選択時に出現するアドレス入力ハーフシートView
                inputAdressHalfSheet()
                
                UserEntryRecommendationView(logInVM: logInVM,
                                            isShow: $inputLogIn.isShowUserEntryRecommendation)
                .opacity(inputLogIn.isShowUserEntryRecommendation ? 1.0 : 0.0)
                .offset(y: inputLogIn.isShowUserEntryRecommendation ? 0 : getRect().height)
            }
            
        } // ZStack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                
            case .existsUserDocument         :
                Button("戻る") {
                    logInVM.signedInOrNot = false
                    logInVM.logOut()
                }
                Button("ログイン") {
                    withAnimation(.spring(response: 0.5)) {
                        logInVM.selectSignInType = .logIn
                        logInVM.rootNavigation = .fetch
                    }
                }
                
            case .existEmailAddressAccount   :
                Button("戻る") {
                    logInVM.signedInOrNot = false
                    logInVM.addressSignInFase = .start
                    logInVM.logOut()
                }
                Button("ログイン") {
                    withAnimation(.spring(response: 0.5)) {
                        logInVM.selectSignInType = .logIn
                        logInVM.rootNavigation = .fetch
                    }
                }
                
            case .notExistEmailAddressAccount:
                Button("OK") {}
                
            case .other                      :
                Button("OK") {}
                
            }
                    
        } message: {
            Text(logInVM.logInAlertMessage.text)
        }
        .sheet(isPresented: $inputLogIn.isShowPickerView) {
            // .fase1ならバックグラウンドの画像設定、.fase2ならユーザーアイコンの画像設定
            if inputLogIn.createAccountFase == .fase1 {
                PHPickerView(captureImage: $inputLogIn.captureBackgroundImage, isShowSheet: $inputLogIn.isShowPickerView, isShowError: $inputLogIn.captureError)
            } else if inputLogIn.createAccountFase == .fase2 {
                PHPickerView(captureImage: $inputLogIn.captureUserIconImage, isShowSheet: $inputLogIn.isShowPickerView, isShowError: $inputLogIn.captureError)
            }
        }
        
        .background {
            ZStack {
                GeometryReader { proxy in
                    if inputLogIn.selectBackground == .original {
                        Image(uiImage: inputLogIn.captureBackgroundImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .blur(radius: inputLogIn.checkBackgroundEffect ? 0 : 2)
                    } else {
                        Image(inputLogIn.selectBackground.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .blur(radius: inputLogIn.checkBackgroundEffect ? 0 : 2)
                    }
                    Color(.black)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .opacity(inputLogIn.checkBackgroundEffect ? 0.0 : 0.2)
                }
                .ignoresSafeArea()
            }
        }
        .onChange(of: inputLogIn.createAccountFase) { newFaseValue in
            withAnimation(.spring(response: 1.0)) {
                switch newFaseValue {
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
        .onChange(of: logInVM.signedInOrNot) { resultValue in
            
            print("logInVM.existCurrentUserCheck更新を検知")
            if !resultValue { return }
            
            switch logInVM.selectSignInType {
                
            case .start:
                print("処理なし")

            case .logIn:
                withAnimation(.spring(response: 0.5)) {
                logInVM.rootNavigation = .fetch
                }
            
            case .signAp:
                Task {
                    do {
                        /// 以前に作った既存のuserDocumentデータがあるかどうかをチェック
                        /// もし存在したら、関数内で既存データへのログインを促すアラートを発火しています
                        _ = try await logInVM.existUserDocumentCheck()
                        
                        /// ユーザーデータをFirestoreに保存⬇︎
                        _ = try await logInVM.setSignUpUserDocument(name: inputLogIn.createUserNameText,
                                                                password: inputLogIn.password,
                                                                imageData: inputLogIn.captureUserIconImage,
                                                                color: inputLogIn.selectUserColor)
                        
                        // Firestoreに保存したデータをローカルに引っ張ってくる
                        _ = try await userVM.fetchUser()
                        guard let user = userVM.user else { return }
                        
                        /// 新規チームデータの準備⬇︎
                        let createTeamID = UUID().uuidString
                        let joinMember = JoinMember(memberUID: user.id, name: user.name, iconURL: user.iconURL)
                        
                        let teamData = Team(id: createTeamID, name: "\(user.name)のチーム", members: [joinMember])
                        let joinTeamData = JoinTeam(teamID: teamData.id, name: teamData.name)
                        
                        /// 準備したチームデータをFirestoreに保存していく
                        /// userDocument側にも新規作成したチームのidを保存しておく(addNewJoinTeam)
                        try await teamVM.addTeam(teamData: teamData)
                        try await userVM.addNewJoinTeam(newJoinTeam: joinTeamData)
                        
                        withAnimation(.spring(response: 0.5)) {
                            logInVM.rootNavigation = .fetch
                        }
                    } catch {
                        print("ユーザーデータの作成に失敗しました")
                    }
                } // Task end
            }
        }
        
    } // body
    
    @ViewBuilder
    func signInTitle(title: String) -> some View {
        HStack {
            Rectangle().foregroundColor(.white.opacity(0.4)).frame(width: 60, height: 1)
            Text(title)
                .tracking(10)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal)
            Rectangle().foregroundColor(.white.opacity(0.4)).frame(width: 60, height: 1)
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
        VStack(spacing: 25) {
            
            Button {
                withAnimation(.easeIn(duration: 0.25)) {
                    logInVM.showEmailSheetBackground.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                        logInVM.showEmailHalfSheet.toggle()
                    }
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
            
            Text("または")
                .foregroundColor(.white).opacity(0.7)
                .tracking(2)

            Button {
                // お試しログイン選択時の処理
                hapticSuccessNotification()
                withAnimation(.easeInOut(duration: 0.4)) {
                    inputLogIn.isShowUserEntryRecommendation.toggle()
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
    func createAccountViews() -> some View {
        
        VStack(spacing: 50) {
            
            Group {
                switch inputLogIn.createAccountFase {
                case .start:
                    Text("")
                    
                case .fase1:
                    VStack(spacing: 10) {
                        Text("まずはあなたにぴったりの")
                        Text("デザインを決めましょう")
                    }
                    .tracking(5)
                    .offset(y: 30)
                    
                case .fase2:
                    VStack(spacing: 10) {
                        Text("unicoへようこそ")
                            .tracking(10)
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
            .font(.subheadline).foregroundColor(.white.opacity(0.8))
            .opacity(inputLogIn.checkBackgroundOpacity)
            .opacity(inputLogIn.createAccountTitle ? 1.0 : 0.0)
            
            Group {
                switch inputLogIn.createAccountFase {
                    
                case .start: Text("")
                    
                // Fase1: 背景写真を選んでもらう
                case .fase1:
                    
                    VStack(spacing: 30) {
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 30) {
                                ForEach(Background.allCases, id: \.self) { value in
                                    Group {
                                        if value == .original {
                                            Image(uiImage: inputLogIn.captureBackgroundImage ?? UIImage())
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 250)
                                                .border(.blue, width: 1)
                                                .overlay {
                                                    Button("写真を挿入") {
                                                        inputLogIn.isShowPickerView.toggle()
                                                    }
                                                    .buttonStyle(.borderedProminent)
                                                    
                                                }
                                        } else {
                                            Image(value.imageName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 250)
                                        }
                                    }
                                    .clipped()
                                    .scaleEffect(inputLogIn.selectBackground == value ? 1.2 : 1.0)
                                    .overlay(alignment: .topTrailing) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.green)
                                            .frame(width: 30, height: 30)
                                            .scaleEffect(inputLogIn.selectBackground == value ? 1.0 : 1.2)
                                            .opacity(inputLogIn.selectBackground == value ? 1.0 : 0.0)
                                            .offset(x: 20, y: -30)
                                    }
                                    .padding(.leading, value == .original ? 40 : 0)
                                    .padding(.trailing, value == .sample4 ? 40 : 0)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.5)) {
                                            inputLogIn.selectBackground = value
                                        }
                                    }
                                }
                            }
                            .frame(height: 310)
                        }
                    } // VStack
                    .opacity(inputLogIn.checkBackgroundOpacity)
                    .offset(y: 20)
                    
                    Button("次へ") {
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
                    }
                    .buttonStyle(.borderedProminent)
                    .opacity(inputLogIn.checkBackgroundOpacity)
                    .overlay(alignment: .trailing) {
                        VStack {
                            Text("確認する").font(.footnote).offset(x: 15)
                            Toggle("", isOn: $inputLogIn.checkBackgroundOpacityToggle)
                        }
                        .frame(width: 80)
                        .offset(x: 130)
                        .onChange(of: inputLogIn.checkBackgroundOpacityToggle) { newValue in
                            if newValue {
                                withAnimation(.easeIn(duration: 0.2)) { inputLogIn.checkBackgroundOpacity = 0.0 }
                                withAnimation(.easeIn(duration: 0.2)) { inputLogIn.checkBackgroundEffect.toggle() }
                            } else {
                                withAnimation(.easeIn(duration: 0.2)) { inputLogIn.checkBackgroundOpacity = 1.0 }
                                withAnimation(.easeIn(duration: 0.2)) { inputLogIn.checkBackgroundEffect.toggle() }
                            }
                        }
                    }
                    .offset(y: 20)
                    
                case .fase2:
                    
                    Group {
                        if let captureImage = inputLogIn.captureUserIconImage {
                            UIImageCircleIcon(photoImage: captureImage, size: 150)
                        } else {
                            Image(systemName: "photo.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150)
                                .foregroundColor(.white)
                        }
                    }
                    .onTapGesture { inputLogIn.isShowPickerView.toggle() }
                    .overlay(alignment: .top) {
                        Text("ユーザ情報は後から変更できます。").font(.caption)
                            .foregroundColor(.white.opacity(0.5))
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
                                    .foregroundColor(.white.opacity(0.4))
                                Rectangle().foregroundColor(.white.opacity(0.7)).frame(height: 1)
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
                                    logInVM.showEmailHalfSheet.toggle()
                                    showKyboard = nil
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    logInVM.showEmailSheetBackground.toggle()
                                    logInVM.addressSignInFase = .start
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
                            .disabled(logInVM.addressSignInFase == .check ? true : false)
                            .opacity(logInVM.addressSignInFase == .check ? 0.3 : 1.0)
                        }
                        .padding([.horizontal, .top], 20)
                        .padding(.bottom, 10)
                        
                        HStack(spacing: 10) {
                            if logInVM.addressSignInFase == .check {
                                ProgressView()
                            } else {
                                logInVM.addressSignInFase.checkIcon
                                    .foregroundColor(
                                        logInVM.addressSignInFase == .failure ||
                                        logInVM.addressSignInFase == .notExist ? .red : .green)
                            }
                            Text(logInVM.addressSignInFase.checkText)
                                .tracking(5)
                                .opacity(0.5)
                                .fontWeight(.semibold)
                        }
                        .frame(width: 300, height: 30)
                        .opacity(logInVM.addressSignInFase != .start ? 1.0 : 0.0)
                        
                        HStack(spacing: 35) {
                            
                            Image(systemName: "envelope.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                                .scaleEffect(logInVM.addressSignInFase == .check ? 1.0 :
                                                logInVM.addressSignInFase == .success ? 1.4 :
                                                1.0)
                                .opacity(logInVM.addressSignInFase == .check ? 0.8 :
                                            logInVM.addressSignInFase == .failure ||
                                            logInVM.addressSignInFase == .notExist ? 0.8 :
                                            logInVM.addressSignInFase == .success ? 1.0 :
                                            0.8)
                                .overlay(alignment: .topTrailing) {
                                    Image(systemName: "questionmark")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .opacity(logInVM.addressSignInFase == .failure ||
                                                 logInVM.addressSignInFase == .notExist ? 0.5 : 0.0)
                                        .offset(x: 15, y: -15)
                                }
                            
                            if logInVM.addressSignInFase != .success {
                                Image(systemName: "arrowshape.turn.up.right.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .opacity(logInVM.addressSignInFase == .check ? 1.0 :
                                                logInVM.addressSignInFase == .failure ||
                                                logInVM.addressSignInFase == .notExist ? 0.2 :
                                                0.4)
                                    .scaleEffect(inputLogIn.repeatAnimation ? 1.3 : 1.0)
                                    .animation(.default.repeat(while: inputLogIn.repeatAnimation),
                                               value: inputLogIn.repeatAnimation)
                            }
                            
                            if logInVM.addressSignInFase != .success {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                    .opacity(logInVM.addressSignInFase == .check ? 0.4 :
                                                logInVM.addressSignInFase == .failure ||
                                                logInVM.addressSignInFase == .notExist ? 0.2 :
                                                0.8)
                                    .scaleEffect(logInVM.addressSignInFase == .check ? 0.8 : 1.0)
                            }
                        }
                        .frame(height: 60)
                        .padding(.bottom)
                        // リピートスケールアニメーションの発火トリガー(アドレス入力の.check時に使用)
                        .onChange(of: logInVM.addressSignInFase) { newValue in
                            if newValue == .check {
                                inputLogIn.repeatAnimation = true
                            } else {
                                inputLogIn.repeatAnimation = false
                            }
                        }
                        
                        VStack(spacing: 5) {
                            Text(logInVM.addressSignInFase.messageText.text1)
                            Text(logInVM.addressSignInFase.messageText.text2)
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
                        Button(logInVM.addressSignInFase == .start || logInVM.addressSignInFase == .check ? "メールを送信" : "もう一度送る") {
                            
                            withAnimation(.spring(response: 0.3)) {
                                logInVM.addressSignInFase = .check
                            }
                            
                            switch logInVM.selectSignInType {
                                
                            case .start :
                                print("処理なし")
                                
                            case .logIn :
                                logInVM.existEmailAccountCheck(inputLogIn.address)
                                
                            case .signAp:
                                logInVM.existEmailAccountCheck(inputLogIn.address)
                                
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(inputLogIn.sendAddressButtonDisabled)
                        .opacity(logInVM.addressSignInFase == .check ? 0.3 : 1.0)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                }
        }
        .offset(y: logInVM.showEmailHalfSheet ? 0 : getRect().height / 2)
        .offset(y: inputLogIn.keyboardOffset)
        .onChange(of: showKyboard) { newValue in
            if newValue == .check {
                withAnimation(.spring(response: 0.4)) {
                    inputLogIn.keyboardOffset = -UIScreen.main.bounds.height / 3
                }
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    inputLogIn.keyboardOffset = 0
                }
            }
        }
        
        .background {
            Color.black.opacity(logInVM.showEmailSheetBackground ? 0.7 : 0.0)
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
                    .foregroundColor(inputLogIn.createAccountFase != .fase1 ? .green :
                                     inputLogIn.createAccountFase == .fase1 &&
                                     inputLogIn.createAccountShowContents ? .yellow : .white)
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
                                     inputLogIn.createAccountFase != .fase2 ? .green :
                                     inputLogIn.createAccountFase == .fase2 &&
                                     inputLogIn.createAccountShowContents ? .yellow : .white)
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
                                     inputLogIn.createAccountFase != .fase3 ? .green :
                                     inputLogIn.createAccountFase == .fase3 &&
                                     inputLogIn.createAccountShowContents ? .yellow : .white)
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
        LogInView(logInVM: LogInViewModel(), teamVM: TeamViewModel(), userVM: UserViewModel())
    }
}
