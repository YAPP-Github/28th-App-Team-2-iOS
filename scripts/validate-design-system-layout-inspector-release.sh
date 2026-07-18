#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

WORKSPACE="$ROOT_DIR/todakun.xcworkspace"
SCHEME="DesignSystemExample"
CONFIGURATION="Release"

failures=0

fail() {
  printf '오류: %s\n' "$1" >&2
  failures=$((failures + 1))
}

require_file() {
  if [[ ! -f "$1" ]]; then
    fail "필수 파일이 없습니다: $1"
    return 1
  fi
}

report_pattern() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  local matches
  local status

  matches="$(rg -n -- "$pattern" "$file")"
  status=$?

  if [[ "$status" -eq 0 ]]; then
    fail "$message"
    printf '%s\n' "$matches" >&2
  elif [[ "$status" -ne 1 ]]; then
    fail "검사 패턴을 실행하지 못했습니다: $pattern"
  fi
}

if [[ ! -d "$WORKSPACE" ]]; then
  printf "오류: workspace가 없습니다. 먼저 'mise exec -- tuist generate --no-open'을 실행하세요.\n" >&2
  exit 1
fi

for command in mise xcrun rg find sort xargs awk; do
  if ! command -v "$command" >/dev/null 2>&1; then
    fail "필수 명령어를 찾을 수 없습니다: $command"
  fi
done

if [[ "$failures" -gt 0 ]]; then
  printf 'Release 레이아웃 검사기 검증을 시작하기 전에 실패했습니다.\n' >&2
  exit 1
fi

TEMP_DIR=""
if ! TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/validate-ds-layout-inspector-release.XXXXXX")" \
  || [[ -z "$TEMP_DIR" || ! -d "$TEMP_DIR" ]]; then
  printf '오류: 임시 디렉터리 생성에 실패했습니다.\n' >&2
  exit 1
fi

trap 'rm -rf "$TEMP_DIR"' EXIT

DERIVED_DATA="$TEMP_DIR/DerivedData"
PRODUCTS_DIR="$DERIVED_DATA/Build/Products/${CONFIGURATION}-iphonesimulator"
APP_BINARY="$PRODUCTS_DIR/DesignSystemExample.app/DesignSystemExample"
FRAMEWORK_BINARY="$PRODUCTS_DIR/DesignSystem.framework/DesignSystem"
MODULE_DIR="$PRODUCTS_DIR/DesignSystem.framework/Modules/DesignSystem.swiftmodule"

printf 'Release DesignSystemExample을 별도 DerivedData에 빌드합니다.\n'
if ! mise exec -- tuist xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO; then
  printf '오류: Release DesignSystemExample 빌드에 실패했습니다.\n' >&2
  exit 1
fi

require_file "$APP_BINARY"
require_file "$FRAMEWORK_BINARY"

if [[ ! -d "$MODULE_DIR" ]]; then
  fail "DesignSystem Swift 모듈 디렉터리가 없습니다: $MODULE_DIR"
fi

if [[ "$failures" -gt 0 ]]; then
  printf 'Release 산출물을 찾지 못해 검증을 중단합니다.\n' >&2
  exit 1
fi

if ! xcrun nm -jU "$APP_BINARY" > "$TEMP_DIR/app-symbols"; then
  fail "앱 실행 파일 심볼을 읽지 못했습니다."
fi

if ! xcrun nm -jU "$FRAMEWORK_BINARY" > "$TEMP_DIR/framework-symbols"; then
  fail "DesignSystem 정적 산출물 심볼을 읽지 못했습니다."
fi

if ! /usr/bin/strings -a "$APP_BINARY" > "$TEMP_DIR/app-strings"; then
  fail "앱 실행 파일 문자열을 읽지 못했습니다."
fi

if ! /usr/bin/strings -a "$FRAMEWORK_BINARY" > "$TEMP_DIR/framework-strings"; then
  fail "DesignSystem 정적 산출물 문자열을 읽지 못했습니다."
fi

if [[ "$failures" -gt 0 ]]; then
  printf 'Release 산출물 정보 추출에 실패했습니다.\n' >&2
  exit 1
fi

# 정적 아카이브 멤버명도 nm 출력에 포함되므로 Mach-O 심볼 행만 남긴다.
if ! awk '/^_/' "$TEMP_DIR/app-symbols" "$TEMP_DIR/framework-symbols" \
  | sort -u > "$TEMP_DIR/all-symbols"; then
  fail "Release 심볼 목록을 합치지 못했습니다."
fi

if ! sort -u "$TEMP_DIR/app-strings" "$TEMP_DIR/framework-strings" > "$TEMP_DIR/all-strings"; then
  fail "Release 문자열 목록을 합치지 못했습니다."
fi

# 소스 파일명과 정적 아카이브 멤버명은 증거가 아니므로 실제 구현 타입명만 검사한다.
IMPLEMENTATION_SYMBOL_PATTERN='DSLayout(Inspector|Debug(Node|PreferenceKey|GeometryModifier)|Region|Measurement|RulerPoints|ElementCollector)'
report_pattern \
  "$TEMP_DIR/all-symbols" \
  "$IMPLEMENTATION_SYMBOL_PATTERN" \
  "Release 심볼에 DEBUG 레이아웃 검사기 구현 타입이 남아 있습니다."

RUNTIME_STRING_PATTERN='영역을 눌러 속성을 확인하세요|두 영역을 차례로 눌러 간격을 측정하세요|두 지점을 차례로 누르거나 드래그해 측정하세요|현재 화면:|선택 영역:'
report_pattern \
  "$TEMP_DIR/all-strings" \
  "$RUNTIME_STRING_PATTERN" \
  "Release 산출물에 레이아웃 검사기 런타임 문자열이 남아 있습니다."

# @autoclosure 인자가 Release에서 평가되면 컴포넌트 내부 영역 이름이 문자열로 남는다.
DEBUG_NAME_PATTERN='DS[A-Za-z0-9]+\.(LeftIcon|RightIcon|Title|Content|Text|Icon)|Typography\.'
report_pattern \
  "$TEMP_DIR/all-strings" \
  "$DEBUG_NAME_PATTERN" \
  "Release 산출물에 평가된 컴포넌트 디버그 이름이 남아 있습니다."

if ! find "$MODULE_DIR" -type f -name '*.abi.json' -print0 \
  | xargs -0 cat > "$TEMP_DIR/public-abi"; then
  fail "DesignSystem 공개 ABI 정보를 읽지 못했습니다."
elif [[ ! -s "$TEMP_DIR/public-abi" ]]; then
  fail "DesignSystem 공개 ABI 정보가 비어 있습니다."
else
  report_pattern \
    "$TEMP_DIR/public-abi" \
    'dsDebug(LayoutInspector|Geometry|DetailGeometry|TypographyGeometry)|DSLayoutInspector' \
    "Release 공개 ABI에 디버그 API가 노출되어 있습니다."
fi

if [[ "$failures" -eq 0 ]]; then
  printf 'DesignSystem 레이아웃 검사기 Release 검증 통과.\n'
  printf '  - DEBUG 구현 심볼 없음\n'
  printf '  - 검사기·컴포넌트 디버그 문자열 없음\n'
  printf '  - 공개 ABI 디버그 API 없음\n'
  exit 0
fi

printf 'DesignSystem 레이아웃 검사기 Release 검증 실패: 총 %d개 문제를 발견했습니다.\n' "$failures" >&2
exit 1
