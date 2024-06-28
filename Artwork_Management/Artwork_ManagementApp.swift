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
                .environmentObject(AuthViewModel())
                .environmentObject(TeamViewModel())
                .environmentObject(UserViewModel())
                .environmentObject(ItemViewModel())
                .environmentObject(TagViewModel())
                .environmentObject(BackgroundViewModel())
                .environmentObject(ProgressViewModel())
                .environmentObject(PreloadViewModel())
        }
    }
}
