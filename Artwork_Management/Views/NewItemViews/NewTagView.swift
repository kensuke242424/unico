//
//  NewTagView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/04.
//

import SwiftUI

struct NewTagView: View {

    @State private var newTagName = ""
    @State private var newTagColor = ""
    @State private var selectionTagColor = UIColor.red
    @State private var disableButton = true
    @Binding var isShowNewTagCreate: Bool

    var body: some View {

        ZStack {

            Color(.gray)
                .ignoresSafeArea()
                .opacity(0.3)
                .onTapGesture {
                    withAnimation(.linear(duration: 0.2)) {
                        isShowNewTagCreate = false
                    }
                } // onTapGesture

            VStack {

                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.black)
                    .frame(width: 300, height: 400)
                    .opacity(0.6)
                    .overlay {

                        VStack(spacing: 10) {
                            Text("新規タグ")
                                .foregroundColor(.gray)
                                .font(.title3)
                                .fontWeight(.bold)

                            Rectangle()
                                .foregroundColor(.gray)
                                .frame(height: 1)
                                .padding(.bottom)

                            VStack {
                                Text("■タグネーム")
                                    .foregroundColor(.white)

                                TextField("タグの名前を入力...", text: $newTagName)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 200, height: 20)

                                Divider()
                                    .background(.white)
                                    .padding(.horizontal, 50)
                            } // タグネーム
                            .padding(.bottom)

                            VStack {
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

//                                Rectangle()
//                                    .foregroundColor(.white)
//                                    .frame(height: 1)
                            } // タグ色

                            if !newTagName.isEmpty {
                                Text("- \(newTagName) -")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .shadow(radius: 4, x: 4, y: 6)
                            }

                            IndicatorRow(salesValue: 250000, tagColor: Color(selectionTagColor))
                                .padding()

                            Button {
                                // タグ追加処理
                            } label: {
                                Text("追加")
                            }
                            .frame(width: 70, height: 30)
                            .buttonStyle(.borderedProminent)
//                            .disabled(disableButton)
                            .padding(.top)

                        } // VStack
                        .padding()
                    } // overlay 全体
            }

        }

    }
}

struct NewTagView_Previews: PreviewProvider {
    static var previews: some View {
        NewTagView(isShowNewTagCreate: .constant(true))
    }
}
