//
//  AccountSetting.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/10.
//

import SwiftUI

enum AccountListContents: CaseIterable {
    case addressChange
    case deleteAccount
    
    var icon: String {
        switch self {
        case .addressChange:
            return "envelope"
            
        case .deleteAccount:
            return "person"
        }
    }
    
    var title: String {
        switch self {
        case .addressChange:
            return "メールアドレスの変更"
            
        case .deleteAccount:
            return "アカウントの削除"
        }
    }
    
    var infomation: String {
        switch self {
        case .addressChange:
            return "登録メールアドレスの変更を行います。"
            
        case .deleteAccount:
            return "アカウントを削除します。"
        }
    }
    
    var content: some View {
        switch self {
        case .addressChange:
            return Text("登録アドレスの変更画面")
            
        case .deleteAccount:
            return Text("アカウントの削除画面")
        }
    }
}

struct AccountSetting: View {
    var body: some View {
        VStack {
            ForEach(AccountListContents.allCases, id: \.self) { listRow in
                
                NavigationLink {
                    listRow.content
                } label: {
                    ListRowView(icon : listRow.icon,
                                title: listRow.title,
                                text : listRow.infomation
                    )
                }
            }
            
            Spacer()
        }
        .background {
            Color.userBlue1
                .ignoresSafeArea()
        }
        .navigationTitle("アカウント")
        
    }
}

struct AccountSetting_Previews: PreviewProvider {
    static var previews: some View {
        AccountSetting()
    }
}
