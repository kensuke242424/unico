//
//  CommerceSheet.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/12.
//

import SwiftUI
import ResizableSheet

struct CommerceSheet: View {

        @Binding var commerceState: ResizableSheetState

    var body: some View {
        VStack {
            HStack {
                Text("合計")
                    .font(.title2.bold())
                    .opacity(0.6)
                    .offset(y: 3)
                    .padding(.trailing, 2)
                Text("10 個")
                    .font(.largeTitle.bold())

                Spacer()

                Button(
                    action: { commerceState = .hidden },
                    label: {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.green)
                            .frame(width: 80, height: 50)
                            .shadow(color: .gray, radius: 2)
                            .overlay {
                                Image(systemName: "arrowshape.turn.up.right.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .foregroundColor(.white)
                            }
                    }
                ) // Button
            } // HStack
            .frame(height: 100)
            .padding(.horizontal, 20)
        } // VStack 決済シートレイアウト
    }
}
//
//struct CommerceSheet_Previews: PreviewProvider {
//    static var previews: some View {
//
//        var windowScene: UIWindowScene? {
//            let scenes = UIApplication.shared.connectedScenes
//            let windowScene = scenes.first as? UIWindowScene
//            return windowScene
//        }
//        var resizableSheetCenter: ResizableSheetCenter? {
//            windowScene.flatMap(ResizableSheetCenter.resolve(for:))
//        }
//
//        return CommerceSheet()
//            .environment(\.resizableSheetCenter, resizableSheetCenter)
//    }
//}
