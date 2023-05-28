//
//  ApplicationSettingView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/05/26.
//

import SwiftUI

struct ApplicationSettingView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var darkModeToggle: Bool = false
    @State private var selectedColor: MemberColor?

    var body: some View {
        ScrollView {
            VStack(spacing: 50) {

                VStack(alignment: .leading, spacing: 0) {
                    Text("モード設定")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, 10)

                    Text(
    """
    アプリ内でのダークモード設定を行います。
    主にテキスト文字、アイテム詳細画面の配色が切り替わります。
    暗めのレイアウトの場合におすすめです。
    """
                    )
                    .font(.caption)
                    .frame(height: 50)
                    .opacity(0.7)
                    .padding([.top, .leading], 10)

                    List {
                        Toggle("ダークモード", isOn: $darkModeToggle)
                            .listRowBackground(Color.gray.opacity(0.2))
                    }
                    .scrollContentBackground(.hidden)
                    .frame(height: 100)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("テーマカラー設定")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, 10)

                    Text(
    """
    アプリ内でのテーマカラー設定を行います。
    主にタグ、ボタン、サイドメニューの配色が反映されます。
    """
                    )
                    .font(.caption)
                    .frame(height: 40)
                    .opacity(0.7)
                    .padding([.top, .leading], 10)

                    SelectionColorList()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.white)

        }
        .customNavigationTitle(title: "アプリ設定")
        .customSystemBackground()
        .customBackButton()

        .onAppear {
            selectedColor = userVM.memberColor
        }
        .onDisappear {

        } // VStack
    } // SCrollView

    @ViewBuilder
    func SelectionColorList() -> some View {
        VStack(alignment: .leading, spacing: 0) {

            List(selection: $selectedColor) {
                ForEach(MemberColor.allCases, id: \.self) { color in
                    HStack(spacing: 30) {
                        if selectedColor == color {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.white)
                                .opacity(0.5)
                        }

                        Rectangle()
                            .fill(color.color4)
                            .frame(width: 100, height: 20)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.2))
            }
            .scrollContentBackground(.hidden)
            .environment(\.editMode, .constant(.active))
            .frame(height: CGFloat(MemberColor.allCases.count) * 50)
        }
    }
}

struct ApplicationSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationSettingView()
            .environmentObject(UserViewModel())
    }
}
