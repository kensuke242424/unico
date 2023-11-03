# 在庫管理アプリ『unico』
***
**『 ユニークな空間は、在庫管理をもっと楽しくする。 』**
***
ユーザーの商品/作品が持っている"個性"や"色"を反映させることができる、  
外観のカスタマイズ性を持たせた在庫管理アプリです。
![スクリーンショット 2023-10-10 16 35 16のコピー](https://github.com/kensuke242424/unico/assets/100055504/daedf12f-7bfe-4469-829f-0270f917a72e)
<br>
<br>
## 🍎アプリのダウンロード（iOSのみ）

##### <ログイン方法について>

> ◽️アカウント登録時に入力したアドレス宛に、アカウント認証用のリンクが届きます。
> ◽️アドレス登録不要のゲストログインも用意しています。ぜひご利用ください。

[![apple store リンクボタン](https://user-images.githubusercontent.com/68992872/204145956-f5cc0fa8-d4c9-4f2c-b1d4-3c3b1d2e2aba.png)](https://apps.apple.com/us/app/unico-%E3%81%8A%E3%81%97%E3%82%83%E3%82%8C%E3%81%AB%E3%83%A2%E3%83%8E%E3%82%92%E7%AE%A1%E7%90%86/id1663765686)

PCの方はQRからどうぞ！

![unico_store_qrのコピー](https://github.com/kensuke242424/unico/assets/100055504/f7f2b942-1368-44ea-9866-cd2cdce31afa)

##### ◽️対応OS     : iOS16.0~
##### ◽️アカウント登録: メールアドレス
##### ◽️ゲストログイン: 有り

<br>

## 🌐サービスWebサイト

https://unicoapp.wixsite.com/mysite  
[<img width="541" alt="スクリーンショット 2023-10-16 2 01 35" src="https://github.com/kensuke242424/unico/assets/100055504/50dbe0bb-3664-4404-ac99-32d0532e7280">](https://unicoapp.wixsite.com/mysite)

<br>

## 🎬アプリの動作/主な機能4つ

### 1.アイテム管理機能
![Oct-17-2023 16-32-03](https://github.com/kensuke242424/unico/assets/100055504/8e3d2939-85ab-4036-8cd9-bb9f8ecc3c2f)

### 2.カート・通知機能
![Oct-17-2023 22-33-10](https://github.com/kensuke242424/unico/assets/100055504/82e52089-0f15-4e3d-a80d-c6ac4d80eb2e)

### 3.外観のカスタマイズ
![Oct-17-2023 18-22-24](https://github.com/kensuke242424/unico/assets/100055504/f8811b94-e1f5-4e6a-a656-4a9f0cb2a5b7)

### 4.チーム参加/招待
![Oct-17-2023 18-54-21](https://github.com/kensuke242424/unico/assets/100055504/0f8b8769-b31c-48da-b872-3b813c269613)

<br>

## 👤想定ユーザー

- **自身の作品/商品を持ち、販売や在庫管理をしている活動者**
  - ミュージシャン・バンドマンなど音楽家
  - ハンドメイド作家
  - その他個人やチームで活動しているアーティストなど

  <br>

## 📨このアプリを作った背景と想い

ご覧いただきありがとうございます！   
アプリ開発者の中川と申します。  

私は16歳の時から地元の同級生4人とバンドを組み、約9年間にわたり音楽活動をしてきました。  
ライブの日にはたくさんのCDやグッズを車に積み込んで現地へ行き、  
ライブ後はすぐに物販エリアへ駆けつけ、お客様とコミュニケーションを取りながら、  
気に入っていただけた時には作品やチケットを買ってもらう、といった生活をしておりました。 

<img width="772" alt="スクリーンショット 2023-10-28 19 23 40" src="https://github.com/kensuke242424/unico/assets/100055504/dd9ad0ff-f146-4771-baef-e4ac420c5cc2">

<br>

私たちのようなものを含め、自身で作品/商品を作って販売活動をしている方々には、  
その人たちだけのユニークなデザイン、アートワーク、こだわりが詰まっています。

> "作品"や"商品"に込めたオリジナリティを感じながら、  
> 個人やチームでの在庫管理が出来るようなアプリがあればいいのにな??

当時のそんな思いを形にしたのが、unicoというアプリです。

***
**◽️ユーザーが持つ個性やアートワークをアプリに反映でき、お気に入りの空間で在庫管理ができるシステム**  
**◽️特に用事がなくても、ついついアプリを起動して触ってしまうようなUI&UX**
***

これをアプリ価値としての最大の目標とし、開発をしてきました。

unicoを利用しているユーザー同士で、  
お互いの画面を見せ合いたくなるような、  
ユーザー個々にそんな"愛着"が生まれるアプリを目指して、
今後もアップデートを続けていきます。

<br>

## 🔧使用技術

#### ◽️開発環境
- Xcode `15.0`
- Swift `5.8.1`
- macOS Ventura `13.5.2`

#### ◽️アーキテクチャ
- MVVM

#### ◽️UIフレームワーク
- SwiftUI

#### ◽️使用ライブラリ、ツール
- [firebase-ios-sdk `10.15.0`](https://github.com/firebase/firebase-ios-sdk)
  - [Cloud Firestore](https://firebase.google.com/docs/firestore?hl=ja)（アプリ内データの保存/更新/削除）
  - [Authentication](https://firebase.google.com/docs/auth?hl=ja)（アカウント登録情報の管理）
  - [Cloud Storage](https://firebase.google.com/docs/storage?hl=ja)（背景やアイコンなど画像データの保存）
  - [Dynamic Links](https://firebase.google.com/docs/dynamic-links?hl=ja) （メールリンクでのアカウント認証）
    
- [SDWebImageSwiftUI `2.2.2`](https://github.com/SDWebImage/SDWebImageSwiftUI)（サーバー内の画像データを非同期取得/表示）
- [swiftui-introspect `0.6.0`](https://github.com/siteline/swiftui-introspect/tree/main)（SwiftUIコンポーネント内で構築されているUIKitソースのオプション変更/更新）
- [Resizable Sheet](https://github.com/mtj0928/ResizableSheet)（カートとして表示されるハーフモーダル画面）

#### ◽️ライブラリ管理
- [Swift Package Manager](https://github.com/apple/swift-package-manager)

<br>

## 🗺️アプリの設計

### 1.画面遷移フロー

[Figmaの全体像>>](https://www.figma.com/file/HcpcVbLFT195io673bv2Cs/unico-%E8%A8%AD%E8%A8%88%E5%9B%B3?type=whiteboard&node-id=0%3A1&t=ZFTwPEQdZsNGcLwm-1)

#### ◽️ログイン/アカウント作成/チーム作成
<img width="879" alt="スクリーンショット 2023-10-15 17 42 15" src="https://github.com/kensuke242424/unico/assets/100055504/1ba84bad-16ca-4fbf-bf39-e5313d7ae5be">

#### ◽️メイン画面
<img width="920" alt="スクリーンショット 2023-10-15 17 42 39" src="https://github.com/kensuke242424/unico/assets/100055504/0a118811-5015-4b41-abd7-cc7929783b51">

<br>

### 2.シーケンス図
<img width="1065" alt="スクリーンショット 2023-10-19 1 29 40" src="https://github.com/kensuke242424/unico/assets/100055504/161f7f5e-8e6b-4e77-a506-212579d73798">
<img width="1110" alt="スクリーンショット 2023-10-19 1 29 55" src="https://github.com/kensuke242424/unico/assets/100055504/79d1edaa-fb5d-4563-bc78-10ae12761971">

<br>

### 4.ER図
<img width="637" alt="スクリーンショット 2023-10-26 2 10 57" src="https://github.com/kensuke242424/unico/assets/100055504/7cdb69fd-2907-4bf2-bf03-80c6886a885d">

<br>
<br>
<br>

# 開発の振り返り

<br>

## ✅こだわったポイント/力を入れた実装

### ポイント1: アニメーションやジェスチャーを活用した触り心地の良いUI

◽️[`rotation3DEffect`](https://developer.apple.com/documentation/swiftui/view/rotation3deffect(_:axis:anchor:anchorz:perspective:))を用いた奥行きのあるアイテムカード操作  

![Nov-02-2023 15-36-58](https://github.com/kensuke242424/unico/assets/100055504/0ce8542f-b326-4562-85b5-eccdf5694f1b)

https://github.com/kensuke242424/unico/blob/61255ebf9eac0cf6d4022455ef95653d0bb5cd9c/Artwork_Management/Views/TabViews/ItemTabViews/ItemTabView.swift#L249-L368

<br>

◽️[`matchedGeometryEffect`](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:))を用いたアイテム詳細への動的な遷移モーション

![Nov-02-2023 16-16-47](https://github.com/kensuke242424/unico/assets/100055504/fd437af6-0448-431a-b6fb-4906929fa195)

https://github.com/kensuke242424/unico/blob/61255ebf9eac0cf6d4022455ef95653d0bb5cd9c/Artwork_Management/Views/TabViews/ItemTabViews/ItemTabView.swift#L344-L359

<br>

◽️[`simultaneousGesture`](https://developer.apple.com/documentation/swiftui/simultaneousgesture)を用いた複数ジェスチャーの共存

![Nov-02-2023 16-42-06](https://github.com/kensuke242424/unico/assets/100055504/a5a19944-1751-406c-bc67-f1a328f48ec2)

https://github.com/kensuke242424/unico/blob/61255ebf9eac0cf6d4022455ef95653d0bb5cd9c/Artwork_Management/Views/TabViews/HomeTabViews/HomeTabView.swift#L41-L64

https://github.com/kensuke242424/unico/blob/61255ebf9eac0cf6d4022455ef95653d0bb5cd9c/Artwork_Management/Helpers/CustomDragGesture.swift#L10-L34

<br>

### ポイント2: 複数人でのデータ共有 & 複数チームへの所属システム
<br>

本アプリにおける想定ユーザーの使用ケースとして、以下のようなケースが考えられました。

> 1.ユーザーが複数のチームに在籍しており、チームごとに別々でアイテム管理したい  
> 2.一つのチームに複数のメンバーが在籍しており、メンバーと一緒にアイテム管理したい

これらのケースに対応できるように、データ設計をしています。

<br>

また、Firebaseからのデータ読み取り量をスリムにするため、以下のようなデータ構造にしています。

> 1.「User」オブジェクトは、自身が所属するチーム群の"最小限の情報"を保持する「JoinTeam」オブジェクトを持つ  
> 2.「Team」オブジェクトは、自身に所属しているメンバー群の"最小限の情報"を保持する「JoinMember」オブジェクトを持つ

これにより、アプリ起動のたびに「所属メンバー」「所属チーム」全てのドキュメントを叩く必要がなくなり、  
「User」「Team」ドキュメントの二つを引っ張ってくるだけで、UI表示に必要な情報を全て満たせるようにしています。

<br>

### ◽️総括/今後に活かす点

- aaa
- bbb
- ccc

<br>

# 最後に

### 👤開発者の情報

- **X（旧Twitter）**  
https://twitter.com/kenchan2n4n

- **私について**  
https://unicoapp.wixsite.com/mysite/about-5

<br>

### 🖊️技術発信

iOSアプリ開発スクール様が運営している技術ブログにて、  
主にSwiftUIコンポーネントなどに関しての記事を書かせていただいています。

https://blog.code-candy.com/category/swiftui/

<br>

### 🛠️README構築ツール

- [GIPHY CAPTURE](https://giphy.com/apps/giphycapture)（アプリの動作のgif撮影）
- [Figma](https://www.figma.com/files/recents-and-sharing/recently-viewed?fuid=1294561477219333460)（画面遷移フロー）
- [GitMind](https://gitmind.com/app/templates?lang=jp)（シーケンス図）
- [draw.io](https://app.diagrams.net/)（ER図）


