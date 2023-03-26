//
//  UpadateAddressView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/10.
//

import SwiftUI
import FirebaseAuth

enum UpdateEmailCheckFase {
    case start, check, failure, success
    
    var faseText: String {
        switch self {
        case .start:
            return ""
        case.check:
            return "新しいアドレスをチェックしています..."
        case .failure:
            return "エラーが発生しました。"
        case .success:
            return ""
        }
    }
}

struct UpdateAddressView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var logInVM: LogInViewModel
    @EnvironmentObject var userVM : UserViewModel
    @State private var inputEmailAddress: String = ""
    @State private var showBackAlert: Bool = false
    
    var body: some View {
        VStack {
            
            Text("新しく登録するメールアドレスを入力してください。")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .opacity(0.7)
                .multilineTextAlignment(.leading)
                .padding(.top, 120)
            
            VStack {
                Text("- 現在登録されているメールアドレス -")
                    .opacity(0.7)
                    .padding(.bottom, 7)
                Text(Auth.auth().currentUser?.email ?? "???")
                    .opacity(0.5)
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .padding(.top)
            
            TextField("", text: $inputEmailAddress)
                .textInputAutocapitalization(.never)
                .foregroundColor(.black)
                .padding()
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .opacity(0.8)
                            .frame(height: 32)
                        Text(inputEmailAddress.isEmpty ? "新しいメールアドレスを入力" : "")
                            .foregroundColor(.black)
                            .opacity(0.4)
                    }
                }
                .padding()
            
            Button("アドレスを更新") {
                Task {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        logInVM.updateEmailCheckFase = .check
                    }
                    logInVM.updateEmailAddress(email: inputEmailAddress)
                }
            }
            .buttonStyle(.borderedProminent)
            
            // アドレスのチェック状態を表示するテキスト
            HStack(spacing: 10) {
                Text(logInVM.updateEmailCheckFase.faseText)
                    .font(.callout)
                    .foregroundColor(logInVM.updateEmailCheckFase == .failure ? .red : .white)
                
                if logInVM.updateEmailCheckFase == .check { ProgressView() }
            }
            .padding(.vertical)
            // 新規アドレスのチェックが通ったら、Firebaseに新規アドレスを保存後、更新完了Viewへ遷移する
            .onChange(of: logInVM.updateEmailCheckFase) { newValue in
                if newValue == .success {
                    Task {
                        await userVM.updateUserEmailAddress(email: inputEmailAddress)
                        navigationVM.path.append(SystemAccountPath.successUpdateEmail)
                    }
                }
            }
            
            Spacer()
        } // VStack
        .alert("確認", isPresented: $showBackAlert) {
            Button("戻る") {}
            Button("はい") { navigationVM.path.removeLast(2) }
        } message: {
            Text("メールアドレスの更新をやめますか？")
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .customSystemBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        showBackAlert.toggle()
                    }, label: {
                        Image(systemName: "arrow.backward")
                    }
                ).tint(.blue)
            }
        }
        .navigationTitle("メールアドレスの変更")
    }
}

struct UpadateAddressView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UpdateAddressView()
                .environmentObject(LogInViewModel())
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
