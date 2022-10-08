//
//  SideMenuNewTagView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/05.
//

import SwiftUI

enum Status {
    case create
    case update
}

struct SideMenuNewTagView: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var isOpenSideMenu: Bool
    @Binding var geometryMinY: CGFloat
    @Binding var selectionTagName: String
    @Binding var selectionTagColor: Color

    let screenSize = UIScreen.main.bounds
    let itemTagName: String
    let itemTagColor: Color

    let itemStatus: Status
    let tagSideMenuStatus: Status

    @State private var newTagName = ""
    @State private var disableButton = true
    @State private var opacity = 0.0
    @State private var selectionSideMenuTagColor = Color.red
    @State private var isShowAlert = false
    // NOTE: 初期値として画面横幅分をoffset(x)軸に渡すことで、呼び出されるまでの間、画面外へ除いておく
    @State private var defaultOffsetX: CGFloat = UIScreen.main.bounds.width
    @FocusState var focusedField: Field?

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
                    //       DispatchQueueを用いてtoggle処理をずらしています。
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
                    .shadow(radius: 5, x: -5, y: 5)
                    .shadow(radius: 5, x: -5, y: 5)

                VStack(alignment: .leading, spacing: 20) {

                    VStack(alignment: .leading) {
                        Text(tagSideMenuStatus == .create ? "新規タグ" : "タグ編集")
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

                        HStack(spacing: 10) {
                            Text("■タグネーム")
                                .fontWeight(.heavy)
                                .foregroundColor(.white)

                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: 30, height: 15)
                                .foregroundColor(.gray)
                                .overlay {
                                    Text("必須")
                                        .font(.caption)
                                } // overlay
                                .opacity(0.8)
                        } // HStack

                        TextField("No name...", text: $newTagName)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .padding()
                            .frame(width: 200, height: 20)
                            .focused($focusedField, equals: .tag)

                        FocusedLineRow(select: focusedField == .tag ? true : false)
                            .frame(width: screenSize.width / 2)

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

                        Picker("色を選択", selection: $selectionSideMenuTagColor) {

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

                    IndicatorRow(salesValue: 170000, tagColor: selectionSideMenuTagColor)

                    Button {



                            switch tagSideMenuStatus {

                            case .create:

                                print("タグ追加ボタンタップ...")

                                // NOTE: アイテム内にタグが重複していないかを確認します。重複していればアラート表示
                                if itemVM.tags.contains(where: { $0.tagName == newTagName }) {

                                    print("タグが重複しました。")
                                    self.isShowAlert.toggle()

                                } else {

                                // 新規タグデータを追加、配列の１番目に保存(at: 0)
                                itemVM.tags.insert(Tag(tagName: newTagName,
                                                       tagColor: selectionSideMenuTagColor),
                                                   at: 0)

                                self.selectionTagName = newTagName

                            } // if contains

                            case .update:

                                print("タグ編集ボタンタップ...")

                                self.selectionTagName = newTagName
                                self.selectionTagColor = selectionSideMenuTagColor

                                // メソッド: 更新内容を受け取って、itemVM.tagsの対象タグデータを更新するメソッドです。
                                itemVM.updateTagsData(itemVM: itemVM,
                                                      itemTagName: itemTagName,
                                                      selectTagName: newTagName,
                                                      selectTagColor: selectionSideMenuTagColor)

                                // メソッド: 更新内容を受け取って、itemVM.itemsの対象タグデータを更新するメソッドです。
                                itemVM.updateItemsTagData(itemVM: itemVM,
                                                          itemTagName: itemTagName,
                                                          newTagName: newTagName,
                                                          newTagColorString: itemVM.castColorIntoString(color: selectionTagColor))

                            } // switch

                        if !isShowAlert {

                            withAnimation(.easeIn(duration: 0.25)) {
                                self.defaultOffsetX = screenSize.width
                                self.opacity = 0.0
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.isOpenSideMenu = false

                            }
                        } // if !isShowAlert

                    } label: {
                        Text(tagSideMenuStatus == .create ? "追加" : "更新")
                    } // Button(追加 or 更新)
                    .alert("タグの重複", isPresented: $isShowAlert) {

                        Button {
                            isShowAlert.toggle()
                            print("isShowAlert: \(isShowAlert)")
                        } label: {
                            Text("OK")
                        }
                    } message: {
                        Text("入力したタグネームは既に存在します。")
                    } // alert
                    .frame(width: 70, height: 30)
                    .buttonStyle(.borderedProminent)
                    .disabled(disableButton)
                    .padding(.top)

                } // VStack
                .padding(.leading, 30)
            } // ZStack (新規タグブロック)
            .offset(x: defaultOffsetX)
            .onTapGesture { self.focusedField = nil }

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
        .offset(y: itemStatus == .create ? 0 : -80)
        .offset(y: focusedField == .tag ? -self.geometryMinY - 330 : -self.geometryMinY - 200)
        .animation(.easeOut(duration: 0.3), value: focusedField)
        .opacity(self.opacity)
        // View表示時

        .onAppear {

            // // タグ編集の場合は、親Viewから受け取ったアイテムの値を渡す
            if tagSideMenuStatus == .update {
                self.newTagName = itemTagName
                self.selectionSideMenuTagColor = itemTagColor
            }

            withAnimation(.easeIn(duration: 0.3)) {
                self.opacity = 1.0
                // NOTE: View呼び出し時に「画面横幅 / 2 - (微調整)」で横から入力ブロックを出現
                self.defaultOffsetX = defaultOffsetX / 2 - 30
            }
        } // onAppear

    } // body
} // View

struct SideMenuNewTagView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuNewTagView(
            itemVM: ItemViewModel(),
            isOpenSideMenu: .constant(true),
            geometryMinY: .constant(-200),
            selectionTagName: .constant("＋タグを追加"),
            selectionTagColor: .constant(Color.red),
            itemTagName: "Album",
            itemTagColor: Color.red,
            itemStatus: .create,
            tagSideMenuStatus: .create
        )
    }
}
