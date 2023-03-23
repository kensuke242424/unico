//
//  AccountView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI
import StoreKit

struct SystemView: View {
    
    enum SystemListContents: CaseIterable {
        case infomation
        case account
        case twitter
        case query
        case review
        case share
        case rules
        case privacy
        
        var icon: String {
            switch self {
                
            case .infomation:
                return "cube.transparent"
                
            case .account:
                return "person"
                
            case .twitter:
                return ""
                
            case .query:
                return "envelope.open"
            
                
            case .review:
                return "star.bubble"
                
            case .share:
                return "square.and.arrow.up"
                
            case .rules:
                return "network.badge.shield.half.filled"
                
            case .privacy:
                return "hand.raised.fingers.spread"
            }
        }
        
        var title: String {
            switch self {
                
            case .infomation:
                return "お知らせ"
                
            case .account:
                return "アカウント"
                
            case .twitter:
                return "公式Twitter"
                
            case .query:
                return "お問い合わせ"
                
            case .review:
                return "アプリへの評価"
                
            case .share:
                return "アプリをシェア"
                
            case .rules:
                return "利用規約"
                
            case .privacy:
                return "プライバシーポリシー"
            }
        }
        
        var infomation: String {
            switch self {
                
            case .infomation:
                return "アプリのアップデートやお知らせを記載しています。"
                
            case .account:
                return "アカウント情報の確認や変更、削除を含めた操作を行います。"
                
            case .twitter:
                return "unicoの公式Twitterへ移動します。"
                
            case .query:
                return "アプリご利用についてお問い合わせを行います。"
                
            case .review:
                return "unicoのレビュー評価を行います。"
                
            case .share:
                return "unicoアプリをシェアします。"
                
            case .rules:
                return "アプリの利用規約について記載しています。"
                
            case .privacy:
                return "アプリのプライバシーポリシーを記載しています。"
            }
        }
    }

    @EnvironmentObject var logInVM: LogInViewModel
    @StateObject var itemVM: ItemViewModel

    var body: some View {

        VStack {
            ForEach(SystemListContents.allCases, id: \.self) { listRow in
                
                
                switch listRow {
                    
                case .infomation:
                    NavigationLink {
                        EmptyView()
                    } label: {
                        ListRowView(icon : listRow.icon,
                                    title: listRow.title,
                                    text : listRow.infomation)
                    }
                    
                case .account:
                    NavigationLink {
                        AccountSystemView(logInVM: logInVM)
                    } label: {
                        ListRowView(icon : listRow.icon,
                                    title: listRow.title,
                                    text : listRow.infomation)
                    }
                    
                case .twitter:
                    NavigationLink {
                        EmptyView()
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
                    
                case .review:
                    Button {
                        
                    } label: {
                        ListRowView(icon : listRow.icon,
                                    title: listRow.title,
                                    text : listRow.infomation)
                    }
                    
                case .share:
                    Button {
                        logInVM.shareApp()
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
        .navigationTitle("設定メニュー")
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
                if self.title == "公式Twitter" {
                    Image("twitter_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 20)
                } else {
                    Image(systemName: icon)
                        .font(.title3)
                        .frame(width: 30, height: 30)
                }
                
                
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.semibold)
                        .padding(.bottom, 1)
                    Text(text)
                        .font(.caption)
                        .opacity(0.5)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
                    .opacity(0.7)
            }
            .padding(.horizontal, 15)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .padding(.vertical, 10)
    }
}

struct SystemView_Previews: PreviewProvider {
    static var previews: some View {
        SystemView(itemVM: ItemViewModel())
    }
}
