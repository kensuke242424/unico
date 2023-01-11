//
//  LogInViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/21.
//

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
    }

    @Published var rootNavigation: RootNavigation = .logIn

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var uid: String? {
        return Auth.auth().currentUser?.uid
    }

    // sign in with Appleにてサインイン時に生成されるランダム文字列「ノンス」
    fileprivate var currentNonce: String?

    var logInErrorMessage: String = ""

    var isShowLogInErrorAlert: Bool = false
    var logInErrorAlertMessage: String = ""

    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        // sha256 ⇨ 256文字のハッシュ関数を生成し暗号化。サインイン認証時に照らし合わせる
        // 元となる文字列の文字数に関係なく256文字が生成される。この値はサインイン処理のたびに異なる値を照らし合わせる。
        request.nonce = sha256(nonce)
    }

    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let failure) = result {
            logInErrorAlertMessage = failure.localizedDescription
            isShowLogInErrorAlert.toggle()
        }
        else if case .success(let success) = result {
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
                         _ = try await Auth.auth().signIn(with: credential)
                    } catch {
                        print("Error authenticating: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
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

    func signIn(email: String, password: String) async -> Bool {

        logInErrorMessage = ""

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let uid = result.user.uid
            print("signIn成功_uid：\(uid)")
            return true
        } catch {
             let errorCode = AuthErrorCode.Code(rawValue: error._code)
            switch errorCode {
            case .invalidEmail: logInErrorMessage = "メールアドレスの形式が正しくありません"
            case .wrongPassword: logInErrorMessage = "入力したパスワードでサインインできません"
            case .emailAlreadyInUse: logInErrorMessage = "このメールアドレスは既に登録されています"
            case .weakPassword: logInErrorMessage = "パスワードは６文字以上で入力してください"
            case .userNotFound: logInErrorMessage = "入力情報のユーザは見つかりませんでした"
            case .userDisabled: logInErrorMessage = "このアカウントは無効です"
            default: logInErrorMessage = "予期せぬエラーが発生しました。"
            }
            return false
        }
    }

    func signUp(email: String, password: String) async -> Bool {

        logInErrorMessage = ""

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            print("signUp成功_uid：\(uid)")
            return true
        } catch {
            let errorCode = AuthErrorCode.Code(rawValue: error._code)

            switch errorCode {
            case .invalidEmail: logInErrorMessage = "メールアドレスの形式が正しくありません"
            case .emailAlreadyInUse: logInErrorMessage = "このメールアドレスは既に登録されています"
            case .weakPassword: logInErrorMessage = "パスワードは６文字以上で入力してください"
            case .userNotFound: logInErrorMessage = "入力情報のユーザは見つかりませんでした"
            case .userDisabled: logInErrorMessage = "このアカウントは無効です"
            default: logInErrorMessage = "予期せぬエラーが発生しました。"
            }
            return false
        }
    }

    func passwordUpdate(email: String) {

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            if error ==  nil {
                print("パスワード変更メール送信完了")
            } else {
                print("パスワード変更メール送信失敗")
                self.logInErrorMessage = "パスワード変更メール送信失敗"
            }
        }
    }

    func addUser(userData: User) async -> Bool {

        print("addUser実行")

        guard let usersRef = db?.collection("users") else {
            print("error: guard let itemsRef = db?.collection(users), let uid = Auth.auth().currentUser?.uid")
            return false
        }
        do {
            // currentUserのuidとドキュメントIDを同じにして保存
            _ = try usersRef.document(userData.id).setData(from: userData)
        } catch {
            print("Error: try db!.collection(collectionID).addDocument(from: itemData)")
            return false
        }
        print("addUser完了")
        return true
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
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
}
