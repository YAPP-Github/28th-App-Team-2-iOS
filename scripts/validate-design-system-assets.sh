#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

DESIGN_SYSTEM_DIR="${DESIGN_SYSTEM_DIR:-$ROOT_DIR/Projects/Core/DesignSystem}"
ASSET_CATALOG="$DESIGN_SYSTEM_DIR/Resources/Assets.xcassets"
GENERATED_ACCESSORS="$DESIGN_SYSTEM_DIR/Derived/Sources/TuistAssets+DesignSystem.swift"
COLOR_BRIDGE="$DESIGN_SYSTEM_DIR/Sources/DesignSystemColor.swift"
ICON_BRIDGE="$DESIGN_SYSTEM_DIR/Sources/DesignSystemIcon.swift"
COLOR_CATALOG="$DESIGN_SYSTEM_DIR/Example/Sources/Catalogs/ColorCatalogView.swift"
ICON_CATALOG="$DESIGN_SYSTEM_DIR/Example/Sources/Catalogs/IconCatalogView.swift"

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

require_directory() {
  if [[ ! -d "$1" ]]; then
    fail "필수 디렉터리가 없습니다: $1"
    return 1
  fi
}

report_difference() {
  local expected_file="$1"
  local actual_file="$2"
  local missing_message="$3"
  local unexpected_message="$4"
  local item

  while IFS= read -r item; do
    [[ -n "$item" ]] && fail "$missing_message: '$item'"
  done < <(comm -23 "$expected_file" "$actual_file")

  while IFS= read -r item; do
    [[ -n "$item" ]] && fail "$unexpected_message: '$item'"
  done < <(comm -13 "$expected_file" "$actual_file")
}

report_bridge_name_mismatches() {
  local mappings_file="$1"
  local bridge_name="$2"
  local exposed_name
  local referenced_name

  while IFS=$'\t' read -r exposed_name referenced_name; do
    if [[ -n "$exposed_name" && "$exposed_name" != "$referenced_name" ]]; then
      fail "$bridge_name 이름이 일치하지 않습니다. 공개 이름 '$exposed_name', 연결된 Tuist 접근자 '$referenced_name'"
    fi
  done < "$mappings_file"
}

require_directory "$ASSET_CATALOG/Colors"
require_directory "$ASSET_CATALOG/Icons"
require_file "$GENERATED_ACCESSORS"
require_file "$COLOR_BRIDGE"
require_file "$ICON_BRIDGE"
require_file "$COLOR_CATALOG"
require_file "$ICON_CATALOG"

if [[ "$failures" -gt 0 ]]; then
  printf 'DesignSystem 에셋 비교를 시작하기 전에 검증이 실패했습니다.\n' >&2
  exit 1
fi

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/validate-design-system-assets.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT

if ! find "$ASSET_CATALOG/Colors" -type d -name '*.colorset' \
  | sed -e "s#^$ASSET_CATALOG/##" -e 's#\.colorset$##' \
  | sort -u > "$TEMP_DIR/asset-colors"; then
  fail "Asset Catalog에서 색상 에셋 목록을 수집하지 못했습니다."
fi

if ! find "$ASSET_CATALOG/Icons" -type d -name '*.imageset' \
  | sed -e "s#^$ASSET_CATALOG/##" -e 's#\.imageset$##' \
  | sort -u > "$TEMP_DIR/asset-icons"; then
  fail "Asset Catalog에서 아이콘 에셋 목록을 수집하지 못했습니다."
fi

# 주의: 아래 정규식은 현재 Tuist가 생성하는 에셋 접근자 코드 형식에 의존한다.
# Tuist 버전 변경 후 파싱 결과가 비어 있으면 생성 코드 형식과 정규식을 함께 확인한다.
if ! perl -ne 'print "$2\t$1\n" if /public static let ([A-Za-z_][A-Za-z0-9_]*) = DesignSystemColors\(name: "(Colors\/[^"]+)"\)/' \
  "$GENERATED_ACCESSORS" | sort -u > "$TEMP_DIR/generated-color-mappings"; then
  fail "Tuist 생성 코드에서 색상 접근자 매핑을 추출하지 못했습니다."
fi

if ! perl -ne 'print "$2\t$1\n" if /public static let ([A-Za-z_][A-Za-z0-9_]*) = DesignSystemImages\(name: "(Icons\/[^"]+)"\)/' \
  "$GENERATED_ACCESSORS" | sort -u > "$TEMP_DIR/generated-icon-mappings"; then
  fail "Tuist 생성 코드에서 아이콘 접근자 매핑을 추출하지 못했습니다."
fi

if [[ ! -s "$TEMP_DIR/generated-color-mappings" ]]; then
  fail "Tuist 색상 접근자 파싱 결과가 비어 있습니다. 생성 코드 형식과 검증 정규식을 확인하세요."
fi

if [[ ! -s "$TEMP_DIR/generated-icon-mappings" ]]; then
  fail "Tuist 아이콘 접근자 파싱 결과가 비어 있습니다. 생성 코드 형식과 검증 정규식을 확인하세요."
fi

if [[ "$failures" -gt 0 ]]; then
  printf 'DesignSystem 에셋 목록 생성에 실패했습니다.\n' >&2
  exit 1
fi

if ! cut -f1 "$TEMP_DIR/generated-color-mappings" | sort -u > "$TEMP_DIR/generated-colors"; then
  fail "Tuist 색상 에셋 이름 목록을 만들지 못했습니다."
fi

if ! cut -f2 "$TEMP_DIR/generated-color-mappings" | sort -u > "$TEMP_DIR/generated-color-identifiers"; then
  fail "Tuist 색상 접근자 이름 목록을 만들지 못했습니다."
fi

if ! cut -f1 "$TEMP_DIR/generated-icon-mappings" | sort -u > "$TEMP_DIR/generated-icons"; then
  fail "Tuist 아이콘 에셋 이름 목록을 만들지 못했습니다."
fi

if ! cut -f2 "$TEMP_DIR/generated-icon-mappings" | sort -u > "$TEMP_DIR/generated-icon-identifiers"; then
  fail "Tuist 아이콘 접근자 이름 목록을 만들지 못했습니다."
fi

if ! perl -ne 'print "$1\t$2\n" if /^\s*public static let ([A-Za-z_][A-Za-z0-9_]*)\s*=\s*DesignSystemAsset\.Colors\.([A-Za-z_][A-Za-z0-9_]*)\.swiftUIColor\s*$/' \
  "$COLOR_BRIDGE" | sort -u > "$TEMP_DIR/color-bridge-mappings"; then
  fail "Color.ds 브릿지 매핑을 추출하지 못했습니다."
fi

if ! perl -ne 'print "$1\t$2\n" if /^\s*public static let ([A-Za-z_][A-Za-z0-9_]*)\s*=\s*DesignSystemAsset\.Icons\.([A-Za-z_][A-Za-z0-9_]*)\.swiftUIImage\s*$/' \
  "$ICON_BRIDGE" | sort -u > "$TEMP_DIR/icon-bridge-mappings"; then
  fail "Image.ds 브릿지 매핑을 추출하지 못했습니다."
fi

if ! cut -f2 "$TEMP_DIR/color-bridge-mappings" | sort -u > "$TEMP_DIR/bridged-colors"; then
  fail "Color.ds 브릿지 접근자 목록을 만들지 못했습니다."
fi

if ! cut -f2 "$TEMP_DIR/icon-bridge-mappings" | sort -u > "$TEMP_DIR/bridged-icons"; then
  fail "Image.ds 브릿지 접근자 목록을 만들지 못했습니다."
fi

# Catalog에서 주석 처리된 참조는 등록으로 간주하지 않는다.
if ! perl -0777 -ne '$source = $_; $source =~ s{/\*.*?\*/}{}gs; $source =~ s{//[^\n]*}{}g; while ($source =~ /DesignSystemAsset\.Colors\.([A-Za-z_][A-Za-z0-9_]*)/g) { print "$1\n" }' \
  "$COLOR_CATALOG" | sort -u > "$TEMP_DIR/catalog-colors"; then
  fail "색상 Catalog의 접근자 목록을 추출하지 못했습니다."
fi

if ! perl -0777 -ne '$source = $_; $source =~ s{/\*.*?\*/}{}gs; $source =~ s{//[^\n]*}{}g; while ($source =~ /DesignSystemAsset\.Icons\.([A-Za-z_][A-Za-z0-9_]*)/g) { print "$1\n" }' \
  "$ICON_CATALOG" | sort -u > "$TEMP_DIR/catalog-icons"; then
  fail "아이콘 Catalog의 접근자 목록을 추출하지 못했습니다."
fi

if [[ "$failures" -gt 0 ]]; then
  printf 'DesignSystem 에셋 등록 정보 추출에 실패했습니다.\n' >&2
  exit 1
fi

report_bridge_name_mismatches "$TEMP_DIR/color-bridge-mappings" "Color.ds 브릿지"
report_bridge_name_mismatches "$TEMP_DIR/icon-bridge-mappings" "Image.ds 브릿지"

report_difference \
  "$TEMP_DIR/asset-colors" \
  "$TEMP_DIR/generated-colors" \
  "실제 색상 에셋이 Tuist 생성 접근자에 없습니다. 'mise exec -- tuist generate --no-open' 실행이 필요한 대상" \
  "Tuist 색상 접근자에 대응하는 실제 에셋이 없습니다"

report_difference \
  "$TEMP_DIR/asset-icons" \
  "$TEMP_DIR/generated-icons" \
  "실제 아이콘 에셋이 Tuist 생성 접근자에 없습니다. 'mise exec -- tuist generate --no-open' 실행이 필요한 대상" \
  "Tuist 아이콘 접근자에 대응하는 실제 에셋이 없습니다"

report_difference \
  "$TEMP_DIR/generated-color-identifiers" \
  "$TEMP_DIR/bridged-colors" \
  "Tuist 색상 접근자가 Color.ds 브릿지에 없습니다" \
  "Color.ds 브릿지가 알 수 없는 Tuist 접근자를 참조합니다"

report_difference \
  "$TEMP_DIR/generated-icon-identifiers" \
  "$TEMP_DIR/bridged-icons" \
  "Tuist 아이콘 접근자가 Image.ds 브릿지에 없습니다" \
  "Image.ds 브릿지가 알 수 없는 Tuist 접근자를 참조합니다"

report_difference \
  "$TEMP_DIR/generated-color-identifiers" \
  "$TEMP_DIR/catalog-colors" \
  "Tuist 색상 접근자가 Color Catalog에 없습니다" \
  "Color Catalog가 알 수 없는 Tuist 접근자를 참조합니다"

report_difference \
  "$TEMP_DIR/generated-icon-identifiers" \
  "$TEMP_DIR/catalog-icons" \
  "Tuist 아이콘 접근자가 Icon Catalog에 없습니다" \
  "Icon Catalog가 알 수 없는 Tuist 접근자를 참조합니다"

if [[ "$failures" -eq 0 ]]; then
  printf 'DesignSystem 에셋 검증 통과 (색상 %s개, 아이콘 %s개).\n' \
    "$(awk 'END { print NR }' "$TEMP_DIR/asset-colors")" \
    "$(awk 'END { print NR }' "$TEMP_DIR/asset-icons")"
  exit 0
fi

printf 'DesignSystem 에셋 검증 실패: 총 %d개 문제를 발견했습니다.\n' "$failures" >&2
exit 1
