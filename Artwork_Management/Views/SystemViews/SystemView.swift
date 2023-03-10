//
//  AccountView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct SystemView: View {
    
    enum SystemListContents: CaseIterable {
        case account
        
        var icon: String {
            switch self {
            case .account:
                return "person"
            }
        }
        
        var title: String {
            switch self {
            case .account:
                return "アカウント"
            }
        }
        
        var infomation: String {
            switch self {
            case .account:
                return "アカウント情報の変更や削除などの操作を行います。"
            }
        }
        
        var content: some View {
            switch self {
            case .account:
                return AccountSetting()
            }
        }
    }

    @StateObject var itemVM: ItemViewModel

    var body: some View {

        VStack {
            ForEach(SystemListContents.allCases, id: \.self) { listRow in
                
                NavigationLink {
                    listRow.content
                } label: {
                    ListRowView(icon : listRow.icon,
                            title: listRow.title,
                            text : listRow.infomation)
                }
            }
            
            Spacer()
            
        } // VStack
        .background {
            Color.userBlue1
                .ignoresSafeArea()
        }
        .navigationTitle("設定")
        
    } // body
} // View

struct ListRowView: View {
    
    let icon: String
    let title: String
    let text: String
    
    var body: some View {
        
        VStack {
            
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 30)
                    .opacity(0.5)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.semibold)
                    Text(text)
                        .font(.caption)
                        .opacity(0.5)
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
        .frame(height: 50)
        .foregroundColor(.white)
        .padding(.vertical, 10)
    }
}

struct SystemView_Previews: PreviewProvider {
    static var previews: some View {
        SystemView(itemVM: ItemViewModel())
    }
}
