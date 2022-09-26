//
//  LogInView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI

struct LogInView: View {

    var body: some View {

        NavigationView {

            VStack {

                Spacer()

                RogoMark()

                Spacer()

                Text("ログイン")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(30)

                LogInInfomation()

                NavigationLink("初めての方はこちら>>",
                               destination: FirstLogInView())
                .foregroundColor(.blue)
                .padding()

                Spacer()

            } // VStack

        } // NavigationView
    } // body
} // View

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}

// ログイン画面に表示されるロゴマークのカスタムViewです。
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

// ログイン時の入力欄のカスタムViewです。
struct LogInInfomation: View {

    @State private var address = ""
    @State private var password = ""
    @State private var passHidden = true

    var body: some View {

        VStack(alignment: .leading) {

            Text("メールアドレス")
                .foregroundColor(.gray)

            TextField("●●●●", text: $address)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .padding(.bottom, 20)

            ZStack {

                Group {
                    if passHidden {
                        Text("パスワード")
                            .foregroundColor(.gray)

                        SecureField("●●●●", text: $password)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                    } else {
                        Text("パスワード")
                            .foregroundColor(.gray)

                        TextField("●●●●", text: $password)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                    } // if passHidden
                } // Group

                HStack {
                    Spacer()

                    Button {
                        passHidden.toggle()
                        print("passHidden: \(passHidden)")
                    } label: {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.gray)
                    } // Button
                }
                .padding()

            } // ZStack
        } // VStack
        .padding()

    } // body
} // View
