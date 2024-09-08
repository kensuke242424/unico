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

/// メールリンクの使用用途を管理する列挙型。
enum HandleUseReceivedEmailLink {
    /// サインイン時に用いられるケース
    case signIn
    /// 初期画面からの新規登録時に用いられるケース
    case signUp // 新規登録
    /// 匿名ユーザーからのアカウント登録で用いられるケース
    case entryAccount
    /// メールアドレス更新で用いられるケース
    case updateEmail
    /// アカウント削除時に用いられるケース
    case deleteAccount
}

class AuthViewModel: ObservableObject {

    init() {
        self.startCurrentUserListener()
    }

    /// LogInViewから次の画面へのナビゲーションを総括管理するプロパティ
    @Published var rootNavigation: RootNavigation = .logIn

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
    @Published var addressReAuthenticateResult: Bool = false

    // アカウント削除時に必要な値
    // リンクからの再認証が成功した後、ユーザーに最終確認を行うため、
    // 再認証によって受け取った値を保持しておく
    var receivedAddressByLink: String = ""
    var receivedLink: String = ""

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    var listenerHandle: AuthStateDidChangeListenerHandle?
    var uid: String? { Auth.auth().currentUser?.uid }
    var isAnonymous: Bool {
        if let user = Auth.auth().currentUser, user.isAnonymous {
            return true
        } else {
            return false
        }
    }

    // sign in with Appleにてサインイン時に生成されるランダム文字列「ノンス」
    fileprivate var currentNonce: String?

    func startCurrentUserListener() {
        listenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                Logger.i("uid: \(self.uid ?? "nil")")
                self.signedInOrNotResult = true
            } else {
                Logger.i("uid: \(self.uid ?? "nil")")
                self.signedInOrNotResult = false
            }
        }
    }

    /// ユーザーを匿名アカウントとして登録するメソッド。
    func signUpAnonymously() {
        Auth.auth().signInAnonymously { (authResult, error) in
            if let error = error {
                self.isShowLogInFlowAlert.toggle()
                return
            }
            if let user = authResult?.user {
                Logger.i("signIn user id: \(user.uid)")
                Logger.i("isAnnonimous: \(user.isAnonymous)")
            }
        }
    }
    /// メールリンクを経由してFirebaseAuthへアクセスし、匿名アカウント->会員登録アカウントへ更新するメソッド。
    /// 登録に成功した場合、データをすべて引き継いで登録済みアカウントとなる。
    /// - Parameters:
    ///   - email: ユーザーが自身の登録情報として入力したメールアドレス。
    ///   - link: メールリンクから受信したリンク情報。
    func entryAccountByEmailLink(email: String, link: String) {

        let credential = EmailAuthProvider.credential(withEmail: email, link: link)

        Auth.auth().currentUser?.link(with: credential) { authData, error in
            if let error {
                Logger.e(error.localizedDescription)
                self.resultAccountLink = false
                self.showAccountLinkAlert.toggle()
                return
            }
            // The provider was successfully linked.
            // The phone user can now sign in with their phone number or email.
            self.resultAccountLink = true
            self.showAccountLinkAlert.toggle()
        }
    }

    /// 入力されたメールアドレスが既にFirebaseのAuthデータに登録されているかをチェックし、
    /// アカウントの有無によって適切な処理を実行するメソッド。
    /// 実行される処理は、ユーザーが選択したサインインタイプによって分岐する。
    /// - Parameters:
    ///   - email: ユーザーが入力したメールアドレス。
    ///   - selected: ユーザーが操作の中で選択したサインインタイプ。
    func existEmailCheckAndSendMailLink(email: String, selected: UserSelectedSignInType) {

        /// 受け取ったメールアドレスを使って、Auth内から既存アカウントの有無を調べる
        Auth.auth().fetchSignInMethods(forEmail: email) { (providers, error) in

            if let error = error {
                Logger.e(error.localizedDescription)
                // メソッドの実行結果がerrorだった場合の処理
                self.logInAlertMessage = .other
                self.isShowLogInFlowAlert.toggle()

                hapticErrorNotification()
                withAnimation(.spring(response: 0.3)) {
                    self.addressSignInFase = .failure
                }
                return
            }
            /// アカウントが既に存在していた場合の処理
            if let providers = providers, providers.count > 0 {

                /// Authの判定後、ユーザが選択したサインインタイプによってさらに処理がスイッチ分岐する
                switch selected {

                case .start :
                    print("")

                case .logIn :
                    self.sendEmailLink(email: email, useType: .signIn)

                case .signUp:
                    // アカウントが既に存在することをアラートで伝えて、既存データへのログインを促す
                    self.logInAlertMessage = .existEmailAddressAccount
                    self.isShowLogInFlowAlert.toggle()
                    withAnimation(.spring(response: 0.3)) {
                        self.addressSignInFase = .exist
                    }

                    hapticErrorNotification()
                }
                // アカウントが存在しなかった場合の処理
            } else {

                switch selected {

                case .start :
                    print("")

                case .logIn :
                    // アカウントが存在しないことをアラートで伝えて、ユーザ登録を促す
                    self.logInAlertMessage = .notExistEmailAddressAccount
                    self.isShowLogInFlowAlert.toggle()

                    withAnimation(.spring(response: 0.3)) {
                        self.addressSignInFase = .notExist
                    }
                    hapticErrorNotification()

                case .signUp:
                    self.sendEmailLink(email: email, useType: .signUp)

                }
            }
        }
    }

    /// ユーザーのuidをFirestoreの"users"ドキュメントと照らし合わせ、
    /// ドキュメントがすでに存在するかをチェックするメソッド。
    func existUserDocumentCheck() async throws {
        guard let uid = uid else { throw CustomError.uidEmpty }

        if let doc = db?.collection("users").document(uid) {

            do {
                let document = try await doc.getDocument(source: .default)
                let user = try? document.data(as: User.self)
                Logger.d("exsist user.")
                self.logInAlertMessage = .existsUserDocument
                self.isShowLogInFlowAlert.toggle()
                throw CustomError.existUserDocument
            }
        }
    }

    /// 新規ユーザードキュメントをFirestoreに保存するメソッド。
    /// - Parameters:
    ///   - name: ユーザーが入力したアプリ内のユーザー名。
    ///   - password: ユーザーが入力したパスワード。
    ///   - imageData: ユーザーが設定したユーザーアイコンデータ。タプル型でurlとpathが含まれている。
    ///   - color: ユーザーが選択したカスタムシステムカラー。
    func setNewUserDocumentToFirestore(name: String,
                                       password: String?,
                                       imageData: (url: URL?, filePath: String?),
                                       color: ThemeColor) async throws {

        guard let currentUser = Auth.auth().currentUser else {
            Logger.e("currentUser nil.")
            throw CustomError.uidEmpty
        }
        // currentUserのuidとドキュメントIDを同じにして生成
        let newUserData = User(id: currentUser.uid,
                               name: name,
                               address: currentUser.email,
                               password: password,
                               iconURL: imageData.url,
                               iconPath: imageData.filePath,
                               userColor: color,
                               joinsId: [])
        do {
            try db?
                .collection("users")
                .document(newUserData.id)
                .setData(from: newUserData)
        } catch {
            Logger.d(error.localizedDescription)
            throw CustomError.setData
        }
    }

    // ダイナミックリンクによってメールアドレス認証でのサインインをするため、ユーザにメールを送信するメソッド
    /// - Parameters:
    ///   - email: ユーザーが入力したメールアドレス。
    ///   - useType: メールリンクの利用用途を表現する値。
    func sendEmailLink(email: String, useType: HandleUseReceivedEmailLink) {

        withAnimation(.easeInOut(duration: 0.3)) {
            self.addressSignInFase = .check
        }

        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://unicoaddress.page.link/open")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        actionCodeSettings.setAndroidPackageName("com.example.android",
                                                 installIfNotAvailable: false, minimumVersion: "12")

        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
            if let error = error {
                Logger.e(error.localizedDescription)
                hapticErrorNotification()
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.addressSignInFase = .failure
                }
                return
            }
            hapticSuccessNotification()

            // リンクから再度アプリに戻ってきた後の処理で、リンクから飛んできたアドレスと保存アドレスの差分がないかチェック
            UserDefaults.standard.set(email, forKey: "Email")

            // 呼び出し側で指定されたリンクの用途をプロパティに渡す
            self.handleUseReceivedEmailLink = useType
            withAnimation(.easeInOut(duration: 0.7)) {
                self.addressSignInFase = .success
            }
        }
    }

    /// ユーザーのメールからのリンクアクセスを検知して実行するメソッド。
    /// 受け取ったリンクとメールアドレスを用いて、Firebase.Authにアタッチする。
    /// - Parameters:
    ///   - email: ユーザーが入力したメールアドレス。
    ///   - link: メールリンクからのアクセスによって検知したリンク値。
    func signInEmailLink(email: String, link: String) {
        Auth.auth().signIn(withEmail: email, link: link) { authResult, error in
            if let error {
                Logger.e(error.localizedDescription)
                //リンクメールの有効期限が切れていた時、ここに処理が走るみたい。
                self.isShowLogInFlowAlert.toggle()
                self.logInAlertMessage = .invalidLink
                return
            }
        }
    }

    /// ユーザーの登録メールアドレスを更新するメソッド。
    /// - Parameter email: 新しく登録するメールアドレス。
    func updateEmailAddress(email: String) {
        Auth.auth().currentUser?.updateEmail(to: email) { error in
            if let error {
                Logger.d(error.localizedDescription)
                hapticErrorNotification()
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.updateEmailCheckFase = .failure
                }
            } else {
                Logger.i("updateEmail: \(email)")
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.updateEmailCheckFase = .success
                }
            }
        }
    }

    /// メールリンクからcredentialを作成してアカウント再認証を行う。
    /// 再認証に成功したら、メールリンクの使用用途によって処理が分岐する。
    func addressReAuthenticateByEmailLink(email: String, link: String, handle: HandleUseReceivedEmailLink) {
        guard let user = Auth.auth().currentUser else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, link: link)

        // アカウントの再認証が成功したら新規メールアドレス入力画面へ移動する
        user.reauthenticate(with: credential) { authData, error in
            if let error = error {
                Logger.e(error.localizedDescription)
                self.defaultEmailCheckFase = .failure
            } else {
                Logger.i("reauthenticateUserEmail: \(email)")
                // 各ビューのonChangeへ処理が移行(メールアドレス更新、アカウント削除)
                // 再認証によって受け取った値を保持しておく(アカウント削除時、最終確認アラートを挟むため)
                self.receivedAddressByLink = email
                self.receivedLink = link
                self.addressReAuthenticateResult = true
            }
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
    /// StringデータからQRコードを生成するメソッド。
    /// - Parameter
    /// - inputText: QRコード化する対象のStringデータ。
    /// - Returns: UIImageデータとしてQRコード画像を返す。
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

    func refreshAuthState() {
        self.signedInOrNotResult = false

        if let user = Auth.auth().currentUser {
            user.reload { error in
                if let error {
                    Logger.e(error.localizedDescription)
                } else {
                    if Auth.auth().currentUser == nil {
                        Logger.i("User is no longer valid")
                    } else {
                        Logger.i("User is still valid")
                    }
                }
            }
        }
    }

    /// FirebaseのAuthにアタッチし、アカウントをログアウトするメソッド。
    func logOut() {
        do {
            try Auth.auth().signOut()
            Logger.i("user signOut.")
        } catch let error {
            Logger.e(error.localizedDescription)
        }
    }

    /// Firebase Authのアカウントデータを消去する破壊的メソッド。
    func deleteAuth() async throws {
        guard let user = Auth.auth().currentUser else { throw CustomError.userEmpty }

        do {
            _ = try await user.delete()
            Logger.i("user deleted.")
        } catch {
            DispatchQueue.main.async {
                self.deleteAccountCheckFase = .failure
            }
            Logger.e(error.localizedDescription)
            throw CustomError.deleteAccount
        }
    }

    deinit {
        if let listenerHandle {
            Auth.auth().removeStateDidChangeListener(listenerHandle)
        }
    }
}

/// Authフロー関連におけるエラーの列挙。
enum AuthRelatedError:Error {
    case uidEmpty
    case joinsEmpty
    case referenceEmpty
    case missingData
    case missingSnapshot
    case failedCreateJoinTeam
    case failedFetchUser
    case failedFetchAddedNewUser
    case failedTeamListen
    case failedUpdateLastLogIn
}
