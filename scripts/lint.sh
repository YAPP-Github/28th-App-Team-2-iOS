#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v mise >/dev/null 2>&1; then
  printf 'error: mise가 설치되어 있지 않습니다. README의 Getting Started를 확인해주세요.\n' >&2
  exit 1
fi

if ! mise which swiftlint >/dev/null 2>&1; then
  printf 'error: SwiftLint가 설치되어 있지 않습니다. mise install을 먼저 실행해주세요.\n' >&2
  exit 1
fi

printf 'Running SwiftLint...\n'
mise exec -- swiftlint lint --config "$ROOT_DIR/.swiftlint.yml" --strict --no-cache
