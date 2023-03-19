//
//  SavingProgressView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/20.
//

import SwiftUI

struct SavingProgressView: View {
    var body: some View {
        VStack(spacing: 20) {
            
            Text("画像を保存しています...")
                .foregroundColor(.white)
                .tracking(3)
            
            ProgressView()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Rectangle()
                .fill(.black.opacity(0.5))
                .ignoresSafeArea()
        }
    }
}

struct SavingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        SavingProgressView()
    }
}
