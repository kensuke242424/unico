//
//  CustomImagePicker.swift
//  PhotoCroppingSampleApp
//
//  Created by Kensuke Nakagawa on 2023/03/01.
//

import SwiftUI
import PhotosUI

// MARK: View Extensions
extension View {
    @ViewBuilder
    func cropImagePicker(option: Crop,
                         show: Binding<Bool>,
                         croppedImage: Binding<UIImage?>) -> some View {

        CustomImagePicker(option: option, show: show, croppedImage: croppedImage) {
            self
        }
    }

    /// - For Making it Simple and easy to use.
    @ViewBuilder
    func frame(_ size: CGSize) -> some View {
        self
            .frame(width: size.width, height: size.height)
    }

    /// 物理的な衝撃をシミュレートするハプティクスを作成する、具体的なフィードバックジェネレーターのサブクラスです。
    /// 衝撃が発生したことを示すには、衝撃フィードバックを使用します。
    /// 例えば、ユーザーインターフェイスのオブジェクトが他のオブジェクトと衝突したときや、所定の位置にスナップしたときに、
    /// インパクト・フィードバックをトリガーすることができます。
    func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

fileprivate struct CustomImagePicker<Content: View>: View {
    var content: Content
    var option: Crop
    @Binding var show: Bool
    @Binding var croppedImage: UIImage?
    init(option: Crop, show: Binding<Bool>, croppedImage: Binding<UIImage?>,
         @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self._show = show
        self._croppedImage = croppedImage
        self.option = option
    }

    /// - View Propweties
    @State private var photosItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showDialog: Bool = false
    @State private var selectedCropType: Crop = .circle
    @State private var showCropView: Bool = false
    var body: some View {
        content
            /// iOS16~
            /// photosPicker(isPresented:selection:matching:preferredItemEncoding:)
            /// PhotosPickerItemを選択するPhotosピッカーを提示します。
            .photosPicker(isPresented: $show,
                          selection: $photosItem,
                          matching: .images)
            // 写真が選ばれた時の処理
            .onChange(of: photosItem) { newValue in
                if let newValue {
                    Task {
                        if let imageData = try? await newValue.loadTransferable(type: Data.self),
                           let image = UIImage(data: imageData) {
                            await MainActor.run(body: {
                                selectedImage = image
                            })
                        }
                    }
                }
            }
            // 新しい写真の格納を検知したらクロップビューを発火
            .onChange(of: selectedImage) { newImage in
                if newImage != nil {
                    showCropView.toggle()
                }
            }
            .fullScreenCover(isPresented: $showCropView) {
                /// When exited Clearing the old selected Image
                ///  終了時 古い選択画像をクリアする
                selectedImage = nil
            } content: {
                CropView(crop: option, image: selectedImage) { croppedImage, status in
                        // クロップ処理によって生成されたUIImageが存在すればcroppedImageプロパティに渡す(バインディング)
                    if let croppedImage {
                        self.croppedImage = croppedImage
                    }
                }
            }
    }
}

struct CropView: View {
    var crop: Crop
    var image: UIImage?
    var onCrop: (UIImage?, Bool) -> ()

    /// - View Property
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    @GestureState private var isInteracting: Bool = false

    var body: some View {

        NavigationStack {
            ImageView()
                .navigationTitle("写真の切り取り")
                .navigationBarTitleDisplayMode(.inline)
                // iOS16~
                .toolbarBackground(.visible, for: .navigationBar)
                // iOS16~
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Color.black, for: .navigationBar)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Color.black
                        .ignoresSafeArea()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {

                        Button {
                            /// Conberting View to Image (Native iOS 16+ )
                            /// SwiftUIのビューから画像を作成するオブジェクトです。
                            /// SwiftUI のビューからビットマップ画像データをエクスポートするために
                            ///  ImageRenderer を使用します。ビューでレンダラーを初期化し、
                            ///  render(rasterizationScale:renderer:)メソッドを呼び出すか、
                            ///  レンダラーのプロパティを使用して CGImage、NSImage、または
                            ///   UIImage を作成することによって、必要に応じて画像をレンダリングすることができます。
                            let rendeler = ImageRenderer(content: ImageView(hideGrids: true))
                            rendeler.proposedSize = .init(crop.size())
                            if let image = rendeler.uiImage {
                                onCrop(image, true)
                            } else {
                                onCrop(nil, false)
                            }
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                }
        }
    }

    /// 画像のView
    /// hideGridsは、画像を編集時かレンダリング時かで、グリッド線の有無を分岐するための引数
    @ViewBuilder
    func ImageView(hideGrids: Bool = false) -> some View {

        let cropSize = crop.size()

        GeometryReader {
            let size = $0.size

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    // GeometryReaderとcoordenateSpaceを使った、画像が枠からはみ出た分を枠内に戻す処理
                    .overlay(content: {
                        GeometryReader { proxy in
                            // サイズ拡大縮小ジェスチャーで定義されたcoordinateSpace値を使う
                            let rect = proxy.frame(in: .named("CROPVIEW"))

                            Color.clear
                                .onChange(of: isInteracting) { newValue in
                                    /// - true Dragging
                                    /// - false Stopped Dragging
                                    /// With the Help of GeometryReader (GeometryReaderの力を借りて)
                                    /// We can now read the minX, Y and maxX, Y of the Image(これで、画像のminX, YとmaxX, Yを読み取ることができるようになりました。)
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        // 画像のドラッグ最終位置が横にはみ出ていれば戻す
                                        if rect.minX > 0 {
                                            /// - Resetting to Last Location
                                            offset.width = offset.width - rect.minX
                                            haptics(.medium)
                                        }
                                        // 画像のドラッグ最終位置が縦にはみ出ていれば戻す
                                        if rect.minY > 0 {
                                            /// - Resetting to Last Location
                                            offset.height = offset.height - rect.minY
                                            haptics(.medium)
                                        }

                                        /// - Doing the Same for maxX, Y
                                        if rect.maxX < size.width {
                                            /// - Resetting to Last Location
                                            offset.width = (rect.minX - offset.width)
                                            haptics(.medium)
                                        }

                                        if rect.maxY < size.height {
                                            /// - Resetting to Last Location
                                            offset.height = (rect.minY - offset.height)
                                            haptics(.medium)
                                        }

                                    }
                                }
                        }
                    })
                    .frame(size)
                    // ドラッグが終了した時点の最終位置を保存
                    .onChange(of: isInteracting) { newValue in
                        /// true dragging
                        /// false Stopped Draging
                        if !newValue {
                            lastStoredOffset = offset
                        }
                    }
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        // 画像のグリッド線
        .overlay {
            // 画像のクロップ、レンダリング時にはグリッドを消す
            if !hideGrids {
                Grids()
            }
        }
        ///coordinateSpace(name:)
        ///ビューの座標空間に名前を割り当て、他のコードがポイントやサイズなどの寸法を名前付きの空間と相対的に操作できるようにします。
        .coordinateSpace(name: "CROPVIEW")
        // ドラッグによる画像の移動
        .gesture(
            DragGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    let translation = value.translation
                    offset = CGSize(width: translation.width + lastStoredOffset.width,
                                    height: translation.height + lastStoredOffset.height)
                })
        )
        // 画像の拡大、縮小
        .gesture(
            // MagnificationGesture_画像のピンチイン・ピンチアウトに使う(Option + ドラッグで確認)
            MagnificationGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    let updateScale = value + lastScale
                    // 画像が元のスケール以上に小さくならないようにしている。拡大のみ
                    scale = (updateScale < 1 ? 1 : updateScale)
                }).onEnded({ value in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if scale < 1 {
                            scale = 1
                            lastScale = 0
                        } else {
                            // 元画像のscaleを１として、1 + n の「n」部分をlastScaleとして保存
                            lastScale = scale - 1
                        }
                    }
                })
        )
        .frame(cropSize)
        .cornerRadius(crop == .circle ? cropSize.height / 2 : 0)
    }

    @ViewBuilder
    func Grids() -> some View {
        ZStack {
            HStack {
                ForEach(1...5, id: \.self) { _ in
                        Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)
                }
            }
            VStack {
                ForEach(1...8, id: \.self) { _ in
                        Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }
}

struct CustomImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        CropView(crop: .circle, image: UIImage(named: "sample_image1")) { _, _ in

        }
    }
}
