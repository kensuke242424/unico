//
//  AccountView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI
import StoreKit
import SafariServices

struct SystemView: View {

    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var logInVM: LogInViewModel

    @StateObject var externalManager = ExternalManager()

    var body: some View {

        VStack(spacing: 10) {
            ForEach(SystemListContents.allCases, id: \.self) { listRow in
                
                
                switch listRow {

                case .setting:
                    Button {
                        navigationVM.path.append(ApplicationSettingPath.root)
                    } label: {
                        ListRowView(icon : listRow.icon,
                                    title: listRow.title,
                                    text : listRow.infomation)
                    }
                    
                case .account:
                    Button {
                        navigationVM.path.append(SystemAccountPath.root)
                    } label: {
                        ListRowView(icon : listRow.icon,
                                    title: listRow.title,
                                    text : listRow.infomation)
                    }
                    
                case .twitter:
                    Button {
                        //TODO: unicoの公式アカウントを作った段階でurlを更新
                        let twitterURL = URL(string: "https://twitter.com/kenchan2n4n")!
                        UIApplication.shared.open(twitterURL)
                    } label: {
                        ListRowView(icon : listRow.icon,
                                    title: listRow.title,
                                    text : listRow.infomation)
                    }
                    
                case .review:
                    Button {
                        externalManager.reviewApp()
                    } label: {
                        ListRowView(icon : listRow.icon,
                                    title: listRow.title,
                                    text : listRow.infomation)
                    }
                    
                case .share:
                    Button {
                        externalManager.shareApp()
                    } label: {
                        ListRowView(icon : listRow.icon,
                                    title: listRow.title,
                                    text : listRow.infomation)
                    }
                    
                case .query:
                    NavigationLink {
                        EmptyView()
                    } label: {
                        ListRowView(icon : listRow.icon,
                                    title: listRow.title,
                                    text : listRow.infomation)
                    }
                    
                case .rules:
                    NavigationLink {
                        EmptyView()
                    } label: {
                        ListRowView(icon : listRow.icon,
                                    title: listRow.title,
                                    text : listRow.infomation)
                    }
                    
                case .privacy:
                    NavigationLink {
                        EmptyView()
                    } label: {
                        ListRowView(icon : listRow.icon,
                                    title: listRow.title,
                                    text : listRow.infomation)
                    }
                }
            }
            
            Spacer()
            
        } // VStack
        .customNavigationTitle(title: "システムメニュー")
        .customSystemBackground()
        .customBackButton()
        
    } // body
} // View

struct ListRowView: View {
    
    let icon: String
    let title: String
    let text: String
    
    var body: some View {
        
        VStack {
            
            HStack {
                if self.title == "公式X（旧Twitter）" {
                    Image("X_Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 20)
                } else {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                }
                
                
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.semibold)
                        .foregroundColor(title == "アカウントの削除" ? .red :
                                         title == "ログアウト"      ? .orange : .white)
                        .padding(.bottom, 1)
                    Text(text)
                        .font(.caption)
                        .foregroundColor(.white)
                        .opacity(0.5)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .opacity(0.7)
            }
            .padding(.horizontal, 15)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

/// システム画面の各種リストのエレメントを管理する列挙体。
enum SystemListContents: CaseIterable {
    case setting
    case account
    case twitter
    case review
    case share
    case query
    case rules
    case privacy

    var icon: String {
        switch self {

        case .setting:
            return "paintbrush.pointed.fill"

        case .account:
            return "person"

        case .twitter:
            return ""

        case .review:
            return "star.bubble"

        case .share:
            return "square.and.arrow.up"

        case .query:
            return "envelope.open"

        case .rules:
            return "network.badge.shield.half.filled"

        case .privacy:
            return "hand.raised.fingers.spread"
        }
    }

    var title: String {
        switch self {

        case .setting:
            return "アプリ設定"

        case .account:
            return "アカウント設定"

        case .twitter:
            return "公式X（旧Twitter）"

        case .review:
            return "アプリのレビューを書く"

        case .share:
            return "アプリをシェア"

        case .query:
            return "お問い合わせ"

        case .rules:
            return "利用規約"

        case .privacy:
            return "プライバシーポリシー"
        }
    }

    var infomation: String {
        switch self {

        case .setting:
            return "アプリ内の設定を変更します。"

        case .account:
            return "アカウント情報の確認や変更、削除を含めた操作を行います。"

        case .twitter:
            return "unicoの公式X（旧Twitter）アカウントへ移動します。"

        case .review:
            return "AppStoreにてunicoのレビュー評価を行います。（レビューをいただけると大変嬉しいです）"

        case .share:
            return "シェア画面から他の人にunicoアプリをシェアします。"

        case .query:
            return "アプリのご利用に関してお問い合わせを行います。"

        case .rules:
            return "アプリの利用規約について記載しています。"

        case .privacy:
            return "アプリのプライバシーポリシーを記載しています。"
        }
    }
}

struct SystemView_Previews: PreviewProvider {
    static var previews: some View {
        SystemView()
    }
}
