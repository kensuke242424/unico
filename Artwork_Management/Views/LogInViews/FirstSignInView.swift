//
//  FirstLogInView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI

struct FirstSignInView: View {

    @Binding var logInNavigationPath: [LogInNavigation]
    // テスト用のデータ
    let testUser: User

    var body: some View {

        ZStack {

            LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack {

                RogoMark()

                Spacer()

                Text("アカウント登録")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(30)

                FirstLogInInfomation(logInNavigationPath: $logInNavigationPath, user: testUser)

                Spacer()

            } // VStack
        }
    }
}

// ✅ログイン時の入力欄のカスタムViewです。
struct FirstLogInInfomation: View {

    @Binding var logInNavigationPath: [LogInNavigation]
    let user: User

    @State private var input: InputLogIn = InputLogIn()

    var body: some View {

        VStack(alignment: .leading) {
            Group { // 入力欄全体

                Text("メールアドレス")

                TextField("artwork/@gmail.com", text: $input.address)

                Text("パスワード")

                HStack {
                    if input.passHidden {
                        SecureField("●●●●", text: $input.password)
                    } else {
                        TextField("●●●●", text: $input.password)
                    } // if passHidden

                } // HStack
                .overlay(alignment: .trailing) {
                    Button {
                        input.passHidden.toggle()
                        print("passHidden: \(input.passHidden)")
                    } label: {
                        Image(systemName: input.passHidden2 ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    } // Button
                }



                HStack {
                    Text("再度入力してください")
                        .foregroundColor(.gray)

                    if input.resultPassword == false {
                        Text("※パスワードが一致しません")
                            .font(.caption2)
                            .foregroundColor(.red)

                    } // if
                } // HStack

                HStack {
                    if input.passHidden {
                        SecureField("●●●●", text: $input.password2)
                    } else {
                        TextField("●●●●", text: $input.password2)
                    } // if passHidden

                } // HStack
                .overlay(alignment: .trailing) {
                    Button {
                        input.passHidden2.toggle()
                        print("passHidden: \(input.passHidden2)")
                    } label: {
                        Image(systemName: input.passHidden2 ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    } // Button
                }

            } // Group(入力欄全体)
            .font(.subheadline)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            .padding(.bottom, 10)
            .padding(.horizontal, 25)
        } // VStack
        .padding()

        VStack {
            Button("サインアップ") {

                if input.password != input.password2 {
                    input.resultPassword = false
                } else {
                    input.resultPassword = true
                }

                if input.resultPassword {
                    logInNavigationPath.append(.home)
                }

            }
            .buttonStyle(.borderedProminent)
        }
        .padding()

    } // body
} // View

struct FirstLogInView_Previews: PreviewProvider {
    static var previews: some View {

        FirstSignInView(logInNavigationPath: .constant([]),
                        testUser: User(name: "中川賢亮",
                                    address: "kennsuke242424@gmail.com",
                                    password: "ninnzinn2424")
        )
    }
}
