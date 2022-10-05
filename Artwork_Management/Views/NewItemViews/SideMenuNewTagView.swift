//
//  SideMenuNewTagView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/05.
//

import SwiftUI

struct SideMenuNewTagView: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var isOpenSideMenu: Bool

    let screenSize = UIScreen.main.bounds

    @State private var newTagName = ""
    @State private var newTagColor = ""
    @State private var selectionTagColor = UIColor.red
    @State private var disableButton = true

    var body: some View {

        ZStack {

            // 背景
            Color(.gray).opacity(0.5)
                .opacity(self.isOpenSideMenu ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.25))
                .onTapGesture {
                    self.isOpenSideMenu = false
                }

            // Todo: サイドメニューViewレイアウトここから

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.black)
                    .frame(width: screenSize.width, height: 600)
                    .opacity(0.7)

                VStack(alignment: .leading, spacing: 30) {

                    VStack(alignment: .leading) {
                        Text("新規タグ")
                            .font(.title2)
                            .foregroundColor(.white)
                            .opacity(0.5)
                            .fontWeight(.bold)

                        Rectangle()
                            .foregroundColor(.white)
                            .opacity(0.2)
                            .frame(width: screenSize.width, height: 5)
                            .padding(.bottom, 50)
                    }

                    VStack(alignment: .leading) {
                        Text("■タグネーム")
                            .foregroundColor(.white)

                        TextField("No name...", text: $newTagName)
//                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 20)

                        Rectangle()
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .frame(width: screenSize.width / 2, height: 1)
                            .padding(.bottom)

                    } // タグネーム
                    .padding(.bottom)

                    VStack(alignment: .leading) {
                        Text("■タグ色")
                            .foregroundColor(.white)

                        Picker("色を選択", selection: $selectionTagColor) {

                            Text("赤").tag(UIColor.red)
                            Text("青").tag(UIColor.blue)
                            Text("黄").tag(UIColor.yellow)
                            Text("緑").tag(UIColor.green)
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom)
                        .padding(.trailing, screenSize.width / 2)
                    } // タグ色

                    if !newTagName.isEmpty {
                        Text("- \(newTagName) -")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(radius: 4, x: 4, y: 6)
                    }

                    IndicatorRow(salesValue: 150000, tagColor: Color(selectionTagColor))

                    Button {
                        // タグ追加処理
                    } label: {
                        Text("追加")
                    }
                    .frame(width: 70, height: 30)
                    .buttonStyle(.borderedProminent)
                    //                    .disabled(disableButton)
                    .padding(.top)

                } // VStack
                .padding(.leading, 30)
            } // ZStack (ブロック)
            .offset(x: self.isOpenSideMenu ? screenSize.width / 2 - 30 : screenSize.width)
            .animation(.easeIn(duration: 0.25))

            // サイドメニューViewレイアウト ここまで

        } // ZStack
//        .offset(y: 100)
    } // body
} // View

struct SideMenuNewTagView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuNewTagView(itemVM: ItemViewModel(),
                           isOpenSideMenu: .constant(true))
    }
}
