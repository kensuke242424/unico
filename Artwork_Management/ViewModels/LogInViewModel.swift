//
//  LogInViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/21.
//

import Foundation
import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

class LogInViewModel: ObservableObject {

    init() {
        print("<<<<<<<<<  LogInViewModel_init  >>>>>>>>>")
        self.startCurrentUserListener()
    }

    /// LogInViewから次の画面へのナビゲーションを総括管理するプロパティ
    @Published var rootNavigation: RootNavigation = .logIn
    
    enum HandleUseReceivedEmailLink {
        case signIn, signUp, entryAccount, updateEmail, deleteAccount
    }
    // メールリンクによって受け取ったユーザリンクをどのように扱うかをハンドルするプロパティ
    @Published var handleUseReceivedEmailLink: HandleUseReceivedEmailLink = .signIn
    
    /// リスナーによってサインインが検知されたらトグルするプロパティ
    @Published var signedInOrNotResult: Bool = false
    
    /// メールアドレス入力用のハーフシートを管理するプロパティ
    @Published var showEmailHalfSheet: Bool = false
    @Published var showEmailSheetBackground: Bool = false
    
    /// LogInView内でのエラーアラートとメッセージを管理するプロパティ
    @Published var isShowLogInFlowAlert: Bool = false
    @Published var logInAlertMessage: LogInAlert = .start
    
    /// LogInViewでのサインイン操作フローを管理するプロパティ
    @Published var userSelectedSignInType  : UserSelectedSignInType = .start
    @Published var createAccountFase       : CreateAccountFase = .start
    @Published var selectProviderType      : SelectProviderType = .start
    @Published var addressSignInFase       : AddressSignInFase = .start
    @Published var resultSignInType        : ResultSignInType = .signIn
    
    // 匿名アカウントから永久アカウントへの認証結果を管理するプロパティ
    @Published var resultAccountLink   : Bool = false
    @Published var showAccountLinkAlert: Bool = false
    
    // アカウントのメールアドレス設定関連の操作フローを管理するプロパティ
    @Published var defaultEmailCheckFase: DefaultEmailCheckFase = .start
    @Published var updateEmailCheckFase: UpdateEmailCheckFase = .success
    @Published var deleteAccountCheckFase: DeleteAccountCheckFase = .start
    @Published var addressReauthenticateResult: Bool = false

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var listenerHandle: AuthStateDidChangeListenerHandle?
    var uid: String? {
        return Auth.auth().currentUser?.uid
    }

    // sign in with Appleにてサインイン時に生成されるランダム文字列「ノンス」
    fileprivate var currentNonce: String?
    
    func startCurrentUserListener() {
        print("startCurrentUserListenerが実行されました")
        
        listenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                print("signedInOrNot_サインイン⭕️")
                print("uid: \(self.uid ?? "アンラップ失敗")")
                self.signedInOrNotResult = true
                print("checkCurrentUserExists: \(self.signedInOrNotResult)")
                
            } else {
                print("signedInOrNot_サインイン❌")
                print("uid: \(self.uid ?? "nil")")
                self.signedInOrNotResult = false
            }
        }
    }
    
    func signInAnonymously() {
        
        print("＝＝＝＝＝signInAnonymouslyメソッド実行＝＝＝＝＝＝")
        
        Auth.auth().signInAnonymously { (authResult, error) in
            
            if let error = error {
                print(error.localizedDescription)
                print("匿名サインインに失敗しました")
                self.isShowLogInFlowAlert.toggle()
                return
            }
            if let user = authResult?.user {
                print("匿名サインインに成功しました")
                print("isAnonymousSignIn: \(user.isAnonymous)")
            }
        }
    }
    
    func entryAccountByEmailLink(email: String, link: String) {
        
        let credential = EmailAuthProvider.credential(withEmail: email, link: link)
        
        Auth.auth().currentUser?.link(with: credential) { authData, error in
            if let error {
                // And error occurred during linking.
                print("アカウントリンク時にエラー発生")
                self.resultAccountLink = false
                self.showAccountLinkAlert.toggle()
                return
            }
            // The provider was successfully linked.
            // The phone user can now sign in with their phone number or email.
            print("アカウントリンク成功")
            self.resultAccountLink = true
            self.showAccountLinkAlert.toggle()
        }
    }
    
    func verifyInputEmailMatchesCurrent(email: String) async -> Bool {
        guard let user = Auth.auth().currentUser else  { return false }
        if user.email == email {
            return true
        } else  {
            return false
        }
    }
    
    func existEmailCheckAndSendMailLink(_ email: String) {
        
        /// 受け取ったメールアドレスを使って、Auth内から既存アカウントの有無を調べる
        Auth.auth().fetchSignInMethods(forEmail: email) { (providers, error) in
            
            if let error = error {
                // メソッドの実行結果がerrorだった場合の処理
                print("ERROR: checkExistsEmailLogInUser: \(error.localizedDescription)")
                self.logInAlertMessage = .other
                self.isShowLogInFlowAlert.toggle()
                
                hapticErrorNotification()
                withAnimation(.spring(response: 0.3)) {
                    self.addressSignInFase = .failure
                }
                return
            }
            /// Authの判定後、ユーザが選択したサインインタイプによってさらに処理がスイッチ分岐する
            if let providers = providers, providers.count > 0 {
                // アカウントが既に存在していた場合の処理
                switch self.userSelectedSignInType {
                    
                case .start :
                    print("処理なし")
                    
                case .logIn :
                    self.sendEmailLink(email: email)
                    
                case .signUp:
                    // アカウントが既に存在することをアラートで伝えて、既存データへのログインを促す
                    self.logInAlertMessage = .existEmailAddressAccount
                    self.isShowLogInFlowAlert.toggle()
                    
                    hapticErrorNotification()
                }
                
            } else {
                // アカウントが存在しなかった場合の処理
                switch self.userSelectedSignInType {
                    
                case .start :
                    print("処理なし")
                    
                case .logIn :
                    // アカウントが存在しないことをアラートで伝えて、ユーザ登録を促す
                    self.logInAlertMessage = .notExistEmailAddressAccount
                    self.isShowLogInFlowAlert.toggle()
                    
                    withAnimation(.spring(response: 0.3)) {
                        self.addressSignInFase = .notExist
                    }
                    hapticErrorNotification()

                case .signUp:
                    self.sendEmailLink(email: email)
                    
                }
            }
        }
    }
    
    func existUserDocumentCheck() async throws {
        print("checkExistsUserDocumentメソッド実行")
        guard let uid = uid else { throw CustomError.uidEmpty }
        if let doc = db?.collection("users").document(uid) {
            
            print(doc)
            do {
                let document = try await doc.getDocument(source: .default)
                let user = try document.data(as: User.self)
                print("このアカウントには既に作成しているuserドキュメントが存在します")
                print("userデータ: \(user)")
                self.logInAlertMessage = .existsUserDocument
                self.isShowLogInFlowAlert.toggle()
                throw CustomError.existUserDocument
            } catch {
                print("このアカウントに既存userDocumentデータはありません。")
            }
        } else {
            print("サインインユーザーに作成しているuserドキュメントは存在しませんでした")
        }
    }

    func setNewUserDocument(name     : String,
                               password : String?,
                               imageData: (url: URL?, filePath: String?),
                               color: MemberColor) async throws {

        print("setSignUpUserDocument実行")

        guard let usersRef = db?.collection("users") else {
            print("ERROR: guard let itemsRef = db?.collection(users), let uid = Auth.auth().currentUser?.uid")
            throw CustomError.getRef
        }

        guard let currentUser = Auth.auth().currentUser else {
            print("ERROR: guard let currentUser")
            throw CustomError.uidEmpty
        }
        let newUserData = User(id: currentUser.uid,
                               name: name,
                               address: currentUser.email,
                               password: password,
                               iconURL: imageData.url,
                               iconPath: imageData.filePath,
                               userColor: color,
                               joins: [])
        do {
            // currentUserのuidとドキュメントIDを同じにして保存
            _ = try usersRef.document(newUserData.id).setData(from: newUserData)

        } catch {
            print("ERROR: try usersRef.document(newUserData.id).setData(from: newUserData)")
            throw CustomError.setData
        }
    }
    
    // ダイナミックリンクによってメールアドレス認証でのサインインをするため、ユーザにメールを送信するメソッド
    func sendEmailLink(email: String) {
        
        withAnimation(.easeInOut(duration: 0.3)) {
            self.addressSignInFase = .check
        }
        
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://unicoaddress.page.link/open")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        actionCodeSettings.setAndroidPackageName("com.example.android",
                                                 installIfNotAvailable: false, minimumVersion: "12")
        
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
            if let error = error {
                print("Failed to send sign in link: \(error.localizedDescription)")
                hapticErrorNotification()
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.addressSignInFase = .failure
                }
                return
            }
            print("Sign in link sent successfully.")
            hapticSuccessNotification()
            
            // TODO: ⬇︎の処理まだできてない。どうやってリンク側のアドレスを取得するかまだわかってない。
            // リンクから再度アプリに戻ってきた後の処理で、リンクから飛んできたアドレスと保存アドレスの差分がないかチェック
            UserDefaults.standard.set(email, forKey: "Email")
            
            withAnimation(.easeInOut(duration: 0.7)) {
                self.addressSignInFase = .success
            }
        }
    }
    
    func signInEmailLink(email: String, link: String) {
        Auth.auth().signIn(withEmail: email, link: link)
        { authResult, error in
            if let error {
                print("ログインエラー：", error.localizedDescription)
                //リンクメールの有効期限が切れていた時、ここに処理が走るみたい。
                self.isShowLogInFlowAlert.toggle()
                self.logInAlertMessage = .invalidLink
                return
            }
            // メールリンクからのサインイン成功時の処理
            if let authResult {
                print("メールリンクからのログイン成功")
                print("currentUser: \(Auth.auth().currentUser)")
            }
        }
    }
    
    func updateEmailAddress(email: String) {
        Auth.auth().currentUser?.updateEmail(to: email) { error in
            if let error {
                print(error.localizedDescription)
                hapticErrorNotification()
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.updateEmailCheckFase = .failure
                }
            } else {
                print("メールアドレスの更新に成功しました")
                hapticSuccessNotification()
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.updateEmailCheckFase = .success
                }
            }
        }
    }
    
    /// メールリンクからcredentialを作成してアカウント再認証を行う。
    /// 再認証に成功したら、handleUseReceivedEmailLinkの状態によって適切な処理を行う
    func addressReauthenticateByEmailLink(email: String, link: String) {
        guard let user = Auth.auth().currentUser else { return }
        let credential = EmailAuthProvider.credential(withEmail:email, link:link)

        // アカウントの再認証が成功したら新規メールアドレス入力画面へ移動する
        user.reauthenticate(with: credential) { authData, error in
            if let error = error {
                print("アカウント再認証失敗: \(error.localizedDescription)")
                self.defaultEmailCheckFase = .failure
            } else {
                
                switch self.handleUseReceivedEmailLink {
                case .signIn: print("handleUseReceivedEmailLink_処理なし")
                case .signUp: print("handleUseReceivedEmailLink_処理なし")
                case .updateEmail:
                    self.addressReauthenticateResult = true
                case .entryAccount:
                    self.entryAccountByEmailLink(email: email, link: link)
                case .deleteAccount:
                    self.deleteAccountWithEmailLink(email: email, link: link)
                }
                
            }
        }
    }

    func uploadImage(_ image: UIImage?) async -> (url: URL?, filePath: String?) {

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "images/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        } catch {
            return (url: nil, filePath: nil)
        }
    }
    
    func resizeUIImage(image: UIImage?, width: CGFloat) -> UIImage? {
        
        if let originalImage = image {
            // オリジナル画像のサイズからアスペクト比を計算
            let aspectScale = originalImage.size.height / originalImage.size.width
            
            // widthからアスペクト比を元にリサイズ後のサイズを取得
            let resizedSize = CGSize(width: width * 3, height: width * Double(aspectScale) * 3)
            
            // リサイズ後のUIImageを生成して返却
            UIGraphicsBeginImageContext(resizedSize)
            originalImage.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return resizedImage
        } else {
            return nil
        }
    }

    func deleteImage(path: String) async {

        let storage = Storage.storage()
        let reference = storage.reference()
        let imageRef = reference.child(path)

        imageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                print("imageRef.delete succsess!")
            }
        }
    }

    func generateUserQRCode(with inputText: String) -> UIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        else { return nil }

        let inputData = inputText.data(using: .utf8)
        qrFilter.setValue(inputData, forKey: "inputMessage")
        // 誤り訂正レベルをHに指定
        // 誤り訂正レベルとは: 生成時に崩れたQRコードを自力で修正する機能のレベル。レベルが高いほどデータは重くなる
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")

        guard let ciImage = qrFilter.outputImage
        else { return nil }

        // CIImageは小さい為、任意のサイズに拡大
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciImage.transformed(by: sizeTransform)

        let context = CIContext()
        // CIImageだとSwiftUIのImageでは表示されない為、CGImageに変換
        guard let cgImage = context.createCGImage(scaledCIImage,
                                                  from: scaledCIImage.extent)
        else { return nil }

        return UIImage(cgImage: cgImage)
    }
    
    func shareApp(){
        let productURL:URL = URL(string: "https://apps.apple.com/us/app/unico/id1663765686")!
        
        let activityViewController = UIActivityViewController(
            activityItems: [productURL],
            applicationActivities: nil)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        if let window {
            window.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func reviewApp(){
            let productURL:URL = URL(string: "https://apps.apple.com/us/app/unico/id1663765686")!
            
            var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)
            
            components?.queryItems = [
                URLQueryItem(name: "action", value: "write-review")
            ]
            
            guard let writeReviewURL = components?.url else {
                return
            }
            
            UIApplication.shared.open(writeReviewURL)
        }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            print("ログアウト成功")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            print("ログアウト失敗")
        }
    }
    
    func deleteAccountWithEmailLink(email: String, link: String) {
        let credential = EmailAuthProvider.credential(withEmail:email, link:link)
        guard let user = Auth.auth().currentUser else { return }
        user.reauthenticate(with: credential) { authData, error in
            if let error {
                print("アカウント再認証失敗: \(error.localizedDescription)")
                self.defaultEmailCheckFase = .failure
                return
            }
            // ユーザーの再認証成功。アカウント削除処理実行
            user.delete { error in
                if let error = error {
                    print("アカウント削除失敗: \(error.localizedDescription)")
                    self.defaultEmailCheckFase = .failure
                } else {
                    // Account deleted.
                    print("アカウント削除完了")
                    self.defaultEmailCheckFase = .success
                }
            }
        }
    }
    
    // サインイン要求で nonce の SHA256 ハッシュを送信すると、Apple はそれを応答で変更せずに渡します。
    // Firebase は、元のノンスをハッシュし、それを Apple から渡された値と比較することで、応答を検証します。
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    // MARK: - Sign in with Appleはまだ実装できていない⬇︎
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        // sha256 ⇨ 256文字のハッシュ関数を生成し暗号化。サインイン認証時に照らし合わせる
        // 元となる文字列の文字数に関係なく256文字が生成される。この値はサインイン処理のたびに異なる値を照らし合わせる。
        request.nonce = sha256(nonce)
    }
    
    @MainActor
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let failure) = result {
            print(failure.localizedDescription)
        }
        else if case .success(let success) = result {
            // ASAuthorizationAppleIDCredential: AppleID認証が成功した結果として得られる資格情報。
            if let appleIDCredential = success.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("fatalError: handleSignInWithAppleCompletion_currentNonceの値が存在しません。")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identify token。識別トークンをフェッチできません。")
                    return
                }
                guard let authorizationCode = appleIDCredential.authorizationCode else {
                    print("Unable to fetch authorizationCode。")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialise token string from data: \(appleIDToken.debugDescription). データからトークン文字列をシリアライズできません。")
                    return
                }
                
                print("＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
                print("appleIDToken: \(appleIDToken)")
                print("authorizationCode: \(authorizationCode)")
                print("＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")

                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                Task {
                    do {
                         _ = try await Auth.auth().signIn(with: credential)
                        print("Sign In With Appleからのアカウント登録完了")
                    } catch {
                        print("Error authenticating: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    // --- 🔥アップルサインインアカウントのサインアウト&AppleID連携解除のメソッド🔥  ---
    func signOutAndDeleteAccount(credencial:  ASAuthorizationAppleIDCredential?) {
      // Firebase Authenticationからサインアウトする
      do {
        try Auth.auth().signOut()
      } catch let signOutError as NSError {
        print("Error signing out: %@", signOutError)
        return
      }

      // Apple ID の identityToken と authorizationCode を取得する
        guard let appleIDCredential = credencial else {
        return
      }

      let identityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)!
      let authorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)!

      // identityTokenとauthorizationCodeを使用して、Apple IDとの連携を解除する
      // （例えば、先ほど紹介したREST APIを呼び出すなど）
      deleteAccountFromServer(identityToken: identityToken, authorizationCode: authorizationCode)
    }
    // アップルサインインデータを削除するために必要な「appleIDToken」「authorizationCode」を保持するASAuthorizationAppleIDCredentialを取得するメソッド
    // TODO: Sign in with Appleはまだ実装できていない。
    func getSignOutWithAppleCredential(_ result: Result<ASAuthorization, Error>) ->  ASAuthorizationAppleIDCredential? {
        
        print("getSignOutWithAppleCredentialメソッド実行")
        
        // 以下のプロパティ値を返す
        var credential: ASAuthorizationAppleIDCredential?
        
        if case .failure(let failure) = result {
            print(failure.localizedDescription)
        }
        else if case .success(let success) = result {
            // ASAuthorizationAppleIDCredential: AppleID認証が成功した結果として得られる資格情報。
            if let appleIDCredential = success.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("fatalError: handleSignInWithAppleCompletion_currentNonceの値が存在しません。")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identify token。識別トークンをフェッチできません。")
                    return nil
                }
                guard let authorizationCode = appleIDCredential.authorizationCode else {
                    print("Unable to fetch authorizationCode。")
                    return nil
                }
                
                print("＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
                print("appleIDToken: \(appleIDToken)")
                print("authorizationCode: \(authorizationCode)")
                print("＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
                credential = appleIDCredential
            }
        }
        return credential
    }
    
    func deleteAccountFromServer(identityToken: String, authorizationCode: String) {
        // 認証用の秘密鍵の読み込み
        guard let filePath = Bundle.main.path(forResource: "AuthKey_MWXRWWC3VP", ofType: "p8") else {
            print("秘密鍵が見つかりません")
            return
        }
        print("filePath: \(filePath)")
        
        let fileURL = URL(fileURLWithPath: filePath)
        guard let privateKey = try? String(contentsOf: fileURL).trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("秘密鍵の読み込みに失敗しました")
            return
        }
        print("fileURL: \(fileURL)")
        print("privateKey: \(privateKey)")

        // HTTPリクエストの作成
        let url = URL(string: "https://appleid.apple.com/auth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // HTTPリクエストのボディに必要な情報を設定
        let requestBody = "client_id=com.example.app&client_secret=\(privateKey)&code=\(authorizationCode)&grant_type=authorization_code&redirect_uri=https://example.com/callback"
        request.httpBody = requestBody.data(using: .utf8)
        print("requestBody: \(requestBody)")

        // HTTPリクエストの送信
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("HTTPリクエストの送信に失敗しました：\(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("HTTPレスポンスがありません")
                return
            }
            print("HTTPレスポンスdata: \(data)")
            
            // TODO: 一つずつチェック
            guard let responseJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("responseJsonの取得に失敗")
                return
            }
            print("responceJson: \(responseJson)") // ✅
            
            guard let identityToken_ = responseJson["id_token"] as? String else {
                print("identityTokenの取得に失敗")
                return
            }
            guard let refreshToken_ = responseJson["refresh_token"] as? String else {
                print("refreshToken取得に失敗")
                return
            }

            // HTTPレスポンスからトークンを取得
//            guard let responseJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                  let identityToken = responseJson["id_token"] as? String,
//                  let refreshToken = responseJson["refresh_token"] as? String else {
//                print("レスポンスJSONからトークンの取得に失敗しました")
//                return
//            }

            // identityTokenを使って、Appleからユーザー情報を取得
            // ...

            // ユーザー情報を使って、アカウントの削除処理を行う
            // ...
        }
        task.resume()
    }
    
    deinit {
        if let listenerHandle {
            Auth.auth().removeStateDidChangeListener(listenerHandle)
        }
    }
}
