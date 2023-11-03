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
**◽️ユーザーのデザイン性が詰まった空間で在庫管理ができるシステム**  
**◽️特に用事がなくても、ついついアプリを起動して触ってしまうようなUI&UX**
***

これをアプリ価値を作る上での最大の目標とし、開発をしてきました。

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

今回このunicoというアプリを作っていく上で、  
「管理する」という基本的な機能に加えて、「眺める」というギャラリー的な視点でも  
ユーザーに楽しんでいただけるようなアプリを目指しました。

アプリ内のパーツを編集したり移動させたりといったカスタマイズ性としての楽しみと、  
ユーザーのアイテムが綺麗に見えるようなUIやアニメーションを意識して実装しています。

<br>

### 1.奥行きのあるアイテムカードのスクロール操作  

![Nov-02-2023 15-36-58](https://github.com/kensuke242424/unico/assets/100055504/0ce8542f-b326-4562-85b5-eccdf5694f1b)  

[`rotation3DEffect`](https://developer.apple.com/documentation/swiftui/view/rotation3deffect(_:axis:anchor:anchorz:perspective:))を用いて、アイテムカードが奥に畳まれていくようなスクロールアニメーションを実装しています。

https://github.com/kensuke242424/unico/blob/61255ebf9eac0cf6d4022455ef95653d0bb5cd9c/Artwork_Management/Views/TabViews/ItemTabViews/ItemTabView.swift#L249-L368

***

<br>

### 2.選択アイテム以外の要素をマスクで隠し、情報の閲覧に集中できるように

![Nov-02-2023 16-16-47](https://github.com/kensuke242424/unico/assets/100055504/fd437af6-0448-431a-b6fb-4906929fa195)

ユーザーによってアイテムが選択されると、  
Viewファイル内の状態変数`selectedItem`に選択アイテムが保持され、  
それ以外の要素を隠すマスク付き詳細Viewを出現させます。  

また、動きのあるアイテムカードの振る舞いは[`matchedGeometryEffect`](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:))によって実装しています。  

https://github.com/kensuke242424/unico/blob/61255ebf9eac0cf6d4022455ef95653d0bb5cd9c/Artwork_Management/Views/TabViews/ItemTabViews/ItemTabView.swift#L344-L359

***

<br>

### 3.複数ジェスチャーを使った直感的なカスタマイズ操作

![Nov-02-2023 16-42-06](https://github.com/kensuke242424/unico/assets/100055504/a5a19944-1751-406c-bc67-f1a328f48ec2)

Homeタブ画面での編集可能パーツには、

- ドラッグ
- ロングタップ
- ピンチアウト

これら３種のジェスチャーを持たせる必要がありました。

各ジェスチャーを[`simultaneousGesture`](https://developer.apple.com/documentation/swiftui/simultaneousgesture)で包んだカスタムモディファイアを作成し、  
パーツに付与することで、複数ジェスチャーを共存させています。

https://github.com/kensuke242424/unico/blob/61255ebf9eac0cf6d4022455ef95653d0bb5cd9c/Artwork_Management/Views/TabViews/HomeTabViews/HomeTabView.swift#L41-L64

https://github.com/kensuke242424/unico/blob/61255ebf9eac0cf6d4022455ef95653d0bb5cd9c/Artwork_Management/Helpers/CustomDragGesture.swift#L10-L34

***

<br>

### 4.在庫処理をまとめて操作できるカートシステム

![Nov-04-2023 01-36-27](https://github.com/kensuke242424/unico/assets/100055504/91b5fd70-4101-413e-aa3b-5302862747f2)

複数のアイテムをまとめて在庫処理できるシステムとして、カート機能を実装しました。  
こちらのハーフモーダルビュー[`Resizable Sheet`](https://github.com/mtj0928/ResizableSheet)は、  
[まつじ](https://twitter.com/mtj_j)さんというエンジニアの方が個人で作成しているライブラリです。  
（実装が中々上手くいかなくて、でもどうしても使いたくて、本人にDMを送って使い方を教わったのは良い思い出です。）  

少し独特にニョキっと画面から出現するので、大変気に入っています。

https://github.com/kensuke242424/unico/blob/61255ebf9eac0cf6d4022455ef95653d0bb5cd9c/Artwork_Management/Views/TabViews/ParentTabView.swift#L240-L332

- 処理アイテムリストの可変型シート
- 合計表示と処理の決定ボタンを持つ固定型シート

これら二つのシートを重ね合わせてコンパクトに配置し、  
アイテムカードの操作とカート操作を両立できるようにしています。

![Nov-04-2023 01-40-43](https://github.com/kensuke242424/unico/assets/100055504/41650294-f50a-45eb-b338-ca688ad7a9fb)

https://github.com/kensuke242424/unico/blob/61255ebf9eac0cf6d4022455ef95653d0bb5cd9c/Artwork_Management/Views/TabViews/ItemTabViews/CartItemsSheet.swift#L11-L230

https://github.com/kensuke242424/unico/blob/61255ebf9eac0cf6d4022455ef95653d0bb5cd9c/Artwork_Management/Views/TabViews/ItemTabViews/CommerceSheet.swift#L12-L135

***
<br>

### --- 実装から感じた課題点 ---

**1. ポピュラーではないUIにおけるUXとのバランス**

今回のようにポピュラーなUIとは少し離れたレイアウトを実装した時、  
ユーザーにとっては、普段慣れている感覚とは違う操作方法やパーツの配置はストレスになり、  
アプリから離脱してしまう原因となる可能性に十分気をつけなければならない。  
「次どう操作すればいいのかわからない」と感じるポイントをユーザー目線で探って、  
操作チュートリアルを挿入するなど、今後対策していく必要がある。
<br>

**2. SwiftUIの自動的な描画更新のコントロール**  

動的なレイアウトを実装するため、Viewファイルの中で`@State`によるプロパティの状態管理が随所で行われている。  
これによってか、意図しないタイミングや場所で画面の再描画が走ってしまったり、  
更新処理のバッティング（？）よってアニメーションが正常に動作しないといったことがしばしば発生した。  
また、iOS17でのみ発生するようなアニメーションの不具合も発見している。  
これらをうまくコントロールしていくためには、SwiftUIをはじめ、  
各メソッドやAPIが内部で行なっている処理を知ることが必要だと感じた。

また、状態変数を含めたプロパティの数が増えれば増えるほど、  
管理が難しくなっていくことに開発の後半になればなるほど悩んだ。  
思考コストが少ない、管理がしやすいプログラムの書き方の引き出しが必要。

<br>

## 全体の総括/自身への教訓

- 客観的な目を失うな、お前の個人的こだわりはユーザーの満足度に関係ない
- 同じ部分でいつまでも悩むな、他のアプローチを試せ
- 適切なコメントログは未来の自分を救う
- その場しのぎなコーディングは未来の憎しみを生む
- その場しのぎな変数名は未来の誤解を生む
- アプリ開発最高

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


