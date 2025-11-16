# 📋 Issue番号ベース管理システム セットアップ & 使い方

このドキュメントでは、GitHub Issue番号（`#XX`）を使って、Issue・ブランチ・コミット・PRを一貫して管理する仕組みの使い方を説明します。

---

## 🚀 初回セットアップ（ローカル環境）

Git hookを有効化するため、以下のコマンドを**1度だけ**実行してください：

```bash
./scripts/setup-git-hooks.sh
```

✅ これで、コミット時に自動で `[#XX]` が追加されるようになります。

---

## 📌 ワークフロー

### 1️⃣ **Issue を作成**

1. GitHub の Issues タブから新規 Issue を作成
2. テンプレートを選択（機能追加・バグ報告・質問）
3. タイトルと内容を記入して Submit

**👉 自動で以下が実行されます：**
- 推奨ブランチ名がコメントで投稿される

**例：Issue #42 を作成した場合**

**コメント例：**
```bash
git checkout -b bugfix/#42-
# ↑ 末尾に作業内容を英語で追加してください（例: fix-modal-bug, add-user-auth）
```

---

### 2️⃣ **ブランチを作成**

Issue のコメントに記載されたブランチ名をベースに作成：

```bash
git checkout -b bugfix/#42-fix-modal-bug
```

**ブランチ命名ルール：**
- `feature/#XX-description` → 新機能
- `bugfix/#XX-description` → バグ修正
- `hotfix/#XX-description` → 緊急修正

---

### 3️⃣ **コミット**

通常通りコミットするだけで、自動で `[#XX]` が追加されます。

```bash
git commit -m "ログイン機能を実装"
```

**👉 自動で以下のように変換されます：**
```
[#42] ログイン機能を実装
```

**手動で付与する場合：**
```bash
git commit -m "[#42] ログイン機能を実装"
```

---

### 4️⃣ **プルリクエスト (PR) を作成**

1. ブランチをプッシュ：
   ```bash
   git push -u origin bugfix/#42-fix-modal-bug
   ```

2. GitHub で PR を作成

3. **PRタイトルに `[#XX]` を含める**：
   ```
   [#42] モーダルのバグを修正
   ```

4. **PR説明に `close #42` を含める**（推奨）：
   - マージ時に自動でIssue #42がクローズされます

**👉 自動チェックが実行されます：**
- ✅ PRタイトルに `[#XX]` が含まれているか
- ❌ 含まれていない場合、自動でコメントが投稿され、チェック失敗

---

## 🔧 トラブルシューティング

### コミットメッセージに `[#XX]` が追加されない

**原因：** Git hook が正しくインストールされていない、またはブランチ名に `#XX` が含まれていない

**解決方法：**
```bash
# Git hookを再インストール
./scripts/setup-git-hooks.sh

# ブランチ名を確認
git branch --show-current

# ブランチ名が正しくない場合は修正
git checkout -b bugfix/#42-fix-description
```

### ブランチ名から #XX が取得できない

**原因：** ブランチ名が命名ルールに従っていない

**解決方法：** ブランチ名を修正
```bash
git checkout -b feature/#42-description
```

### PR チェックが失敗する

**原因：** PRタイトルに `[#XX]` が含まれていない

**解決方法：** PRタイトルを編集
```
[#42] 機能の説明
```

---

## 📂 ファイル構成

```
.
├── .github/
│   ├── workflows/
│   │   ├── issue-auto-id.yml          # Issue作成時のブランチ名提案コメント
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
| Issue 作成 | ✅ ブランチ名提案コメント自動投稿 |
| コミット | ✅ コミットメッセージに `[#XX]` 自動追加 |
| PR 作成 | ✅ タイトルに `[#XX]` があるかチェック |

### 🔗 GitHubネイティブ機能の活用

- **自動リンク**: `#42` を含むコミットやコメントは自動でIssue #42にリンク
- **自動クローズ**: PRに `close #42` と記載してマージすると、Issue #42が自動クローズ
- **トラッキング**: Issue内の「Development」セクションで関連PRやコミットを自動追跡

**👉 一度セットアップすれば、あとは Issue を作成して通常通り開発するだけ！**
