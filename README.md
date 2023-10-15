# unico
ユーザーの"個性"や"色"を反映させることができる、  
カスタマイズ性に重点を置いた在庫管理アプリです。

![スクリーンショット 2023-10-10 16 35 16のコピー](https://github.com/kensuke242424/unico/assets/100055504/daedf12f-7bfe-4469-829f-0270f917a72e)
<br>
<br>
## 🍎アプリのダウンロード

### App Store:
https://onl.bz/nPb5KTg

PCの方はこちらから↓

![unico_store_qrのコピー](https://github.com/kensuke242424/unico/assets/100055504/f7f2b942-1368-44ea-9866-cd2cdce31afa)

##### <ログイン方法について>

> ◽️本アプリではログイン機能としてFirebaseの[Dynamic Links](https://firebase.google.com/docs/dynamic-links?hl=ja)を利用しています。  
> 　入力メールアドレス宛に届くリンクからアプリに再アクセスすることで、アカウント認証を行います。  
> ◽️アドレス登録不要の簡易ログインも用意しています。ぜひご利用ください。
<br>

## 🌐サービスWebサイト
https://unicoapp.wixsite.com/mysite

<br>

## 🔧使用技術

#### ◽️開発言語
- Swift `5.8.1`

#### ◽️アーキテクチャ
- MVVM

#### ◽️UIフレームワーク
- SwiftUI

#### ◽️使用ライブラリ、ツール
- [firebase-ios-sdk `10.15.0`](https://github.com/firebase/firebase-ios-sdk)
  - [Firestore Database]()
  - [Authentication](https://firebase.google.com/docs/auth?hl=ja)
  - [Cloud Storage](https://firebase.google.com/docs/storage?hl=ja)
  - [Dynamic Links](https://firebase.google.com/docs/dynamic-links?hl=ja) （※2025.8.25よりサービス停止）
    
- [SDWebImageSwiftUI `2.2.2`](https://github.com/SDWebImage/SDWebImageSwiftUI)
- [swiftui-introspect `0.6.0`](https://github.com/siteline/swiftui-introspect/tree/main)
- [Resizable Sheet](https://github.com/mtj0928/ResizableSheet)

#### ◽️ライブラリ管理
- [Swift Package Manager](https://github.com/apple/swift-package-manager)

<br>

# 📦このアプリについて

## 想定ユーザー
- aaa
- bbb
- ccc
<br>

## ユーザーが抱える課題
- aaa
- bbb
- ccc
<br>

## ER図

準備中

## 画面遷移図

#### - ログイン画面周り -
<img width="660" alt="スクリーンショット 2023-10-14 16 16 30" src="https://github.com/kensuke242424/unico/assets/100055504/0ecf250f-249c-4773-b905-a17b0c02c7a8">

#### - メイン画面周り -
<img width="759" alt="スクリーンショット 2023-10-15 16 49 06" src="https://github.com/kensuke242424/unico/assets/100055504/d3be656c-75c5-4490-bcd0-8b58f4e4d7b1">





## このアプリを作った背景と想い

***
**『 ユーザーの"個性"や"デザイン性"を反映させられる在庫管理アプリ。 』**
***

このようなアプリのコンセプトに至ったのは、  
私自身が大阪を拠点にバンドを組んで音楽活動を行い、  
活動の中でCDやグッズを販売していた経験が大きな動機となっています。

在庫管理と情報共有のために、当時色々な在庫管理アプリを試しましたが、

◽️食品など日用品の管理に特化したアプリ  
◽️企業の利用を想定したデザインやUIUXのアプリ  

といったものが多く、中間的な位置付けのアプリが中々ありませんでした。

> "作品"や"商品"に込められた  
> オリジナルな世界観やイメージを、  
> アプリの中に反映させることができて、  
> その空間の中で、手軽に、気持ちよく、  
> 個人やチームでの在庫管理が出来るようアプリが欲しいな。

そんな当時の思いを形にしたのが、unicoというアプリです。

unicoを利用しているユーザー同士で、  
お互いのアイテム管理画面を見せ合いたくなるような、  
そんな"愛着"が生まれるアプリを目指して、今後もアップデートを続けていきます。


