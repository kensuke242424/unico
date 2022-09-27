//
//  FirstLogInView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI

struct FirstSignInView: View {

    let user: User
    
    var body: some View {
        NavigationView {

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

        } // NavigationView
    }
}

// ログイン時の入力欄のカスタムViewです。
struct FirstLogInInfomation: View {

    @State private var address = ""
    @State private var password = ""
    @State private var password2 = ""
    @State private var passHidden = true
    @State private var passHidden2 = true
    @State private var resultPassword = true
    @State private var isActive = false
    let user: User

    var body: some View {

        VStack(alignment: .leading) {
            Group { // 入力欄全体

                Text("メールアドレス")

                TextField("artwork/@gmail.com", text: $address)

                Text("パスワード")

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
                            print("passHidden: \(passHidden)")
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

                    if resultPassword == false {
                        Text("※再入力パスワードが異なります")
                            .font(.caption2)
                            .foregroundColor(.red)

                    } // if
                } // HStack

                ZStack {

                    if passHidden2 {
                        SecureField("●●●●", text: $password2)
                    } else {
                        TextField("●●●●", text: $password2)
                    } // if passHidden

                    HStack {
                        Spacer()

                        Button {
                            passHidden2.toggle()
                            print("passHidden: \(passHidden2)")
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
                       isActive: $isActive,
                       label: {
            Button {

                if password != password2 {
                    resultPassword = false
                }
                else {
                    resultPassword = true
                }

                if resultPassword {
                    isActive.toggle()
                }

            } label: {
                Text("サインイン")
            }
            .buttonStyle(.borderedProminent)

        }) // NavigationLink
            .padding()

    } // body
} // View

struct FirstLogInView_Previews: PreviewProvider {
    static var previews: some View {

        FirstSignInView(user: User(name:     "中川賢亮",
                                    address:  "kennsuke242424@gmail.com",
                                    password: "ninnzinn2424"
          )) // testUser)
    }
}
