//
//  UpdateTeamDataView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2023/02/05.
//

import SwiftUI

struct UpdateTeamDataView: View {

    enum UpdateTeamFocused {
        case check
    }

    struct inputUpdateTeamData {
        var teamName: String = ""
        var captureImage: UIImage?
        var isShowPickerView: Bool = false
    }

    @State private var inputUpdateTeam = inputUpdateTeamData()
    @FocusState var updateTeamfocused: UpdateTeamFocused?

    var body: some View {
        VStack(spacing: 40) {
            Group {
                if let captureImage = inputUpdateTeam.captureImage {
                    UIImageCircleIcon(photoImage: captureImage, size: 150)
                } else {
                    Image(systemName: "photo.circle.fill").resizable().scaledToFit()
                        .foregroundColor(.white.opacity(0.5)).frame(width: 150)
                }
            }
            .onTapGesture { inputUpdateTeam.isShowPickerView.toggle() }
            .overlay(alignment: .top) {
                Text("チーム情報は後から変更できます。").font(.caption)
                .foregroundColor(.white.opacity(0.3))
                .frame(width: 200)
                .offset(y: -30)
            }

            TextField("", text: $inputUpdateTeam.teamName)
                .frame(width: 230)
                .focused($updateTeamfocused, equals: .check)
                .textInputAutocapitalization(.never)
                .multilineTextAlignment(.center)
                .background {
                    ZStack {
                        Text(updateTeamfocused == nil && inputUpdateTeam.teamName.isEmpty ? "チーム名を入力" : "")
                            .foregroundColor(.white.opacity(0.3))
                        Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                            .offset(y: 20)
                    }
                }
        }
    }
}

struct UpdateTeamDataView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateTeamDataView()
    }
}
