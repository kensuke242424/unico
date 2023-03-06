//
//  Artwork_ManagementApp.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI
import Firebase
import FirebaseDynamicLinks

@main
struct ArtworkManagementApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
            FirebaseApp.configure()
            return true
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    // handle the URL that must be opened
                    // メールリンクからのログイン時、遷移リンクURLを検知して受け取る
                    let incomingURL = url
                    print("Incoming URL is: \(incomingURL)")
                    // 受け取ったメールリンクURLを使ってダイナミックリンクを生成
                    let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                        guard error == nil else {
                            print("Error found!: \(error!.localizedDescription)")
                            return
                        }
                        // ダイナミックリンクが有効かチェック
                        // リンクが有効だった場合、メールリンクからのサインインメソッド実行
                        if let dynamicLink {
                            let defaults = UserDefaults.standard
                            if let email = defaults.string(forKey: "Email") {
                                print("アカウント登録するユーザのメールアドレス: \(email)")
                                // Firebase Authにアカウントの登録
                                Auth.auth().signIn(withEmail: email, link: incomingURL.absoluteString)
                                { authResult, error in
                                    if let authResult {
                                        print("ログイン成功")
                                    } else {
                                        print("ログインエラー：", error?.localizedDescription ?? "")
                                    }
                                }
                            } else {
                                print("if let email == nil")
                            }
                        } else {
                            print("if let dynamicLink == nil")
                        }
                    }
                    if linkHandled {
                        print("Link Handled")
                        return
                    } else {
                        print("NO linkHandled")
                        return
                    }
                }
        }
    }
    
    private func handlePasswordlessSignIn(withURL url: URL) -> Bool {
        // 受け取ったURLからリンクの絶対文字列(absoluteString)を取得
        let link = url.absoluteString
        // メールリンク用のアドレスサインイン処理を実行
        if Auth.auth().isSignIn(withEmailLink: link) {
            // [END is_signin_link]
            UserDefaults.standard.set(link, forKey: "Link")
            return true
        }
        return false
    }
}
