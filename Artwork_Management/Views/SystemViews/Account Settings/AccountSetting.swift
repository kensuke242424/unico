//
//  AccountSetting.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/10.
//

import SwiftUI

struct AccountSetting: View {
    
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
                return "unicoに登録しているメールアドレス情報の変更を行います。"
                
            case .deleteAccount:
                return "unicoに登録されているアカウントデータを削除します。チーム内に他のメンバーが存在する場合、チーム内の「アイテム」「タグ」を含めたチームデータは消去されずに残ります。"
            }
        }
        
        @ViewBuilder var content: some View {
            
            switch self {
                
            case .addressChange:
                UpdateAddressView()
                
            case .deleteAccount:
                DeleteAccountView()
            }
        }
    }
    
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
        .navigationTitle("アカウント")
        .customSystemBackground()
        .customBackButton()
    }
    
    @ViewBuilder
    func deleteAccount() -> some View {
        
    }
}

struct AccountSetting_Previews: PreviewProvider {
    static var previews: some View {
        AccountSetting()
    }
}
