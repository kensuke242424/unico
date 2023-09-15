//
//  BackgroundCategoriesTagView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/07/12.
//

import SwiftUI

/// 背景画像のカテゴリ選択を管理するタグビュー
struct BackgroundCategoriesTagView: View {

    @EnvironmentObject var backgroundVM: BackgroundViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Namespace private var tagAnimation

    var body: some View {
        HStack {

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {

                    ForEach(BackgroundCategory.allCases, id: \.self) { category in

                        Text(category.categoryName)
                            .tracking(3)
                            .font(userDeviseSize == .small ? .body : .title3)
                            .fontWeight(.light)
                            .foregroundColor(backgroundVM.selectCategory == category ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background {
                                if backgroundVM.selectCategory == category {
                                    Capsule()
                                        .foregroundColor(userVM.memberColor.color3)
                                        .matchedGeometryEffect(id: "ACTIVETA", in: tagAnimation)
                                } else {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.6))
                                }
                            }
                            .contentShape(Capsule())
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.5,
                                                                 dampingFraction: 0.7,
                                                                 blendDuration: 0.7)) {
                                    backgroundVM.selectCategory = category
                                }
                            }
                    } // ForEath
                } // HStack
                .padding(.horizontal, 15)
            } // ScrollView
        }
    }
}
