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

    @Published var rootNavigation: RootNavigation = .logIn
    
    @Published var AlreadyExistsUserDocument: Bool = false
    @Published var existsCurrentUserCheck: Bool = false
    @Published var isShowLogInFlowAlert: Bool = false
    @Published var selectSignInType: SelectSignInType = .start
    @Published var selectProviderType: SelectProviderType = .start
    @Published var logInAlertMessage: LogInAlert = .start
    @Published var addressSignInFase: AddressSignInFase = .start

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var listenerHandle: AuthStateDidChangeListenerHandle?
    var uid: String? {
        return Auth.auth().currentUser?.uid
    }

    // sign in with Appleにてサインイン時に生成されるランダム文字列「ノンス」
    fileprivate var currentNonce: String?

    var logInErrorMessage: String = ""
    var logInErrorAlertMessage: String = ""
    
    func signInAnonymously() {
        
        Auth.auth().signInAnonymously { (authResult, error) in
            
            if let error = error {
                print(error.localizedDescription)
                print("AnonymousSignIn_error")
                self.isShowLogInFlowAlert.toggle()
                return
            }
            if let user = authResult?.user {
                print("\(user.displayName ?? "No displayName")")
                print("isAnonymousSignIn: \(user.isAnonymous)")
            }
        }
    }

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
            logInErrorAlertMessage = failure.localizedDescription
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
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialise token string from data: \(appleIDToken.debugDescription). データからトークン文字列をシリアライズできません。")
                    return
                }

                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                Task {
                    do {
//                        self.startCurrentUserListener()
                         _ = try await Auth.auth().signIn(with: credential)
                        print("Sign In With Appleからのアカウント登録完了")
                    } catch {
                        print("Error authenticating: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func startCurrentUserListener() {
        print("startCurrentUserListenerが実行されました")
        
        listenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                print("currentUserCheck_サインイン⭕️")
                print("uid: \(self.uid ?? "アンラップ失敗")")
                self.existsCurrentUserCheck = true
                print("checkCurrentUserExists: \(self.existsCurrentUserCheck)")
                
            } else {
                print("currentUserCheck_サインイン❌")
                print("uid: \(self.uid ?? "nil")")
                self.existsCurrentUserCheck = false
            }
        }
    }
    
    /// メールアドレスによるサインインフローを実行した時、入力アドレスからAuthの有無を調べる
    /// 存在しなければ、サインアップ操作へと移行するようアラートで知らせる
    //  TODO: メソッド名がわかりにくい気がする...
    func existEmailAccountCheck(_ email: String) {
        Auth.auth().fetchSignInMethods(forEmail: email) { (providers, error) in
            
            if let error = error {
                print("入力アドレスのアカウントが見つかりませんでした")
                print("checkExistsEmailLogInUser: \(error.localizedDescription)")
                self.logInAlertMessage = .other
                self.isShowLogInFlowAlert.toggle()
                return
            }
            
            if let providers = providers, providers.count > 0 {
                // アカウントが既に存在する場合の処理
                switch self.selectSignInType {
                    
                case .start :
                    print("処理なし")
                    
                case .logIn :
                    self.sendSignInLink(email: email)
                    
                case .signAp:
                    // アカウントが既に存在することをアラートで伝えて、既存データへのログインを促す
                    self.logInAlertMessage = .existEmailAddressAccount
                    self.isShowLogInFlowAlert.toggle()
                    
                }
                self.isShowLogInFlowAlert.toggle()
                self.logInAlertMessage = .existEmailAddressAccount
            } else {
                // アカウントが存在しない場合の処理
                
            }
        }
    }
    
    func existUserDocumentCheck() async throws -> Bool {
        print("checkExistsUserDocumentメソッド実行")
        guard let uid = uid else { throw CustomError.uidEmpty }
        if let doc = db?.collection("users").document(uid) {
            
            print(doc)
            do {
                let document = try await doc.getDocument(source: .default)
                let user = try document.data(as: User.self)
                print("このアカウントには既に作成しているuserドキュメントが存在します")
                print("userデータ: \(user)")
                return true
            } catch {
                print("このアカウントに既存userDocumentデータはありません。")
                return false
            }
        } else {
            print("サインインユーザーに作成しているuserドキュメントは存在しませんでした")
            return false
        }
    }

    func setSignUpUserDocument(name: String, password: String?, imageData: UIImage?, color: MemberColor) async -> Bool {

        print("addUserSignInWithApple実行")

        guard let usersRef = db?.collection("users") else {
            print("error: guard let itemsRef = db?.collection(users), let uid = Auth.auth().currentUser?.uid")
            return false
        }

        guard let currentUser = Auth.auth().currentUser else {
            print("Error: guard let currentUser")
            return false
        }

        let uplaodImageData = await  self.uploadImage(imageData)
        let newUserData = User(id: currentUser.uid,
                               name: name,
                               address: currentUser.email,
                               password: password,
                               iconURL: uplaodImageData.url,
                               iconPath: uplaodImageData.filePath,
                               userColor: color,
                               joins: [])
        do {
            // currentUserのuidとドキュメントIDを同じにして保存
            _ = try usersRef.document(newUserData.id).setData(from: newUserData)
            return true
        } catch {
            print("Error: try usersRef.document(newUserData.id).setData(from: newUserData)")
            return false
        }
    }
    
    // ダイナミックリンクによってメールアドレス認証でのサインインをするため、ユーザにメールを送信するメソッド
    func sendSignInLink(email: String) {
        
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
                withAnimation(.easeInOut(duration: 0.3)) { self.addressSignInFase = .failure }
                return
            }
            print("Sign in link sent successfully.") 
            hapticSuccessNotification()
            
            // TODO: ⬇︎の処理まだできてない。どうやってリンク側のアドレスを取得するかまだわかってない。
            // リンクから再度アプリに戻ってきた後の処理で、リンクから飛んできたアドレスと保存アドレスの差分がないかチェック
            UserDefaults.standard.set(email, forKey: "Email")
            
            withAnimation(.easeInOut(duration: 0.8)) {
                // 入力アドレス宛にディープリンク付きメールを送信する
                self.addressSignInFase = .success
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
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            print("ログアウト実行")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            print("ログアウト失敗")
        }
    }
    
    deinit {
        if let listenerHandle {
            Auth.auth().removeStateDidChangeListener(listenerHandle)
        }
    }
}
