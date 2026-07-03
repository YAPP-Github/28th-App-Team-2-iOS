#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

printf 'Regenerating docs/graph.dot and docs/graph.png...\n'
if command -v mise >/dev/null 2>&1; then
  mise exec -- tuist graph --skip-test-targets --skip-external-dependencies --format dot --no-open -o docs >/dev/null 2>&1
  mise exec -- tuist graph --skip-test-targets --skip-external-dependencies --format png --no-open -o docs >/dev/null 2>&1
else
  tuist graph --skip-test-targets --skip-external-dependencies --format dot --no-open -o docs >/dev/null 2>&1
  tuist graph --skip-test-targets --skip-external-dependencies --format png --no-open -o docs >/dev/null 2>&1
fi

printf 'Running architecture validation...\n'
./scripts/validate-architecture.sh
