//
//  UserEntryRecommendationView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/13.
//

import SwiftUI

struct UserEntryRecommendationView: View {
    
    @StateObject var logInVM: LogInViewModel
    @Binding var isShow: Bool
    
    var body: some View {
        
        VStack(spacing: 70) {
            
            // アカウント登録時の機能説明を保持するView
            VStack(alignment: .leading, spacing: 30) {
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("アカウント登録をすると\n以下の機能が解放されます!!")
                }
                .font(.title2)
                .fontWeight(.bold)
                .tracking(3)
                .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 20) {
                    Label("他のユーザーのチームへの参加", systemImage: "person.2.fill")
                    Label(" 自分のチームにユーザーを招待", systemImage: "person.wave.2.fill")
                        .offset(x: 2)
                    Label(" 永続的なデータの保存", systemImage: "cube.transparent.fill")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .tracking(1)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.userBlue1)
                        .opacity(0.7)
                        .scaleEffect(1.4)
                        .offset(x: 10)
                }
                .offset(x: 20)
                .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("※お試しアカウントの期間は作成した日から30日間です。\n  30日後、自動的にデータが削除されます。")
                    Text("※アカウント登録はお試し期間中いつでも可能です。\n  登録が完了すると、お試しアカウントから\n  登録済みアカウントに切り替わります。管理していた\n  アイテムやデータは全て引き継がれます。")
                        
                }
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
            }
            
            // 下部の選択ボタンを保有するView
            VStack(spacing: 40) {
                Text("お試しアカウントで始めますか？")
                    .foregroundColor(.white)
                    .tracking(3)
                
                HStack(spacing: 40) {
                    Button("戻る") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShow.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Button("お試しで始める") {
                        Task {
                            logInVM.selectSignInType = .signAp
                            logInVM.signInAnonymously()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isShow.toggle()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
        }
        .frame(width: getRect().width - 50, height: getRect().height)
        .offset(y: 50)
        .background {
            ZStack {
                
                Color.userBlue1
                    .frame(width: getRect().width, height: getRect().height)
                    .opacity(0.7)
                    .ignoresSafeArea()
                
                BlurView(style: .systemThinMaterialDark)
                    .frame(width: getRect().width, height: getRect().height)
                    .opacity(0.9)
                    .ignoresSafeArea()
                
                LogoMark()
                    .offset(y: -getRect().height + 200)
                    .scaleEffect(0.5)
            }
            
        }
    }
}

struct UserEntryRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        UserEntryRecommendationView(logInVM: LogInViewModel(), isShow: .constant(true))
    }
}
