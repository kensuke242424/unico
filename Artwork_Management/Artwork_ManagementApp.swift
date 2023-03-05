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
        
        func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
            guard let incomingURL = userActivity.webpageURL else { return false }
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
                // リンクが処理された時に呼び出されるコードをここに実装する
            }
            return linkHandled
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
