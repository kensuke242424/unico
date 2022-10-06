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
    @Binding var geometryMinY: CGFloat

    let screenSize = UIScreen.main.bounds

    @State private var newTagName = ""
    @State private var disableButton = true
    @State private var opacity = 0.0
    @State private var selectionTagColor = Color.red
    @State private var defaultOffsetX: CGFloat = UIScreen.main.bounds.width

    var body: some View {

        ZStack {

            // 背景
            Color(.gray).opacity(0.5)
                .opacity(self.opacity)
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.25)) {
                        self.defaultOffsetX = screenSize.width
                        self.opacity = 0.0
                    }
                    // NOTE: 表示管理Bool値をずらさないとView非表示時のアニメーションが不自然になるため、
                    //       DispatchQueueを用いて処理をずらしています。
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.isOpenSideMenu = false
                    }
                } // .onTapGesture

            // Todo: サイドメニューViewレイアウトここから

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.black)
                    .frame(width: screenSize.width, height: 600)
                    .opacity(0.7)

                VStack(alignment: .leading, spacing: 20) {

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

                    } // タイトル(新規タグ)

                    VStack(alignment: .leading) {
                        Text("■タグネーム")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)

                        TextField("No name...", text: $newTagName)
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
                            .fontWeight(.heavy)
                            .foregroundColor(.white)

                        HStack(spacing: 20) {
                            Text("◀︎")
                            Image(systemName: "rectangle.and.hand.point.up.left.filled")
                            Text("▶︎")
                        }
                        .foregroundColor(.white)
                        .opacity(0.5)
                        .padding(.top)
//                        .padding(.leading, 40)

                        Picker("色を選択", selection: $selectionTagColor) {

                            Text("赤").tag(Color.red)
                            Text("青").tag(Color.blue)
                            Text("黄").tag(Color.yellow)
                            Text("緑").tag(Color.green)
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom)
                        .padding(.trailing, screenSize.width / 2)
                    } // タグ色

                    Text("-  \(newTagName)  -")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 4, x: 4, y: 6)

                    IndicatorRow(salesValue: 170000, tagColor: selectionTagColor)

                    Button {
                        // 新規タグをオブジェクトに詰め、配列の１番目に保存
                        itemVM.tags.insert(Tag(tagName: newTagName,
                                               tagColor: selectionTagColor),
                                           at: 0
                        )

                        withAnimation(.easeIn(duration: 0.25)) {
                            self.defaultOffsetX = screenSize.width
                            self.opacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.isOpenSideMenu = false
                        }

                    } label: {
                        Text("追加")
                    }
                    .frame(width: 70, height: 30)
                    .buttonStyle(.borderedProminent)
                    .disabled(disableButton)
                    .padding(.top)

                } // VStack
                .padding(.leading, 30)
            } // ZStack (ブロック)
            .offset(x: defaultOffsetX)

            // NOTE: タグネームの入力値がisEmptyの場合、追加ボタンを無効化します
            .onChange(of: newTagName) {newValue in
                withAnimation(.easeIn(duration: 0.15)) {
                    if newValue.isEmpty {
                        disableButton = true
                    } else {
                        disableButton = false
                    }
                }
            } // .onChange

        } // ZStack(全体)
        .offset(y: -self.geometryMinY - 170)
        .opacity(self.opacity)
        // View表示時

        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                self.opacity = 1.0
                self.defaultOffsetX = defaultOffsetX / 2 - 30
            }
            self.selectionTagColor = .red
        } // onAppear

    } // body
} // View

struct SideMenuNewTagView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuNewTagView(itemVM: ItemViewModel(),
                           isOpenSideMenu: .constant(true),
                           geometryMinY: .constant(-150)
        )
    }
}
