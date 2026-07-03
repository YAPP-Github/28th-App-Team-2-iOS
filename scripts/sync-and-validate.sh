#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

TEMP_DOT="docs/graph.dot.tmp"
TEMP_SORTED="docs/graph.dot.sorted"
ORIG_BACKUP="docs/graph.dot.bak"

# Ensure docs directory exists
mkdir -p docs

# Backup existing graph.dot
if [ -f "docs/graph.dot" ]; then
  cp "docs/graph.dot" "$ORIG_BACKUP"
fi

printf 'Generating temporary dependency graph...\n'
if command -v mise >/dev/null 2>&1; then
  mise exec -- tuist graph --skip-test-targets --skip-external-dependencies --format dot --no-open -o docs >/dev/null 2>&1
else
  tuist graph --skip-test-targets --skip-external-dependencies --format dot --no-open -o docs >/dev/null 2>&1
fi

if [ -f "docs/graph.dot" ]; then
  mv "docs/graph.dot" "$TEMP_DOT"
else
  printf 'error: Failed to generate graph.dot\n' >&2
  # Restore backup if it failed
  if [ -f "$ORIG_BACKUP" ]; then
    mv "$ORIG_BACKUP" "docs/graph.dot"
  fi
  exit 1
fi

# Restore the original graph.dot for comparison
if [ -f "$ORIG_BACKUP" ]; then
  mv "$ORIG_BACKUP" "docs/graph.dot"
fi

# Sort body of DOT file alphabetically to ensure 100% determinism (Tuist order is random)
head -n 1 "$TEMP_DOT" > "$TEMP_SORTED"
tail -n +2 "$TEMP_DOT" | sed '$d' | sort >> "$TEMP_SORTED"
tail -n 1 "$TEMP_DOT" >> "$TEMP_SORTED"

# Check if there is an actual semantic difference
CHANGES_DETECTED=1
if [ -f "docs/graph.dot" ]; then
  if cmp -s "$TEMP_SORTED" "docs/graph.dot"; then
    CHANGES_DETECTED=0
  fi
fi

if [ $CHANGES_DETECTED -eq 1 ]; then
  printf 'Changes detected in dependency graph. Updating docs/graph.dot and docs/graph.png...\n'
  mv "$TEMP_SORTED" "docs/graph.dot"
  
  if command -v mise >/dev/null 2>&1; then
    mise exec -- tuist graph --skip-test-targets --skip-external-dependencies --format png --no-open -o docs >/dev/null 2>&1
  else
    tuist graph --skip-test-targets --skip-external-dependencies --format png --no-open -o docs >/dev/null 2>&1
  fi

  printf '\n[⚠️ Warning] 아키텍처 다이어그램이 실제 프로젝트 구조(코드)와 일치하지 않아 최신 상태로 갱신되었습니다.\n' >&2
  rm -f "$TEMP_DOT"
  exit 1
else
  printf 'No changes in dependency graph. Keeping existing files (preventing dirty workspace).\n'
  rm -f "$TEMP_SORTED"
fi

rm -f "$TEMP_DOT"

printf 'Running architecture validation...\n'
./scripts/validate-architecture.sh
