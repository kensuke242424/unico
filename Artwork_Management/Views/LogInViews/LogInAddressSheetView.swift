//
//  LogInAddressSheetView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/23.
//

import SwiftUI

struct LogInAddressSheetView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var logInVM: AuthViewModel
    @FocusState var showEmailKyboard: Bool?
    
    @State private var inputLogIn: InputLogIn = InputLogIn()
    
    @State private var offsetAnimation: Bool = false

    /// アドレスの使用用途を表すプロパティ。
    /// 設定によってメールリンクの使用タイプが分岐する。
    let useType: HandleUseReceivedEmailLink
    
    var body: some View {
            VStack {
                Spacer()
                VStack {
                    // -- トップ --
                    HStack {
                        switch useType {
                        case .signUp, .entryAccount:
                            Text("メールアドレス アカウント登録").font(.title3).fontWeight(.bold)
                        case.signIn:
                            Text("メールアドレス ログイン").font(.title3).fontWeight(.bold)
                        case .updateEmail, .deleteAccount:
                            Text("メールアドレス 認証").font(.title3).fontWeight(.bold)
                        }

                        Spacer()

                        // 閉じるボタン
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                                offsetAnimation.toggle()
                                showEmailKyboard = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                logInVM.showEmailHalfSheet.toggle()
                                logInVM.addressSignInFase = .start
                            }
                        } label: {
                            Circle()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray.opacity(0.2))
                                .overlay {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary.opacity(0.7))
                                        .frame(width: 10, height: 10)
                                }
                        }
                        .disabled(logInVM.addressSignInFase == .check ? true : false)
                        .opacity(logInVM.addressSignInFase == .check ? 0.3 : 1.0)
                    }

                    // -- アドレスチェック中のみ表示されるテキスト --
                    HStack(spacing: 10) {
                        if logInVM.addressSignInFase == .check {
                            ProgressView()
                        } else {
                            logInVM.addressSignInFase.checkIcon
                                .foregroundColor(
                                    logInVM.addressSignInFase == .failure ||
                                    logInVM.addressSignInFase == .exist   ||
                                    logInVM.addressSignInFase == .notExist ? .red : .green)
                        }
                        Text(logInVM.addressSignInFase.checkText)
                            .tracking(5)
                            .opacity(0.5)
                            .fontWeight(.semibold)
                    }
                    .frame(width: 300, height: 30)
                    .opacity(logInVM.addressSignInFase != .start ? 1.0 : 0.0)

                    // -- フェーズシンボル --
                    HStack(spacing: 35) {
                        Image(systemName: "envelope.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                            .scaleEffect(logInVM.addressSignInFase == .check ? 1.0 :
                                            logInVM.addressSignInFase == .success ? 1.4 :
                                            1.0)
                            .opacity(logInVM.addressSignInFase == .check ? 0.8 :
                                        logInVM.addressSignInFase == .failure ||
                                     logInVM.addressSignInFase == .notExist ? 0.8 :
                                        logInVM.addressSignInFase == .success ? 1.0 :
                                        0.8)
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: "questionmark")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .opacity(logInVM.addressSignInFase == .failure ||
                                             logInVM.addressSignInFase == .notExist ? 0.5 : 0.0)
                                    .offset(x: 15, y: -15)
                            }

                        if logInVM.addressSignInFase != .success {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .opacity(logInVM.addressSignInFase == .check ? 1.0 :
                                            logInVM.addressSignInFase == .failure ||
                                         logInVM.addressSignInFase == .notExist ? 0.2 :
                                            0.4)
                                .scaleEffect(inputLogIn.repeatAnimation ? 1.3 : 1.0)
                                .animation(.default.repeat(while: inputLogIn.repeatAnimation),
                                           value: inputLogIn.repeatAnimation)
                        }

                        if logInVM.addressSignInFase != .success {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                                .opacity(logInVM.addressSignInFase == .check ? 0.4 :
                                            logInVM.addressSignInFase == .failure ||
                                         logInVM.addressSignInFase == .notExist ? 0.2 :
                                            0.8)
                                .scaleEffect(logInVM.addressSignInFase == .check ? 0.8 : 1.0)
                        }
                    }
                    .frame(height: 60)
                    .padding(.bottom)

                    // リピートスケールアニメーションの発火トリガー(アドレス入力の.check時に使用)
                    .onChange(of: logInVM.addressSignInFase) { newValue in
                        if newValue == .check {
                            inputLogIn.repeatAnimation = true
                        } else {
                            inputLogIn.repeatAnimation = false
                        }
                    }

                    // -- フェーズテキスト --
                    VStack(spacing: 5) {
                        Text(logInVM.addressSignInFase.messageText.text1)
                        Text(logInVM.addressSignInFase.messageText.text2)
                    }
                    .font(.subheadline)
                    .tracking(1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)

                    // -- アドレス入力ボックス --
                    TextField("メールアドレスを入力", text: $inputLogIn.address)
                        .focused($showEmailKyboard, equals: true)
                        .autocapitalization(.none)
                        .padding()
                        .frame(width: getRect().width * 0.8, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(colorScheme == .dark ? .gray.opacity(0.2) : .white)
                                .frame(height: 30)
                                .shadow(color: showEmailKyboard == true ? .blue : .clear, radius: 3)
                        )
                        .padding(20)
                        .onChange(of: inputLogIn.address) { newValue in
                            if newValue.isEmpty {
                                inputLogIn.sendAddressButtonDisabled = true
                            } else {
                                inputLogIn.sendAddressButtonDisabled = false
                            }
                        }

                    // -- リンクメール送信ボタン --
                    Button(logInVM.addressSignInFase == .start || logInVM.addressSignInFase == .check ? "メールを送信" : "もう一度送る") {

                        // アドレス処理の結果ビュー更新は各メソッド先で行なっている
                        withAnimation(.spring(response: 0.3)) {
                            logInVM.addressSignInFase = .check
                        }

                        switch useType {
                        case .signUp:
                            logInVM.existEmailCheckAndSendMailLink(email: inputLogIn.address, selected: .signUp)
                        case.signIn:
                            logInVM.existEmailCheckAndSendMailLink(email: inputLogIn.address, selected: .logIn)
                        case .entryAccount:
                            logInVM.sendEmailLink(email: inputLogIn.address, useType: .entryAccount)
                        case .updateEmail:
                            logInVM.sendEmailLink(email: inputLogIn.address, useType: .updateEmail)
                        case .deleteAccount:
                            logInVM.sendEmailLink(email: inputLogIn.address, useType: .deleteAccount)
                        }

                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(inputLogIn.sendAddressButtonDisabled)
                    .opacity(logInVM.addressSignInFase == .check ? 0.3 : 1.0)
                    .padding(.top, 10)
                }
                .padding()
                .padding(.bottom)
                .background {
                    RoundedRectangle(cornerRadius: 40)
                        .foregroundColor(colorScheme == .light ? .customHalfSheetForgroundLight : .customHalfSheetForgroundDark)
                        .onTapGesture { showEmailKyboard = nil }
                }
            }
            .offset(y: offsetAnimation ? 0 : getRect().height / 2 + 50)
            .offset(y: inputLogIn.keyboardOffset)
            .onChange(of: showEmailKyboard) { newValue in
                if newValue == true {
                    withAnimation(.spring(response: 0.5)) {
                        inputLogIn.keyboardOffset = -UIScreen.main.bounds.height / 3
                    }
                } else {
                    withAnimation(.spring(response: 0.5)) {
                        inputLogIn.keyboardOffset = 0
                    }
                }
            }
            .onAppear {
                print("選択中のタイプ: \(useType)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                        offsetAnimation.toggle()
                    }
                }
            }
            .onDisappear {
                // ビューの初期化
                logInVM.addressSignInFase = .start
            }
            .background {
                if logInVM.showEmailHalfSheet {
                    Rectangle()
                        .fill(.black)
                        .opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 1.0, blendDuration: 0.5)) {
                                offsetAnimation.toggle()
                                showEmailKyboard = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                logInVM.showEmailHalfSheet.toggle()
                                logInVM.addressSignInFase = .start
                            }
                        }
                }
            }
            .ignoresSafeArea()
    }
}

struct LogInAddressSheetView_Previews: PreviewProvider {
    static var previews: some View {
        LogInAddressSheetView(useType: .signIn)
    }
}
