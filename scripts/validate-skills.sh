#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

failures=0

fail() {
  printf 'error: %s\n' "$1" >&2
  failures=$((failures + 1))
}

validate_skill() {
  local dir="$1"
  local file="$dir/SKILL.md"
  local expected_name
  local end_line
  local name
  local description

  expected_name="$(basename "$dir")"

  if [[ ! -f "$file" ]]; then
    fail "$dir is missing SKILL.md."
    return
  fi

  if [[ "$(sed -n '1p' "$file")" != "---" ]]; then
    fail "$file must start with YAML frontmatter delimiter '---'."
    return
  fi

  end_line="$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "$file")"
  if [[ -z "$end_line" ]]; then
    fail "$file is missing closing YAML frontmatter delimiter '---'."
    return
  fi

  name="$(awk -v end="$end_line" 'NR > 1 && NR < end && /^name:[[:space:]]*/ { sub(/^name:[[:space:]]*/, ""); gsub(/^"|"$/, ""); print; exit }' "$file")"
  description="$(awk -v end="$end_line" 'NR > 1 && NR < end && /^description:[[:space:]]*/ { sub(/^description:[[:space:]]*/, ""); gsub(/^"|"$/, ""); print; exit }' "$file")"

  if [[ -z "$name" ]]; then
    fail "$file frontmatter must include name."
  elif [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
    fail "$file name '$name' must use lowercase letters, digits, and hyphens only."
  elif [[ "$name" != "$expected_name" ]]; then
    fail "$file name '$name' must match folder name '$expected_name'."
  fi

  if [[ -z "$description" ]]; then
    fail "$file frontmatter must include a non-empty description."
  fi
}

if [[ "$#" -gt 0 ]]; then
  for dir in "$@"; do
    validate_skill "$dir"
  done
else
  if [[ ! -d ".agents/skills" || ! -r ".agents/skills" || ! -x ".agents/skills" ]]; then
    fail ".agents/skills directory is missing or unreadable."
  else
    while IFS= read -r dir; do
      validate_skill "$dir"
    done < <(find .agents/skills -mindepth 1 -maxdepth 1 -type d | sort)
  fi
fi

if [[ "$failures" -eq 0 ]]; then
  printf 'Skill validation passed.\n'
  exit 0
fi

printf 'Skill validation failed with %d issue(s).\n' "$failures" >&2
exit 1
