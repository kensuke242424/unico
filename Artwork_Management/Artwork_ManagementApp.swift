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
                .environmentObject(NavigationViewModel())
                .environmentObject(MomentLogViewModel())
                .environmentObject(LogViewModel())
                .environmentObject(NotificationViewModel())
                .environmentObject(LogInViewModel())
                .environmentObject(TeamViewModel())
                .environmentObject(UserViewModel())
                .environmentObject(TagViewModel())
                .environmentObject(BackgroundViewModel())
                .environmentObject(ProgressViewModel())
                .environmentObject(PreloadViewModel())
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
