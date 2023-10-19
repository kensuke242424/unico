//
//  AccountSetting.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/10.
//

import SwiftUI

struct AccountSystemView: View {
    
    private enum AccountListContents: CaseIterable {
        
        case entryAccount
        case addressChange
        case logOut
        case deleteAccount
        
        var icon: String {
            switch self {
            case .entryAccount:
                return "person.fill.checkmark"
                
            case .addressChange:
                return "envelope"
                
            case .logOut:
                return "door.right.hand.open"
                
            case .deleteAccount:
                return "person"
            }
        }
        
        var title: String {
            switch self {
            case .entryAccount:
                return "アカウントの登録"
                
            case .addressChange:
                return "メールアドレスの変更"
                
            case .logOut:
                return "ログアウト"
                
            case .deleteAccount:
                return "アカウントの削除"
            }
        }
        
        var infomation: String {
            switch self {
            case .entryAccount:
                return "お試しアカウントから本登録アカウントに切り替えます。メールアドレスでの登録が可能です。"
                
            case .addressChange:
                return "unicoに登録しているメールアドレス情報の変更を行います。"
                
            case .logOut:
                return "ご利用のアカウントからログアウトします。"
                
            case .deleteAccount:
                return "unicoに登録されているアカウントデータを削除します。チーム内に他のメンバーが存在する場合、チーム内の「アイテム」「タグ」を含めたチームデータは消去されずに残ります。"
            }
        }
    }
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var progress: ProgressViewModel
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var logInVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var showEntryAccount: Bool = false
    
    // アラートを管理するプロパティ
    @State private var showLogOutAlert         : Bool = false
    @State private var showExistAccountAlert   : Bool = false
    @State private var showNotEntryAccountAlert: Bool = false
    
    var body: some View {
        
        VStack(spacing: 20) {
            ForEach(AccountListContents.allCases, id: \.self) { listRow in
                
                    switch listRow {
                        
                    case .entryAccount:
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                                showEntryAccount.toggle()
                            }
                        } label: {
                            ListRowView(icon : listRow.icon,
                                        title: listRow.title,
                                        text : listRow.infomation)
                        }
                        .onChange(of: logInVM.resultAccountLink) { result in
                            if result == true {
//                                userVM.isAnonymousCheck()
                            }
                        }
                        .alert(logInVM.resultAccountLink ? "登録完了" : "登録失敗",
                               isPresented: $logInVM.showAccountLinkAlert) {
                            Button("OK") {
                                logInVM.showAccountLinkAlert.toggle()
                                dismiss()
                            }
                        } message: {
                            if logInVM.resultAccountLink {
                                Text("アカウントの登録に成功しました！引き続き、unicoをよろしくお願い致します。")
                            } else {
                                Text("アカウント登録時にエラーが発生しました。もう一度試してみてください。")
                            }
                        } // alert

                        
                    case .addressChange:
                        Button {
                            if userVM.isAnonymous {
                                showNotEntryAccountAlert.toggle()
                            } else {
                                navigationVM.path.append(SystemAccountPath.defaultEmailCheck)
                            }
                        } label: {
                            ListRowView(icon : listRow.icon,
                                        title: listRow.title,
                                        text : listRow.infomation
                            )
                        }
                        .alert("未登録", isPresented: $showNotEntryAccountAlert) {
                            Button("OK") {}
                        } message: {
                            Text("お使いのアカウントはお試し中です。メールアドレスは登録されていません。")
                        }
                        
                    case .logOut:
                        Button {
                            showLogOutAlert.toggle()
                        } label: {
                            ListRowView(icon : listRow.icon,
                                        title: listRow.title,
                                        text : listRow.infomation
                            )
                        }
                        .alert("確認", isPresented: $showLogOutAlert) {
                            Button("戻る") { showLogOutAlert.toggle() }
                            Button("ログアウト") {
                                progress.showLoading.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    progress.showLoading.toggle()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.easeIn(duration: 0.5)) {
                                            logInVM.rootNavigation = .logIn
                                            logInVM.logOut()
                                        }
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    navigationVM.path.removeLast(navigationVM.path.count)
                                }
                            }
                        } message: {
                            if userVM.isAnonymous {
                                Text("お試し中にログアウトすると、元のデータに再度ログインすることはできません。ログアウトしますか？")
                            } else {
                                Text("アカウントからログアウトして、ログイン画面に戻ります。よろしいですか？")
                            }
                        } // alert
                        
                    case .deleteAccount:
                        Button {
                            navigationVM.path.append(SystemAccountPath.deleteAccount)
                        } label: {
                            ListRowView(icon : listRow.icon,
                                        title: listRow.title,
                                        text : listRow.infomation
                            )
                        }
                    }
            }
            Spacer()
        }
        .customNavigationTitle(title: "アカウント")
        .customSystemBackground()
        .customBackButton()
        .sheet(isPresented: $showEntryAccount) {
            UserEntryRecommendationView(isShow: $showEntryAccount)
        }
    }
}

struct AccountSetting_Previews: PreviewProvider {
    static var previews: some View {
        AccountSystemView()
            .environmentObject(AuthViewModel())
            .environmentObject(NavigationViewModel())
            .environmentObject(UserViewModel())
    }
}
