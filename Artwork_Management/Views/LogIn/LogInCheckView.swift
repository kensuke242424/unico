//
//  LodingView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/27.
//

import SwiftUI

struct LogInCheckView: View {

    var body: some View {

        HStack {

            ProgressView()
                .padding(.trailing, 5)

            Text("LogIn Check...")
                .foregroundColor(.gray)
        }
    }
}

struct SuccsessView: View {
    var body: some View {

        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("Welcome!!")
        } // HStack
    }
}

struct ErrorView: View {
    var body: some View {
        HStack {
            Image(systemName: "lock.slash.fill")
                .foregroundColor(.red)
            Text("Login failed.")
        } // HStack
    }
}

struct LodingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LogInCheckView()
            SuccsessView()
            ErrorView()
        }

    }
}
