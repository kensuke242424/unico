//
//  QRReader.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2023/01/16.
//

import UIKit
import AVFoundation

class QRReader: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {

    // カメラ用のAVsessionインスタンス作成
    private let AVsession = AVCaptureSession()
    @Published var qrData: String = ""
    @Published var isdetectQR: Bool = false

    // 外部からAVCaptureSessionの開始と停止が出来るように以下2つのメソッド追加
    func startSession() {
        if AVsession.isRunning { return }
        AVsession.startRunning()
    }

    func stopSession() {
        if !AVsession.isRunning { return }
        AVsession.stopRunning()
    }
}
