//
//  FirstLogInView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI

struct FirstSignInView: View {
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

                FirstLogInInfomation()

                Button {

                } label: {
                    Text("サインイン")
                }
                .buttonStyle(.borderedProminent)

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

    var body: some View {

        VStack(alignment: .leading) {
            Group { // 入力欄全体

                Text("メールアドレス")
                    .foregroundColor(.gray)

                TextField("artwork/@gmail.com", text: $address)

                Text("パスワード")
                    .foregroundColor(.gray)

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

                Text("再度入力してください")
                    .foregroundColor(.gray)

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
    } // body
} // View

struct FirstLogInView_Previews: PreviewProvider {
    static var previews: some View {
        FirstSignInView()
    }
}
