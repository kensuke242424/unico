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
    
    let passTag: Tag?
    
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
                    Text(passTag == nil ? "タグの追加" : "タグの編集")
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
                
                Button("追加") {
                    if let passTag {
                        var updateTagData = passTag
                        updateTagData.tagName = tagName
                        tagVM.updateTagData(updateData : updateTagData,
                                            defaultData: passTag,
                                            teamID     : teamVM.team!.id)
                    } else {
                        var createTagData = Tag(oderIndex: tagVM.tags.count,
                                                tagName  : tagName,
                                                tagColor : .gray)
                        tagVM.addTag(tagData: createTagData, teamID: teamVM.team!.id)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(tagName.isEmpty ? true : false)
                .onChange(of: tagName) { newValue in
                    if newValue.isEmpty {
                        withAnimation(.easeInOut(duration: 0.3)) { nameEmpty = true }
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) { nameEmpty = false }
                    }
                }
                .onChange(of: tagName) { newValue in
                    if tagVM.tags.contains(where: {$0.tagName == tagName}) {
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
                withAnimation(.easeInOut(duration: 0.3)) { tagVM.showEdit = false }
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
            Color.black
                .opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { focused = nil }
        }
    }
}

struct EditTagView_Previews: PreviewProvider {
    static var previews: some View {
        EditTagView(passTag: nil)
            .background {
                Image("background_1")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
    }
}
