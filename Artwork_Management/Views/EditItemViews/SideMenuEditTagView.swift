//
//  SideMenuNewTagView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/05.
//

import SwiftUI
// NOTE: サイドタグメニューの入力値を構造体化
struct InputTagSideMenu {
    var newTagNameText: String = ""
    var disableButton: Bool = true
    var selectionSideMenuTagColor: UsedColor = .red
    var overlapTagNameAlert: Bool = false
    var updateTagErrorAlert: Bool = false
    var tagSideMenuStatus: EditStatus = .create
    // NOTE: 初期値として画面横幅分をoffset(x)軸に渡すことで、呼び出されるまでの間、画面外へ除いておく
}

struct SideMenuEditTagView: View {

    enum EditTagField {
        case tag, name
    }

    @StateObject var itemVM: ItemViewModel
    @Binding var inputHome: InputHome
    @Binding var inputTag: InputTagSideMenu
    let defaultTag: Tag?
    let tagSideMenuStatus: EditStatus
    @FocusState var focusedField: EditTagField?

    let screenSize = UIScreen.main.bounds

    var body: some View {

        Color.clear
            .ignoresSafeArea()

            // TagSideMenu Detail...
            .overlay {

                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color.customDarkGray2).opacity(0.9)
                    .blur(radius: 10)
                    .frame(width: screenSize.width, height: screenSize.height * 0.65)
                    .onTapGesture { focusedField = nil }
                    .overlay(alignment: .bottomLeading) {
                        Button {
                            inputTag.newTagNameText = ""
                            inputTag.selectionSideMenuTagColor = .red
                            withAnimation(.easeIn(duration: 0.2)) {
                                inputHome.isOpenEditTagSideMenu.toggle()
                            }
                            withAnimation(.easeIn(duration: 0.2)) {
                                inputTag.newTagNameText = ""
                                inputTag.selectionSideMenuTagColor = .red
                                inputHome.editTagSideMenuBackground.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "multiply.circle.fill")
                                Text("閉じる")
                            }

                            .font(.title3)
                            .foregroundColor(.white)
                            .offset(x: 20, y: 50)
                        }
                    }

                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.4), lineWidth: 2)
                    .frame(width: screenSize.width, height: screenSize.height * 0.65)

                // 入力フォーム...
                VStack(alignment: .leading, spacing: screenSize.height * 0.65 * 0.04) {

                    VStack(alignment: .leading) {

                        Text(inputTag.tagSideMenuStatus == .create ? "新規タグ" : "タグ編集")
                            .font(.title2)
                            .foregroundColor(.white)
                            .opacity(0.5)
                            .fontWeight(.bold)

                        Rectangle()
                            .foregroundColor(.white)
                            .opacity(0.2)
                            .frame(width: screenSize.width, height: 5)
                            .padding(.bottom, 30)

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
                                        .foregroundColor(.black)
                                } // overlay
                                .opacity(0.8)
                        } // HStack
                        .padding(.bottom)

                        TextField("名前を入力", text: $inputTag.newTagNameText)
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

                        Picker("色を選択", selection: $inputTag.selectionSideMenuTagColor) {

                            ForEach(UsedColor.allCases, id: \.self) { value in

                                if value.color != .gray {
                                    Text(value.text)
                                }
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom)
                        .padding(.trailing, screenSize.width / 2)
                    } // タグ色
                    // show edit Result...
                    VStack(alignment: .leading) {
                        Text("-  \(inputTag.newTagNameText)  -")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, alignment: .leading)
                            .lineLimit(1)
                            .padding(.bottom)

                        IndicatorRow(salesValue: 170000,
                                     tagColor: inputTag.selectionSideMenuTagColor)

                        Button {
                            switch inputTag.tagSideMenuStatus {

                            case .create:
                                // NOTE: 既存のタグと重複していないかを確認します。重複していればアラート表示
                                if itemVM.tags.contains(where: { $0.tagName == inputTag.newTagNameText }) {
                                    print(".create エラー inputTag.newTagNameText: \(inputTag.newTagNameText)")
                                    inputTag.overlapTagNameAlert.toggle()
                                    return
                                }
                                // 新規タグデータを追加、配列の2番目に保存(at: 1) 0は"ALL"タグ
                                withAnimation {
                                    itemVM.tags.insert(Tag(tagName: inputTag.newTagNameText,
                                                           tagColor: inputTag.selectionSideMenuTagColor), at: 1)
                                }

                                withAnimation(.easeIn(duration: 0.2)) {
                                    inputHome.isOpenEditTagSideMenu.toggle()
                                }
                                withAnimation(.easeIn(duration: 0.2)) {
                                    inputHome.editTagSideMenuBackground.toggle()
                                }
                                inputTag.newTagNameText = ""
                                inputTag.selectionSideMenuTagColor = .red

                            case .update:

                                guard let unwrappedDefaultTag = defaultTag else {
                                    print("更新対象タグの取得エラー！！")
                                    return
                                }

                                if unwrappedDefaultTag.tagName != inputTag.newTagNameText {
                                    if itemVM.tags.contains(where: { $0.tagName == inputTag.newTagNameText }) {
                                        print(".create タグネーム重複 inputTag.newTagNameText: \(inputTag.newTagNameText)")
                                        inputTag.overlapTagNameAlert.toggle()
                                        return
                                    }
                                }

                                // メソッド: 更新内容を受け取って、itemVM.tagsの対象タグデータを更新するメソッドです。
                                itemVM.updateTagsData(itemVM: itemVM,
                                                      defaultTag: unwrappedDefaultTag,
                                                      newTagName: inputTag.newTagNameText,
                                                      newTagColor: inputTag.selectionSideMenuTagColor)

                                // メソッド: 更新内容を受け取って、itemVM.itemsの対象タグデータを更新するメソッドです。
                                itemVM.updateItemsTagData(itemVM: itemVM,
                                                          defaultTag: unwrappedDefaultTag,
                                                          newTagName: inputTag.newTagNameText,
                                                          newTagColorString: inputTag.selectionSideMenuTagColor.text)

                                withAnimation(.easeIn(duration: 0.2)) {
                                    inputHome.isOpenEditTagSideMenu.toggle()
                                }
                                withAnimation(.easeIn(duration: 0.2)) {
                                    inputHome.editTagSideMenuBackground.toggle()
                                }

                                inputTag.newTagNameText = ""
                                inputTag.selectionSideMenuTagColor = .red

                            } // switch
                        } label: {
                            Text(inputTag.tagSideMenuStatus == .create ? "追加" : "更新")
                        } // Button(追加 or 更新)
                        .frame(width: 70, height: 30)
                        .buttonStyle(.borderedProminent)
                        .disabled(inputTag.disableButton)
                        .padding(.top, 40)
                    }

                    // Alert overlapTagName...
                    .alert("タグの重複", isPresented: $inputTag.overlapTagNameAlert) {

                        Button {
                            inputTag.overlapTagNameAlert.toggle()
                        } label: {
                            Text("OK")
                        }
                    } message: {
                        Text("入力したタグネームは既に存在します。")
                    }

                    // Alert updateTagError...
                    .alert("タグ更新エラー", isPresented: $inputTag.updateTagErrorAlert) {

                        Button {
                            inputTag.updateTagErrorAlert.toggle()
                        } label: {
                            Text("OK")
                        }
                    } message: {
                        Text("タグの更新に失敗しました。")
                    } // alert
                    // NOTE: タグネームの入力値がisEmptyの場合、追加ボタンを無効化します
                    .onChange(of: inputTag.newTagNameText) {newValue in
                        if newValue.isEmpty {
                            inputTag.disableButton = true
                        } else {
                            inputTag.disableButton = false
                        }
                    } // .onChange
                } // VStack
                .offset(x: 20)

            }

            .onChange(of: inputHome.isOpenEditTagSideMenu) { isOpenEditTag in
                if isOpenEditTag == false {
                    focusedField = nil
                    inputTag.newTagNameText = ""
                    inputTag.selectionSideMenuTagColor = .red
                }
            }

    } // body
} // View

struct SideMenuNewTagView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuEditTagView(
            itemVM: ItemViewModel(),
            inputHome: .constant(InputHome()),
            inputTag: .constant(InputTagSideMenu()),
            defaultTag: Tag(tagName: "テストタグ", tagColor: .green),
            tagSideMenuStatus: .create)
    }
}
