//
//  UpadateAddressView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/10.
//

import SwiftUI

struct UpdateAddressView: View {
    @EnvironmentObject var logInVM: LogInViewModel
    @State private var inputEmailAddress: String = ""
    var body: some View {
        VStack {
            Text("新しいアドレスの入力")
                .font(.title2)
                .fontWeight(.bold)
                .tracking(3)
                .foregroundColor(.white)
                .padding(.top, 100)
            
            
            Text("新しく登録するメールアドレスを入力してください。")

            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .opacity(0.7)
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
                        
                        Text(inputEmailAddress.isEmpty ? "登録済のメールアドレスを入力" : "")
                            .foregroundColor(.black)
                            .opacity(0.4)
                    }
                }
                .padding()
            
            Button("アドレスを更新") {
                Task {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        logInVM.systemAccountEmailCheckFase = .check
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            HStack(spacing: 10) {
                Text(logInVM.systemAccountEmailCheckFase.faseText)
                    .foregroundColor(logInVM.systemAccountEmailCheckFase == .notMatches ||
                                     logInVM.systemAccountEmailCheckFase == .failure ? .red : .white)
                
                if logInVM.systemAccountEmailCheckFase == .check ||
                   logInVM.systemAccountEmailCheckFase == .waitDelete {
                   ProgressView()
                }
            }
            .padding()
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .customSystemBackground()
        .customBackButton()
        .navigationTitle("メールアドレスの変更")
        
    }
}

struct UpadateAddressView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateAddressView()
            .environmentObject(LogInViewModel())
    }
}
