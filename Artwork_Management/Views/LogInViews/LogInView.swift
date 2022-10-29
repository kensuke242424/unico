//
//  LogInView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI

// ✅ ログイン画面の親Viewです。
struct LogInView: View {

    // テスト用のダミーデータです。
    let testUser: User = User(name: "中川賢亮",
                              address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424"
    ) // testUser

    var body: some View {

        NavigationView {

            ZStack {
                VStack {

                    Spacer()

                    // ロゴマークのカスタムView
                    RogoMark()

                    Spacer()

                    // ログイン画面のインフォメーション部品のカスタムView
                    LogInInfomation(user: testUser)

                    Spacer()

                } // VStack
            } // ZStack
            .background(LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                                       startPoint: .top, endPoint: .bottom))
        } // NavigationView
    } // body
} // View

// ✅ログイン画面に表示されるロゴマークのカスタムViewです。
struct RogoMark: View {
    var body: some View {

        VStack {

            Image(systemName: "paragraphsign")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding()

            Text("ArtWork Manage")
                .font(.title3)
                .fontWeight(.heavy)
        } // VStack
    } // body
} // View

// ✅ログイン時の入力欄のカスタムViewです。
struct LogInInfomation: View {

    let user: User

    struct InputLogIn {
        var address: String = ""
        var password: String = ""
        var passHidden: Bool = true
        var isActive: Bool = false
        var resultAddress: Bool = true
        var resultPassword: Bool = true
    }

    @State private var input: InputLogIn = InputLogIn()

    var body: some View {

        VStack(alignment: .leading) {

            // 入力欄全体
            Group {

                HStack {
                    Text("メールアドレス")

                    if input.resultAddress == false {
                        Text("※該当するアドレスがありません。")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                } // HStack‚

                TextField("artwork/@gmail.com", text: $input.address)

                HStack {
                    Text("パスワード")

                    if input.resultPassword == false {
                        Text("※パスワードが間違っています。")
                            .font(.caption2)
                            .foregroundColor(.red)
                    } // if
                } // HStack

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
            .keyboardType(.emailAddress)
            .padding(.bottom, 15)

        } // VStack(.leading)
        .padding()

        VStack {

            NavigationLink(destination: HomeTabView(),
                           isActive: $input.isActive,
                           label: {
                Button {

                    // アドレスが存在するかチェック
                    if user.address != input.address {
                        input.resultAddress = false
                    } else {
                        input.resultAddress = true
                    }

                    // メールアドレスが存在したら、パスワードが合っているかチェック
                    if input.resultAddress {
                        if user.password != input.password {
                            input.resultPassword = false
                        } else {
                            input.resultPassword = true
                        }
                    }

                    // アドレス、パスワードが一致したらログイン、遷移
                    if input.resultAddress, input.resultPassword {
                        input.isActive.toggle()
                    }

                } label: {
                    Text("ログイン")
                }
                .buttonStyle(.borderedProminent)

            }) // NavigationLink

            Group {
                NavigationLink("初めての方はこちら>>",
                               destination: FirstSignInView(user: user))
                .foregroundColor(.blue)
                .padding()

                Text("- または -")
                    .padding()

                NavigationLink("試しに始めてみる",
                               destination: HomeTabView())
            } // Group
            .font(.subheadline)
        } // VStack
    } // body
} // View

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
