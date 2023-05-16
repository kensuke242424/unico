//
//  UpdateReportView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/28.
//

import SwiftUI

// NOTE: 書き方は ver10 -> ver.1.0とする
enum UpdateReport: CaseIterable {
    case var10
    
    var version: String {
        switch self {
        case .var10:
            return "var 1.0"
        }
    }
    
    var title: String {
        switch self {
        case .var10:
            return "var 1.0　unicoリリース開始について"
        }
    }
    
    @ViewBuilder
    func getView(varsion: String) -> some View {
        switch self {
        case .var10:
            Version10(varsion: varsion)
        }
    }
}

struct UpdateReportView: View {
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(UpdateReport.allCases, id: \.self) { report in
                
                NavigationLink {
                    report.getView(varsion: report.version)
                } label: {
                    Text(report.title)
                        .lineLimit(1)
                        .padding(.top, 10)
                }
                Rectangle()
                    .frame(height: 0.5)
            }
            Spacer()
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .navigationTitle("お知らせ")
        .customSystemBackground()
    }
}

struct UpdateReportView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateReportView()
    }
}
