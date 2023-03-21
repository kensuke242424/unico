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
    @EnvironmentObject var tagVM : TagViewModel
    
    @Binding var passTag: Tag?
    @Binding var show: Bool
    
    @State private var tagName     : String = ""
    @State private var nameEmpty   : Bool = true
    @State private var containsName: Bool = false
    
    @FocusState var focused: Bool?
    
    var body: some View {
        VStack(spacing: 40) {
            
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
                    
                    if let defaultTag = passTag {
                        var updateTagData     = defaultTag
                        updateTagData.tagName = tagName
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            tagVM.updateTagData(updateData : updateTagData,
                                                defaultData: defaultTag,
                                                teamID     : teamVM.team!.id)
                            
                            self.passTag = updateTagData
                            show = false
                        }
                        
                    } else {
                        let createTagData = Tag(oderIndex: tagVM.tags.count,
                                                tagName  : tagName,
                                                tagColor : .gray)
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            tagVM.addTag(tagData: createTagData, teamID: teamVM.team!.id)
                            self.passTag = createTagData
                            show = false
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(nameEmpty)
                .disabled(containsName)
                .onChange(of: tagName) { newValue in
                    if newValue.isEmpty {
                        withAnimation(.easeInOut(duration: 0.3)) { nameEmpty = true }
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) { nameEmpty = false }
                    }
                }
                .onChange(of: tagName) { newValue in
                    if passTag == nil, tagVM.tags.contains(where: {$0.tagName == tagName}) {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: 30)
        .transition(AnyTransition.opacity.combined(with: .offset(y: 50)))
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
