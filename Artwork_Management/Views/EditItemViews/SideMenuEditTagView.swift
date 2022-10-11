//
//  SideMenuNewTagView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/05.
//

import SwiftUI

struct SideMenuEditTagView: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var isOpenSideMenu: Bool
    @Binding var geometryMinY: CGFloat
    @Binding var selectionTagName: String
    @Binding var selectionTagColor: UsedColor
    let screenSize = UIScreen.main.bounds
    let itemTagName: String
    let itemTagColor: UsedColor

    let editItemStatus: Status
    let tagSideMenuStatus: Status

    // NOTE: サイドタグメニューの入力値を構造体化
    struct InputSideMenuTag {
        var newTagName: String = ""
        var disableButton: Bool = true
        var opacity: CGFloat = 0.0
        var selectionSideMenuTagColor: UsedColor = .red
        var isShowAlert: Bool = false
        // NOTE: 初期値として画面横幅分をoffset(x)軸に渡すことで、呼び出されるまでの間、画面外へ除いておく
        var defaultOffsetX: CGFloat = UIScreen.main.bounds.width
    }

    @State private var input: InputSideMenuTag = InputSideMenuTag()

    @FocusState var focusedField: Field?

    var body: some View {

        ZStack {

            // 背景
            Color(.gray).opacity(0.5)
                .opacity(self.input.opacity)
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.25)) {
                        self.input.defaultOffsetX = screenSize.width
                        self.input.opacity = 0.0
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

                        TextField("No name...", text: $input.newTagName)
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

                        Picker("色を選択", selection: $input.selectionSideMenuTagColor) {

                            ForEach(UsedColor.allCases, id: \.self) { value in

                                Text(value.text).tag(value.color)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom)
                        .padding(.trailing, screenSize.width / 2)
                    } // タグ色

                    Text("-  \(input.newTagName)  -")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 4, x: 4, y: 6)

                    IndicatorRow(salesValue: 170000,
                                 tagColor: input.selectionSideMenuTagColor)

                    Button {

                        switch tagSideMenuStatus {

                        case .create:

                            print("タグ追加ボタンタップ...")

                            // NOTE: 既存のタグと重複していないかを確認します。重複していればアラート表示
                            if itemVM.tags.contains(where: { $0.tagName == input.newTagName }) {

                                print("タグが重複しました。")
                                self.input.isShowAlert.toggle()

                            } else {

                                // 新規タグデータを追加、配列の１番目に保存(at: 0)
                                itemVM.tags.insert(Tag(tagName: input.newTagName,
                                                       tagColor: input.selectionSideMenuTagColor),
                                                   at: 0)

                                self.selectionTagName = input.newTagName

                            } // if contains

                        case .update:

                            print("タグ編集ボタンタップ...")

                            self.selectionTagName = input.newTagName
                            self.selectionTagColor = input.selectionSideMenuTagColor

                            // メソッド: 更新内容を受け取って、itemVM.tagsの対象タグデータを更新するメソッドです。
                            itemVM.updateTagsData(itemVM: itemVM,
                                                  itemTagName: itemTagName,
                                                  selectTagName: input.newTagName,
                                                  selectTagColor: input.selectionSideMenuTagColor)

                            // メソッド: 更新内容を受け取って、itemVM.itemsの対象タグデータを更新するメソッドです。
                            itemVM.updateItemsTagData(itemVM: itemVM,
                                                      itemTagName: itemTagName,
                                                      newTagName: input.newTagName,
                                                      newTagColorString: input.selectionSideMenuTagColor.text)

                        } // switch

                        if !input.isShowAlert {

                            withAnimation(.easeIn(duration: 0.25)) {
                                self.input.defaultOffsetX = screenSize.width
                                self.input.opacity = 0.0
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.isOpenSideMenu = false

                            }
                        } // if !isShowAlert

                    } label: {
                        Text(tagSideMenuStatus == .create ? "追加" : "更新")
                    } // Button(追加 or 更新)
                    .alert("タグの重複", isPresented: $input.isShowAlert) {

                        Button {
                            input.isShowAlert.toggle()
                            print("isShowAlert: \(input.isShowAlert)")
                        } label: {
                            Text("OK")
                        }
                    } message: {
                        Text("入力したタグネームは既に存在します。")
                    } // alert
                    .frame(width: 70, height: 30)
                    .buttonStyle(.borderedProminent)
                    .disabled(input.disableButton)
                    .padding(.top)

                } // VStack
                .padding(.leading, 30)
            } // ZStack (新規タグブロック)
            .offset(x: input.defaultOffsetX)
            .offset(y: editItemStatus == .update ? -80 : 0)
            .onTapGesture { self.focusedField = nil }

            // NOTE: タグネームの入力値がisEmptyの場合、追加ボタンを無効化します
            .onChange(of: input.newTagName) {newValue in
                withAnimation(.easeIn(duration: 0.15)) {
                    if newValue.isEmpty {
                        input.disableButton = true
                    } else {
                        input.disableButton = false
                    }
                }
            } // .onChange

        } // ZStack(全体)
        .offset(y: focusedField == .tag ? -self.geometryMinY - 330 : -self.geometryMinY - 200)
        .animation(.easeOut(duration: 0.3), value: focusedField)
        .opacity(self.input.opacity)
        // View表示時

        .onAppear {

            print("SideMenuTagView_onAppear_実行")

            print("アイテム編集ステータス: \(editItemStatus)")
            print("サイドメニュータグ編集ステータス: \(tagSideMenuStatus)")

            // // タグ編集の場合は、親Viewから受け取ったアイテムの値を渡す
            if tagSideMenuStatus == .update {
                self.input.newTagName = selectionTagName
                self.input.selectionSideMenuTagColor = selectionTagColor
            }

            withAnimation(.easeIn(duration: 0.3)) {
                self.input.opacity = 1.0
                // NOTE: View呼び出し時に「画面横幅 / 2 - (微調整)」で横から入力ブロックを出現
                self.input.defaultOffsetX = input.defaultOffsetX / 2 - 30
            }
        } // onAppear
    } // body
} // View

struct SideMenuNewTagView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuEditTagView(
            itemVM: ItemViewModel(),
            isOpenSideMenu: .constant(true),
            geometryMinY: .constant(-200),
            selectionTagName: .constant("＋タグを追加"),
            selectionTagColor: .constant(.red),
            itemTagName: "Album",
            itemTagColor: .red,
            editItemStatus: .create,
            tagSideMenuStatus: .create
        )
    }
}
