//
//  PHPickerView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI
import PhotosUI

struct PHPickerView: UIViewControllerRepresentable {

    @Binding var selectImage: UIImage?
    @Binding var isShowSheet: Bool

    class Coordinator: NSObject, PHPickerViewControllerDelegate {

        var parent: PHPickerView

        init(parent: PHPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

            guard let result = results.first else {
                print("Error: guard let result = results.first")
                self.parent.isShowSheet = false
                return
            }

            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, _) in
                if let unwrapImage = image as? UIImage {
                    print("PHPickerView_UIImage取得成功: \(unwrapImage)")

                    self.parent.selectImage = unwrapImage
                } else {
                    print("Error: image as? UIImage")
                }
            }
            parent.isShowSheet = false
        } // func picker
    } // Coordinator

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<PHPickerView>) -> PHPickerViewController {

        // PHPickerViewControllerのカスタマイズ
        var configuration = PHPickerConfiguration()

        // 静止画を選択
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)

        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PHPickerView>) {
        // 処理なし
    }

}
