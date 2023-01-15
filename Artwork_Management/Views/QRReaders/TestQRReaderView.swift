//
//  TestQRReaderView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2023/01/16.
//

import SwiftUI

struct TestQRReaderView: View {
    @StateObject var qrReader = QRReader()
    var body: some View {
        QRReaderView(caLayer: qrReader.videoPreviewLayer)
    }
}

struct TestQRReaderView_Previews: PreviewProvider {
    static var previews: some View {
        TestQRReaderView()
    }
}
