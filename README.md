# 在庫管理アプリ『unico』
ユーザーの商品/作品が持っている"個性"や"色"を反映させることができる、  
外観のカスタマイズ性を持たせた在庫管理アプリです。

![スクリーンショット 2023-10-10 16 35 16のコピー](https://github.com/kensuke242424/unico/assets/100055504/daedf12f-7bfe-4469-829f-0270f917a72e)
<br>
<br>
## 🍎アプリのダウンロード（iOSのみ）

##### ◽️ログイン方法 : メールアドレス
##### ◽️ゲストログイン: 有り

[![apple store リンクボタン](https://user-images.githubusercontent.com/68992872/204145956-f5cc0fa8-d4c9-4f2c-b1d4-3c3b1d2e2aba.png)](https://apps.apple.com/us/app/unico-%E3%81%8A%E3%81%97%E3%82%83%E3%82%8C%E3%81%AB%E3%83%A2%E3%83%8E%E3%82%92%E7%AE%A1%E7%90%86/id1663765686)

PCからの方はこちらをどうぞ！

![unico_store_qrのコピー](https://github.com/kensuke242424/unico/assets/100055504/f7f2b942-1368-44ea-9866-cd2cdce31afa)

##### <ログイン方法について>

> ◽️本アプリではログイン機能としてFirebaseの[Dynamic Links](https://firebase.google.com/docs/dynamic-links?hl=ja)を利用しています。  
> 　入力メールアドレス宛に届くリンクからアプリケーションに再アクセスします。
> ◽️アドレス登録不要のゲストログインも用意しています。ぜひご利用ください。

<br>

## 🌐サービスWebサイト

https://unicoapp.wixsite.com/mysite  
[<img width="541" alt="スクリーンショット 2023-10-16 2 01 35" src="https://github.com/kensuke242424/unico/assets/100055504/50dbe0bb-3664-4404-ac99-32d0532e7280">](https://unicoapp.wixsite.com/mysite)

<br>

## 🧭コンセプト

***
**『 ユニークな空間は、在庫管理をもっと楽しくする。 』**
***

#### 機能要件

- [x] アイテムの情報管理ができる
- [x] アプリ内の外観をカスタマイズできる
- [x] 複数人でデータを編集共有できる
- [x] 複数のチームに所属できる

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

## 🗺️アプリの設計

### 1.画面遷移フロー

#### ◽️ログイン/アカウント作成/チーム作成
<img width="879" alt="スクリーンショット 2023-10-15 17 42 15" src="https://github.com/kensuke242424/unico/assets/100055504/1ba84bad-16ca-4fbf-bf39-e5313d7ae5be">

#### ◽️メイン画面
<img width="920" alt="スクリーンショット 2023-10-15 17 42 39" src="https://github.com/kensuke242424/unico/assets/100055504/0a118811-5015-4b41-abd7-cc7929783b51">

<br>

### 2.シーケンス図
<img width="1065" alt="スクリーンショット 2023-10-19 1 29 40" src="https://github.com/kensuke242424/unico/assets/100055504/161f7f5e-8e6b-4e77-a506-212579d73798">
<img width="1110" alt="スクリーンショット 2023-10-19 1 29 55" src="https://github.com/kensuke242424/unico/assets/100055504/79d1edaa-fb5d-4563-bc78-10ae12761971">

<br>

### 3.MVVM設計

<br>

### 4.ER図
<img width="615" alt="スクリーンショット 2023-10-17 23 04 21" src="https://github.com/kensuke242424/unico/assets/100055504/28acc15c-cf55-48d8-aac8-4da182dd96b0">

#### ◽️エンティティ詳細

##### 👤ユーザー関連データ
| エンティティ名 | 用途 |
----|---- 
| User | ユーザーに関するデータ（名前,アイコンURL,etc...）を保持する。1アカウントにつき1つ、Userデータを持つ。 |
| JoinTeam | ユーザーが所属するチームの一部データ（名前、アイコン）および、ユーザーが所属チームごとで設定したカスタマイズ（背景,Home画面パーツ編集など）の内容を保持する。このエンティティはFirestore内でuserドキュメントのサブコレクションとして保存される。 |
| HomeEdit | Home画面における、2つのパーツの編集設定を保持する。所属チームごとで別々の設定が保持される。 |
| NowTimeNewsPart | Home画面における、現在時刻を表示するパーツのエディット（サイズ,位置,表示/非表示）を保持する。所属チームごとで別々の設定が保持される。 |
| TeamNewsPart | Home画面における、現在の操作チームに関する情報を表示するパーツのエディット（サイズ,位置,表示/非表示）を保持する。所属チームごとで別々の設定が保持される。 |
| Background | アプリ内のサンプル背景データおよび、ユーザーが自身の画像フォルダから保存した背景データを保持する。 |

##### 📦チーム関連データ
| エンティティ名 | 用途 |
----|---- 
| Team | アイテムやタグなど、チームメンバー間で"共有"のデータを保持する。ユーザーは複数のチームデータを作成可能。 |
| JoinUser | チームに所属しているユーザーの一部データ（名前、アイコン）および、チーム内で発生した追加,更新,削除に関するログを保持する。このエンティティはFirestore内でteamドキュメントのサブコレクションとして保存される。 |
| Item | ユーザーがチーム内に保存したアイテムに関する情報を保持する。 |
| Tag | アイテムのカテゴリを整理するためのタグデータ。1つのItemに1つのタグ情報を持つ。 |
| Log | チーム内で発生した各データの追加,更新,削除内容を履歴として保持する。各メンバーに発信される通知機能は、このLogデータの内容を用いて作成される。 |

<br>

# 最後に

<br>

## 📨このアプリを作った背景と想い

***
**『 ユニークな空間は、在庫管理をもっと楽しくする。 』**
***

このようなアプリのコンセプトに至ったのは、  
私自身が大阪を拠点にバンドを組んで音楽活動を行い、  
活動の中でCDやグッズを販売していた経験が大きな動機となっています。

> "作品"や"商品"に込めたオリジナリティを感じながら、  
> 個人やチームでの在庫管理が出来るようなアプリがあればな。

そんな当時の思いを形にしたのが、unicoというアプリです。

unicoを利用しているユーザー同士で、  
お互いの画面を見せ合いたくなるような、  
そんな"愛着"が生まれるアプリを目指しています。

<br>

## 👤開発者について

https://twitter.com/kenchan2n4n

#### 🖊️技術発信

こちらのサイトで、主にSwiftUIフレームワークにおいての記事を書かせていただいています。

https://blog.code-candy.com/category/swiftui/

<br>

### README構築ツール

- GIPHY CAPTURE（アプリの動作のgif撮影）
- Figma（画面遷移フロー）
- GitMind（シーケンス図）
- draw.io（ER図）


