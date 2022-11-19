//
//  LogInView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI

enum LogInNavigation: Hashable {
    case signUp, home
}

struct InputLogIn {
    var address: String = ""
    var password: String = ""
    var password2: String = ""
    var passHidden: Bool = true
    var passHidden2: Bool = true
    var resultAddress: Bool = true
    var resultPassword: Bool = true
}

// ✅ ログイン画面の親Viewです。
struct LogInView: View {

    @State private var logInNavigationPath: [LogInNavigation] = []

    @State var userID: String = "sampleUserID"

    // テスト用のダミーデータです。
    let testUser: User = TestUser().testUser

    var body: some View {

        NavigationStack(path: $logInNavigationPath) {

            ZStack {

                LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

                VStack {

                    Spacer()

                    RogoMark()

                    Spacer()

                    // ログイン画面のインフォメーション部品のカスタムView
                    LogInInfomation(logInNavigationPath: $logInNavigationPath,
                                    user: testUser)

                    Spacer()

                } // VStack
            } // ZStack
            .navigationDestination(for: LogInNavigation.self) { destination in

                switch destination {
                case .home:
                    HomeTabView(userID: userID)

                case .signUp:
                    FirstSignInView(logInNavigationPath: $logInNavigationPath,
                                    testUser: testUser,
                                    userID: $userID)
                }
            } // navigationDestination
        } // NavigationStack
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

    @Binding var logInNavigationPath: [LogInNavigation]
    let user: User

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
                    .padding(.bottom)

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
                            Image(systemName: input.passHidden ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        } // Button
                    } // HStack
                    .padding(.horizontal)
                } // ZStack

            } // Group(入力欄全体)
            .font(.subheadline)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            .padding(.horizontal, 25)

        } // VStack(.leading)
        .padding()

        Spacer()

        VStack {

            Button("ログイン") {
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
                    logInNavigationPath.append(.home)
                    print(logInNavigationPath)
                }
            }
            .buttonStyle(.borderedProminent)

            Group {
                Button("初めての方はこちら>>") {
                    logInNavigationPath.append(.signUp)
                    print(logInNavigationPath)
                }
                .foregroundColor(.blue)
                .padding()

                Text("- または -")
                    .padding()

                Button("試しに初めてみる") {
                    logInNavigationPath.append(.home)
                    print(logInNavigationPath)
                }
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
