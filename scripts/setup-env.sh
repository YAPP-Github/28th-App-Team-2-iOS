#!/usr/bin/env bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0;m' # No Color

# 경고 개수를 누적할 카운트 변수
WARNING_COUNT=0

echo -e "🛡️  개발 환경 필수 도구 진단 중..."

# 1. mise 설치 여부 진단
if ! command -v mise &> /dev/null; then
    echo -e "${RED}❌ 에러: 'mise'가 설치되어 있지 않습니다.${NC}"
    echo -e "   이 프로젝트는 mise를 사용해 tuist 등의 버전을 관리합니다."
    echo -e "   아래 명령어를 실행하여 설치해 주세요:"
    echo -e "   ${YELLOW}brew install mise && mise install${NC}"
    exit 1
else
    echo -e "${GREEN}✅ 'mise'가 설치되어 있습니다.${NC}"
fi

# 2. mise.toml에 명시된 도구 설치 (tuist 등)
echo -e "📦 '.mise.toml'에 설정된 개발 도구 설치 중..."
if mise install; then
    echo -e "${GREEN}✅ 'mise install' 완료.${NC}"
else
    echo -e "${RED}❌ 'mise install' failed.${NC}"
    exit 1
fi

# 3. tuist 동작성 테스트
if ! mise exec -- tuist version &> /dev/null; then
    echo -e "${RED}❌ 에러: mise를 통해 'tuist'를 실행할 수 없습니다.${NC}"
    echo -e "   .mise.toml 설정을 확인해 주세요."
    exit 1
else
    TUIST_VER=$(mise exec -- tuist version)
    echo -e "${GREEN}✅ 'tuist' 사용 가능 (버전: ${TUIST_VER}).${NC}"
fi

# 4. GitHub CLI (gh) 설치 및 권한 검사 (Non-blocking)
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  경고: GitHub CLI ('gh')가 설치되어 있지 않습니다.${NC}"
    echo -e "   AI 에이전트와의 이슈/PR 등 자동화 협업 기능을 원활히 사용하려면 gh 설치를 권장합니다."
    echo -e "   다음 명령어로 설치 및 로그인할 수 있습니다:"
    echo -e "   ${YELLOW}brew install gh && gh auth login${NC}"
    WARNING_COUNT=$((WARNING_COUNT + 1))
else
    echo -e "${GREEN}✅ GitHub CLI ('gh')가 설치되어 있습니다.${NC}"
    
    # gh 토큰의 project 권한 스코프 유무 진단
    GH_STATUS=$(gh auth status 2>&1)
    if [[ "$GH_STATUS" != *"project"* ]]; then
        echo -e "${YELLOW}⚠️  경고: GitHub CLI에 'project' 권한(Scope)이 누락되어 있습니다.${NC}"
        echo -e "   AI 에이전트가 GitHub Projects 보드에 이슈를 등록하고 연동하려면 프로젝트 권한이 필요합니다."
        echo -e "   아래 명령어를 실행하여 권한을 승인해 주세요:"
        echo -e "   ${YELLOW}gh auth refresh -s project${NC}"
        WARNING_COUNT=$((WARNING_COUNT + 1))
    else
        echo -e "${GREEN}✅ GitHub CLI 'project' 권한이 정상 활성화되어 있습니다.${NC}"
    fi
fi

# 5. Graphviz (dot) 설치 여부 검사 (Non-blocking)
if ! command -v dot &> /dev/null; then
    echo -e "${YELLOW}⚠️  경고: Graphviz ('dot')가 설치되어 있지 않습니다.${NC}"
    echo -e "   아키텍처 의존성 시각화(.png) 그래프를 생성 및 최신화하기 위해 Graphviz가 필요합니다."
    echo -e "   이를 설치하려면 다음 명령어를 실행해 주세요:"
    echo -e "   ${YELLOW}brew install graphviz${NC}"
    WARNING_COUNT=$((WARNING_COUNT + 1))
else
    echo -e "${GREEN}✅ Graphviz ('dot')가 설치되어 있습니다.${NC}"
fi

# 6. Git Hooks 설정 실행
echo -e "\n🎨 Git Hooks 설정 중..."
SCRIPT_DIR=$(dirname "$0")
if [ -f "${SCRIPT_DIR}/setup-hooks.sh" ]; then
    chmod +x "${SCRIPT_DIR}/setup-hooks.sh"
    "${SCRIPT_DIR}/setup-hooks.sh"
else
    echo -e "${RED}❌ 에러: ${SCRIPT_DIR} 경로에서 setup-hooks.sh를 찾을 수 없습니다.${NC}"
    exit 1
fi

# 7. 셸 활성화 여부 확인 및 경고 출력
# 셸에 'tuist' 명령어가 직접 등록되어 있지 않은 경우에만 가이드 출력
if ! command -v tuist &>/dev/null; then
    echo -e "\n⚠️  ${YELLOW}경고: 터미널 셸에 mise 연동 설정(activate)이 되어 있지 않습니다.${NC}"
    echo -e "   이 상태에서는 터미널에서 'mise exec --' 접두사 없이 'tuist' 명령어를 단독으로 실행할 수 없습니다."
    echo -e "   다음 설정을 ~/.zshrc에 추가한 후 터미널을 재실행해 주세요:"
    echo -e "   ${GREEN}echo 'eval \"\$(mise activate zsh)\"' >> ~/.zshrc${NC}"
    WARNING_COUNT=$((WARNING_COUNT + 1))
fi

# 8. 최종 완료 메시지 출력
if [ $WARNING_COUNT -eq 0 ]; then
    echo -e "\n🎉 ${GREEN}개발 환경 셋업이 성공적으로 완료되었습니다!${NC}"
else
    echo -e "\nℹ️  ${YELLOW}개발 환경 셋업이 완료되었으나, ${WARNING_COUNT}개의 경고 사항이 있습니다.${NC}"
    echo -e "   정상적인 터미널 작업과 AI 협업을 위해 위쪽 로그의 경고(⚠️) 설정을 보완하는 것을 권장합니다."
fi
