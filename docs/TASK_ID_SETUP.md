# 📋 チケットIDシステム セットアップ & 使い方

このドキュメントでは、Issue・ブランチ・コミット・PRを一貫したチケットID（`TASK-XXXX`）で管理する仕組みの使い方を説明します。

---

## 🚀 初回セットアップ（ローカル環境）

Git hookを有効化するため、以下のコマンドを**1度だけ**実行してください：

```bash
./scripts/setup-git-hooks.sh
```

✅ これで、コミット時に自動で `[TASK-XXXX]` が追加されるようになります。

---

## 📌 ワークフロー

### 1️⃣ **Issue を作成**

1. GitHub の Issues タブから新規 Issue を作成
2. テンプレートを選択（機能追加・バグ報告・質問）
3. タイトルと内容を記入して Submit

**👉 自動で以下が実行されます：**
- Issue 本文の先頭に `📋 チケットID` セクションが追加（例: `TASK-0042`）
- 推奨ブランチ名がコメントで投稿される

**例：Issue #42 を作成した場合**

```markdown
## 📋 チケットID
`TASK-0042`

---

## 機能の概要
...
```

**コメント例：**
```bash
git checkout -b feature/TASK-0042-new-authentication
```

---

### 2️⃣ **ブランチを作成**

Issue のコメントに記載されたブランチ名をコピーして使用：

```bash
git checkout -b feature/TASK-0042-new-authentication
```

**ブランチ命名ルール：**
- `feature/TASK-XXXX-description` → 新機能
- `bugfix/TASK-XXXX-description` → バグ修正
- `hotfix/TASK-XXXX-description` → 緊急修正

---

### 3️⃣ **コミット**

通常通りコミットするだけで、自動で `[TASK-XXXX]` が追加されます。

```bash
git commit -m "ログイン機能を実装"
```

**👉 自動で以下のように変換されます：**
```
[TASK-0042] ログイン機能を実装
```

**手動で付与する場合：**
```bash
git commit -m "[TASK-0042] ログイン機能を実装"
```

---

### 4️⃣ **プルリクエスト (PR) を作成**

1. ブランチをプッシュ：
   ```bash
   git push -u origin feature/TASK-0042-new-authentication
   ```

2. GitHub で PR を作成

3. **PRタイトルに `[TASK-XXXX]` を含める**：
   ```
   [TASK-0042] ユーザー認証機能の追加
   ```

**👉 自動チェックが実行されます：**
- ✅ PRタイトルに `[TASK-XXXX]` が含まれているか
- ❌ 含まれていない場合、自動でコメントが投稿され、チェック失敗

---

## 🔧 トラブルシューティング

### コミットメッセージに `[TASK-XXXX]` が追加されない

**原因：** Git hook が正しくインストールされていない

**解決方法：**
```bash
./scripts/setup-git-hooks.sh
```

### ブランチ名から TASK-XXXX が取得できない

**原因：** ブランチ名が命名ルールに従っていない

**解決方法：** ブランチ名を修正
```bash
git checkout -b feature/TASK-0042-description
```

### PR チェックが失敗する

**原因：** PRタイトルに `[TASK-XXXX]` が含まれていない

**解決方法：** PRタイトルを編集
```
[TASK-0042] 機能の説明
```

---

## 📂 ファイル構成

```
.
├── .github/
│   ├── workflows/
│   │   ├── issue-auto-id.yml          # Issue作成時の自動ID付与
│   │   └── pr-title-check.yml         # PRタイトルチェック
│   ├── ISSUE_TEMPLATE/
│   │   ├── FEATURE_REQUEST.md         # 機能追加テンプレート
│   │   ├── BUG_REPORT.md              # バグ報告テンプレート
│   │   └── QUESTION.md                # 質問テンプレート
│   └── PULL_REQUEST_TEMPLATE.md       # PRテンプレート
│
├── scripts/
│   ├── setup-git-hooks.sh             # Git hookセットアップスクリプト
│   └── hooks/
│       └── prepare-commit-msg         # コミットメッセージ自動付与フック
│
└── docs/
    └── TASK_ID_SETUP.md               # このドキュメント
```

---

## 🎯 まとめ

| 操作 | 自動化内容 |
|------|-----------|
| Issue 作成 | ✅ チケットID（`TASK-XXXX`）自動付与 + ブランチ名提案 |
| コミット | ✅ コミットメッセージに `[TASK-XXXX]` 自動追加 |
| PR 作成 | ✅ タイトルに `[TASK-XXXX]` があるかチェック |

**👉 一度セットアップすれば、あとは Issue を作成して通常通り開発するだけ！**
