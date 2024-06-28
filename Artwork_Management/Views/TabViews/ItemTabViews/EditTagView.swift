//
//  EditTagView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/20.
//

import SwiftUI

struct EditTagView: View {

    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var itemVM: ItemViewModel
    @EnvironmentObject var tagVM : TagViewModel

    @Binding var passTag: Tag?
    @Binding var show: Bool

    @State private var tagName     : String = ""
    @State private var openContent : Bool = true
    @State private var nameEmpty   : Bool = true
    @State private var containsName: Bool = false

    @FocusState var focused: Bool?

    var body: some View {
        VStack(spacing: 40) {

            if openContent {
                VStack {
                    HStack {
                        Image(systemName: "tag.fill")
                            .font(.title3)
                        Text(passTag == nil ? "新規タグ" : "タグ編集")
                            .font(.title)
                            .tracking(4)
                            .fontWeight(.semibold)
                    }

                    Rectangle()
                        .fill(colorScheme == .light ?
                              Color.black.gradient : Color.white.gradient)
                        .frame(width: 260, height: 1)

                    if containsName {
                        Text("※同じ名前のタグが存在します")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .padding(.top)
                    }

                    TextField("タグの名前を入力", text: $tagName)
                        .font(.title3)
                        .focused($focused, equals: true)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.vertical, 10)

                    Button(passTag == nil ? "追加" : "完了") {

                        // 🏷️タグ更新の場合
                        if let defaultTag = passTag {

                            var updateTagData = defaultTag
                            updateTagData.tagName = tagName

                            Task {
                                await tagVM.addOrUpdateTag(updateTagData, teamId: teamVM.team!.id)
                                await tagVM.updateTargetItemsTag(before: defaultTag,
                                                                 after: updateTagData,
                                                                 teamId: teamVM.team?.id,
                                                                 items: itemVM.items)
                                tagVM.activeTag = updateTagData
                            }

                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.passTag = updateTagData
                                show = false
                            }

                        // 🏷️タグ追加の場合
                        } else {
                            let createTagData = Tag(oderIndex: tagVM.tags.count,
                                                    tagName  : tagName,
                                                    tagColor : .gray)

                            withAnimation(.easeInOut(duration: 0.3)) {
                                Task {
                                    await tagVM.addOrUpdateTag(createTagData, teamId: teamVM.team!.id)
                                }
                                self.passTag = createTagData
                                show = false
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .transition(.slide)
                    .disabled(nameEmpty)
                    .disabled(containsName)
                    .onChange(of: tagName) { newValue in
                        if newValue.isEmpty {
                            nameEmpty = true
                        } else {
                            nameEmpty = false
                        }
                    }
                    .onChange(of: tagName) { newValue in
                        if passTag?.tagName != tagName &&
                            tagVM.tags.contains(where: {$0.tagName == tagName}) {
                            withAnimation(.easeInOut(duration: 0.3)) { containsName = true }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) { containsName = false }
                        }
                    }
                }
                .frame(width: 300, height: 250)
                .background {
                    RoundedRectangle(cornerRadius: 50)
                        .fill(colorScheme == .light ?
                              Color.white.gradient : Color.black.gradient)
                        .shadow(radius: 1, x: 1, y: 1)
                        .shadow(radius: 1, x: 1, y: 1)
                        .shadow(radius: 1, x: 1, y: 1)
                }
                .onTapGesture { focused = nil }

                Button {
                    /// dismiss
                    withAnimation(.easeInOut(duration: 0.3)) { show = false }
                } label: {
                    Label("閉じる", systemImage: "xmark.circle.fill")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.top)
            } // if showContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: 30)
        .background {
            Color.gray
                .opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture { focused = nil }
        }
        .onAppear {
            if let passTag {
                tagName = passTag.tagName
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.3)) { openContent = true }
            }
        }
    }
}

struct EditTagView_Previews: PreviewProvider {
    static var previews: some View {
        EditTagView(passTag: .constant(nil), show: .constant(true))
            .background {
                Image("background_1")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
    }
}
