//
//  FirstLogInView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI

struct FirstSignInView: View {

    // テスト用のデータ
    let user: User

    var body: some View {

        VStack {

            Spacer()

            RogoMark()

            Spacer()

            Text("アカウント登録")
                .font(.title2)
                .fontWeight(.medium)
                .padding(30)

            FirstLogInInfomation(user: user)

            Spacer()

        } // VStack
        .background(LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]), startPoint: .top, endPoint: .bottom))
    }
}

// ✅ログイン時の入力欄のカスタムViewです。
struct FirstLogInInfomation: View {

    let user: User

    struct InputFirstLogin {
        var address: String = ""
        var password: String = ""
        var password2: String = ""
        var passHidden: Bool = true
        var passHidden2: Bool = true
        var resultPassword: Bool = true
        var isActive: Bool = false
    }

    @State private var input: InputFirstLogin = InputFirstLogin()

    var body: some View {

        VStack(alignment: .leading) {
            Group { // 入力欄全体

                Text("メールアドレス")

                TextField("artwork/@gmail.com", text: $input.address)

                Text("パスワード")

                ZStack {
                    if input.passHidden {
                        SecureField("●●●●", text: $input.password)
                    } else {
                        TextField("●●●●", text: $input.password)
                    } // if passHidden

                    HStack {
                        Spacer()

                        Button {
                            input.passHidden.toggle()
                            print("passHidden: \(input.passHidden)")
                        } label: {
                            Image(systemName: "eye.fill")
                                .foregroundColor(.gray)
                        } // Button
                    } // HStack
                    .padding(.horizontal)
                } // ZStack

                HStack {
                    Text("再度入力してください")
                        .foregroundColor(.gray)

                    if input.resultPassword == false {
                        Text("※パスワードが一致しません")
                            .font(.caption2)
                            .foregroundColor(.red)

                    } // if
                } // HStack

                ZStack {

                    if input.passHidden2 {
                        SecureField("●●●●", text: $input.password2)
                    } else {
                        TextField("●●●●", text: $input.password2)
                    } // if passHidden

                    HStack {
                        Spacer()

                        Button {
                            input.passHidden2.toggle()
                            print("passHidden: \(input.passHidden2)")
                        } label: {
                            Image(systemName: "eye.fill")
                                .foregroundColor(.gray)
                        } // Button
                    } // HStack
                    .padding(.horizontal)
                } // ZStack

            } // Group(入力欄全体)
            .font(.subheadline)
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.emailAddress)
            .padding(.bottom, 10)

        } // VStack
        .padding()

        NavigationLink(destination: HomeTabView(),
                       isActive: $input.isActive,
                       label: {
            Button {

                if input.password != input.password2 {
                    input.resultPassword = false
                } else {
                    input.resultPassword = true
                }

                if input.resultPassword {
                    input.isActive.toggle()
                }

            } label: {
                Text("サインイン")
            }
            .buttonStyle(.borderedProminent)

        }) // NavigationLink
    } // body
} // View

struct FirstLogInView_Previews: PreviewProvider {
    static var previews: some View {

        FirstSignInView(user: User(name: "中川賢亮",
                                    address: "kennsuke242424@gmail.com",
                                    password: "ninnzinn2424")
        )
    }
}
