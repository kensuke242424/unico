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

    @StateObject var teamVM: TeamViewModel = TeamViewModel()
    @StateObject var userVM: UserViewModel = UserViewModel()
    @StateObject var itemVM: ItemViewModel = ItemViewModel()
    @StateObject var tagVM: TagViewModel = TagViewModel()

    @State private var logInNavigationPath: [LogInNavigation] = []

    @State private var startFetchContents: Bool = false
    @State private var isShowProgressView: Bool = false

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
                    LogInInfomation(startFetchContents: $startFetchContents,
                                    user: testUser)

                    Spacer()

                } // VStack

                if isShowProgressView {
                    CustomProgressView()
                }
            } // ZStack
            .navigationDestination(for: LogInNavigation.self) { destination in

                switch destination {
                case .home:
                    HomeTabView(teamVM: teamVM,
                                userVM: userVM,
                                itemVM: itemVM,
                                tagVM: tagVM)

                case .signUp:
                    FirstSignInView(logInNavigationPath: $logInNavigationPath,
                                    testUser: testUser)
                }
            } // navigationDestination
        } // NavigationStack
        .onChange(of: startFetchContents) { check in
            if check {
                Task {
                    print("fetch開始")
                    isShowProgressView = true
                    await tagVM.fetchTag(teamID: teamVM.teamID)
                    await itemVM.fetchItem(teamID: teamVM.teamID)
                    print("fetch終了")
                    isShowProgressView = false
                    logInNavigationPath.append(.home)
                }
            }
        }
    } // body
} // View

// ✅ログイン画面に表示されるロゴマークのカスタムViewです。
struct RogoMark: View {
    var body: some View {

        VStack {

            Image(systemName: "cube.transparent")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 150, height: 150)
                .padding()

            Text("unico")
                .tracking(20)
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))
                .fontWeight(.heavy)
        } // VStack
    } // body
} // View

// ✅ログイン時の入力欄のカスタムViewです。
struct LogInInfomation: View {

    @Binding var startFetchContents: Bool
    let user: User

    @State private var input: InputLogIn = InputLogIn()

    var body: some View {

        VStack {

            // 入力欄全体
            Group {

                HStack {
                    Text("メールアドレス")
                        .foregroundColor(.white.opacity(0.7))

                    if input.resultAddress == false {
                        Text("※該当するアドレスがありません。")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                } // HStack
                .frame(width: getRect().width * 0.7, alignment: .leading)

                RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.2))
                    .frame(width: getRect().width * 0.7, height: 30)
                    .overlay {
                        TextField("artwork/@gmail.com", text: $input.address)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .padding(.bottom, 20)

                HStack {
                    Text("パスワード")
                        .foregroundColor(.white.opacity(0.7))

                    if input.resultPassword == false {
                        Text("※パスワードが間違っています。")
                            .font(.caption2)
                            .foregroundColor(.red)
                    } // if
                } // HStack
                .frame(width: getRect().width * 0.7, alignment: .leading)

                RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.2))
                    .frame(width: getRect().width * 0.7, height: 30)
                    .overlay {
                        ZStack(alignment: .leading) {
                            if input.passHidden {
                                SecureField("●●●●", text: $input.password)
                                    .foregroundColor(.white)
                                    .padding()
                            } else {
                                TextField("●●●●", text: $input.password)
                                    .foregroundColor(.white)
                                    .padding()
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
                    }
                    .padding(.bottom, 10)
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
                    startFetchContents.toggle()
                }
            }
            .buttonStyle(.borderedProminent)

            Group {
                Button("初めての方はこちら>>") {

                    startFetchContents.toggle()
                }
                .foregroundColor(.blue)
                .padding()

                Text("- または -")
                    .padding()
                    .foregroundColor(.white)

                Button("試しに初めてみる") {
                    startFetchContents.toggle()
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
