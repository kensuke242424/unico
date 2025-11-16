#!/bin/bash

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Git Hooks セットアップスクリプト${NC}"
echo -e "${BLUE}========================================${NC}\n"

# リポジトリルートへ移動
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$REPO_ROOT" ]; then
    echo -e "${YELLOW}⚠️  エラー: Gitリポジトリ内で実行してください${NC}"
    exit 1
fi

cd "$REPO_ROOT"
echo -e "${GREEN}📁 リポジトリルート: $REPO_ROOT${NC}\n"

# hooks ディレクトリが存在するか確認
HOOKS_SOURCE_DIR="$REPO_ROOT/scripts/hooks"
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"

if [ ! -d "$HOOKS_SOURCE_DIR" ]; then
    echo -e "${YELLOW}⚠️  エラー: $HOOKS_SOURCE_DIR が見つかりません${NC}"
    exit 1
fi

# .git/hooks ディレクトリが存在するか確認
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    echo -e "${YELLOW}⚠️  エラー: $GIT_HOOKS_DIR が見つかりません${NC}"
    exit 1
fi

# prepare-commit-msg フックをコピー
echo -e "${BLUE}🔧 prepare-commit-msg フックをインストール中...${NC}"

if [ -f "$GIT_HOOKS_DIR/prepare-commit-msg" ]; then
    # バックアップを作成
    BACKUP_FILE="$GIT_HOOKS_DIR/prepare-commit-msg.backup.$(date +%Y%m%d%H%M%S)"
    cp "$GIT_HOOKS_DIR/prepare-commit-msg" "$BACKUP_FILE"
    echo -e "${YELLOW}   既存のフックをバックアップしました: $BACKUP_FILE${NC}"
fi

# フックをコピーして実行権限を付与
cp "$HOOKS_SOURCE_DIR/prepare-commit-msg" "$GIT_HOOKS_DIR/prepare-commit-msg"
chmod +x "$GIT_HOOKS_DIR/prepare-commit-msg"

echo -e "${GREEN}✅ prepare-commit-msg フックのインストールが完了しました${NC}\n"

# 確認
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   インストール完了${NC}"
echo -e "${BLUE}========================================${NC}\n"
echo -e "${GREEN}📝 以下のGit Hooksがインストールされました：${NC}"
echo -e "   • prepare-commit-msg"
echo ""
echo -e "${GREEN}🎉 セットアップ完了！${NC}\n"
echo -e "${YELLOW}💡 使い方：${NC}"
echo -e "   1. Issue からブランチを作成"
echo -e "      例: git checkout -b feature/TASK-0001-new-feature"
echo ""
echo -e "   2. コミット時、自動で [TASK-0001] が追加されます"
echo -e "      例: git commit -m \"ログイン機能を実装\""
echo -e "      → [TASK-0001] ログイン機能を実装"
echo ""
