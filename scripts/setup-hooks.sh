#!/usr/bin/env bash

echo "Setting up Git Hooks for the project..."

# 프로젝트 루트 디렉토리 확인
ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$ROOT_DIR" ]; then
    echo "Error: Not a git repository. Please run this inside the repository."
    exit 1
fi

cd "$ROOT_DIR" || exit 1

# .githooks 디렉토리가 존재하는지 확인
if [ ! -d ".githooks" ]; then
    echo "Error: .githooks directory not found."
    exit 1
fi

# 모든 훅 스크립트에 실행 권한 부여
chmod +x .githooks/* || exit 1
echo "✅ Granted execution permissions to hook scripts."

# git config를 통해 hooksPath 설정
git config core.hooksPath .githooks || exit 1
echo "✅ Set core.hooksPath to .githooks."

echo ""
echo "🎉 Git hooks have been successfully configured!"
echo "   - pre-push: Blocks force push and validates architecture."
echo "   - pre-commit: Enforces Git Flow branch naming conventions."
echo "   - commit-msg: Enforces Conventional Commits format."
