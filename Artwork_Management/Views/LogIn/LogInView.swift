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

    @State private var address = ""
    @State private var password = ""
    @State private var passHidden = true
    @State private var isActive = false
    @State private var resultAddress = true
    @State private var resultPassword = true

    let user: User

    var body: some View {

        VStack(alignment: .leading) {

            // 入力欄全体
            Group {

                HStack {
                    Text("メールアドレス")

                    if resultAddress == false {
                        Text("※該当するアドレスがありません。")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                } // HStack

                TextField("artwork/@gmail.com", text: $address)

                HStack {
                    Text("パスワード")

                    if resultPassword == false {
                        Text("※パスワードが間違っています。")
                            .font(.caption2)
                            .foregroundColor(.red)
                    } // if
                } // HStack

                ZStack {
                    if passHidden {
                        SecureField("●●●●", text: $password)
                    } else {
                        TextField("●●●●", text: $password)
                    } // if passHidden

                    HStack {
                        Spacer()

                        Button {
                            passHidden.toggle()
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
            .padding(.bottom, 15)

        } // VStack(.leading)
        .padding()

        VStack {

            NavigationLink(destination: HomeTabView(),
                           isActive: $isActive,
                           label: {
                Button {

                    // アドレスが存在するかチェック
                    if user.address != address {
                        resultAddress = false
                    } else {
                        resultAddress = true
                    }

                    // メールアドレスが存在したら、パスワードが合っているかチェック
                    if resultAddress {
                        if user.password != password {
                            resultPassword = false
                        } else {
                            resultPassword = true
                        }
                    }

                    // アドレス、パスワードが一致したらログイン、遷移
                    if resultAddress, resultPassword {
                        isActive.toggle()
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
