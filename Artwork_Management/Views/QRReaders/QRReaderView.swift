//
//  QRReaderView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2023/01/16.
//

import SwiftUI

struct QRReaderView: UIViewControllerRepresentable {
    // 画像ベースのコンテンツを管理し、そのコンテンツに対してアニメーションを実行することができるオブジェクト。
    var caLayer: CALayer

    func makeUIViewController(context: UIViewControllerRepresentableContext<QRReaderView>) -> UIViewController {
        // UIKitアプリのビュー階層を管理するオブジェクト
        let viewController = UIViewController()

        // レイヤーをレイヤーのサブレイヤーリストに追加します。
        viewController.view.layer.addSublayer(caLayer)
        caLayer.frame = viewController.view.layer.frame

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        caLayer.frame = uiViewController.view.layer.frame
    }
}
