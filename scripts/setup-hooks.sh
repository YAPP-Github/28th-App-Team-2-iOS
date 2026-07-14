#!/usr/bin/env bash

echo "프로젝트 Git Hooks 설정 중..."

# 프로젝트 루트 디렉토리 확인
ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$ROOT_DIR" ]; then
    echo "에러: Git 저장소가 아닙니다. 저장소 루트 디렉토리 내부에서 실행해 주세요."
    exit 1
fi

cd "$ROOT_DIR" || exit 1

# .githooks 디렉토리가 존재하는지 확인
if [ ! -d ".githooks" ]; then
    echo "에러: .githooks 디렉토리를 찾을 수 없습니다."
    exit 1
fi

# 현재 환경의 Mise 실행 경로 확인
MISE_PATH=$(command -v mise 2>/dev/null)

if [ -z "$MISE_PATH" ] || [ ! -x "$MISE_PATH" ]; then
    echo "에러: Mise 실행 파일을 찾을 수 없습니다. Mise를 설치한 후 다시 시도해 주세요."
    exit 1
fi

# 모든 훅 스크립트에 실행 권한 부여
chmod +x .githooks/* || exit 1
echo "✅ 훅 스크립트 실행 권한 부여 완료."

# git config를 통해 hooksPath 설정
git config core.hooksPath .githooks || exit 1
echo "✅ core.hooksPath를 .githooks로 설정 완료."

# GUI Git 환경에서도 동일한 Mise를 사용하도록 로컬 저장소에 실제 경로 저장
git config --local hooks.misePath "$MISE_PATH" || exit 1
echo "✅ Git Hooks용 Mise 경로 저장 완료: $MISE_PATH"

echo ""
echo "🎉 Git Hooks 설정이 완료되었습니다!"
echo "   - pre-push: 강제 푸시(Force Push) 방지 및 SwiftLint/아키텍처 규칙 검증"
echo "   - pre-commit: Git Flow 브랜치 명명 규칙 준수 여부 검사"
echo "   - commit-msg: Conventional Commits 커밋 메시지 규칙 준수 여부 검사"
