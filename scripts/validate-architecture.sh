#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

failures=0

fail() {
  printf 'error: %s\n' "$1" >&2
  failures=$((failures + 1))
}

contains_name() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

swift_imports() {
  sed -E -n 's/^[[:space:]]*(@[A-Za-z0-9_]+[[:space:]]+)?import[[:space:]]+((struct|class|enum|protocol|typealias|func|let|var)[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*).*/\4/p' "$1"
}

feature_names=()
while IFS= read -r dir; do
  feature_names+=("$(basename "$dir")")
done < <(find Projects/Feature -mindepth 1 -maxdepth 1 -type d | sort)

feature_interface_names=()
for feature in "${feature_names[@]}"; do
  feature_interface_names+=("${feature}Interface")
done

core_names=()
while IFS= read -r dir; do
  core_names+=("$(basename "$dir")")
done < <(find Projects/Core -mindepth 1 -maxdepth 1 -type d | sort)

app_name="$(sed -n 's/.*name:[[:space:]]*"\([^"]*\)".*/\1/p' Projects/App/Project.swift | head -n 1)"

lower_core_names=("Model" "Utils")

check_core_imports() {
  local core file import
  for core in "${core_names[@]}"; do
    while IFS= read -r file; do
      while IFS= read -r import; do
        if contains_name "$import" "${feature_names[@]}" || contains_name "$import" "${feature_interface_names[@]}"; then
          fail "$file imports Feature layer module '$import'. Core must not depend on Feature."
        fi

        if contains_name "$import" "${core_names[@]}"; then
          if ! contains_name "$core" "${lower_core_names[@]}" && contains_name "$import" "${lower_core_names[@]}"; then
            # 상위 Core -> 하위 Core 단방향 참조 허용
            :
          else
            fail "$file imports Core module '$import'. Core modules must remain independent."
          fi
        fi

        if [[ "$import" == "$app_name" ]]; then
          fail "$file imports App module '$import'. Core must not depend on App."
        fi
      done < <(swift_imports "$file")
    done < <(find "Projects/Core/$core/Sources" -name '*.swift' -type f -print)
  done
}

check_feature_imports() {
  local feature file import other
  for feature in "${feature_names[@]}"; do
    while IFS= read -r file; do
      while IFS= read -r import; do
        for other in "${feature_names[@]}"; do
          if [[ "$other" != "$feature" && "$import" == "$other" ]]; then
            fail "$file imports Feature implementation '$import'. Feature implementations must not depend on each other."
          fi
        done

        if [[ "$import" == "$app_name" ]]; then
          fail "$file imports App module '$import'. Feature must not depend on App."
        fi
      done < <(swift_imports "$file")
    done < <(find "Projects/Feature/$feature/Sources" -name '*.swift' -type f -print)

    if [[ -d "Projects/Feature/$feature/Interface/Sources" ]]; then
      while IFS= read -r file; do
        while IFS= read -r import; do
          if contains_name "$import" "${feature_names[@]}" || contains_name "$import" "${feature_interface_names[@]}"; then
            fail "$file imports Feature module '$import'. Interface targets must stay minimal and dependency-free."
          fi

          if contains_name "$import" "${core_names[@]}"; then
            fail "$file imports Core module '$import'. Interface targets currently have no Core dependencies."
          fi

          if [[ "$import" == "ComposableArchitecture" ]]; then
            fail "$file imports ComposableArchitecture. Interface targets must not depend on TCA."
          fi
        done < <(swift_imports "$file")
      done < <(find "Projects/Feature/$feature/Interface/Sources" -name '*.swift' -type f -print)
    fi

    if [[ -d "Projects/Feature/$feature/Testing/Sources" ]]; then
      while IFS= read -r file; do
        while IFS= read -r import; do
          if [[ "$import" == "$feature" ]]; then
            fail "$file imports Feature implementation '$import'. Testing targets must not depend on concrete implementations."
          fi

          for other in "${feature_names[@]}"; do
            if [[ "$import" == "$other" ]]; then
              fail "$file imports Feature implementation '$import'. Testing targets must depend on Feature Interface, not concrete implementation."
            fi
          done

          if [[ "$import" == "$app_name" ]]; then
            fail "$file imports App module '$import'. Testing targets must not depend on App."
          fi
        done < <(swift_imports "$file")
      done < <(find "Projects/Feature/$feature/Testing/Sources" -name '*.swift' -type f -print)
    fi
  done
}

check_project_swift_files() {
  local feature project_file core other core_project

  for feature in "${feature_names[@]}"; do
    project_file="Projects/Feature/$feature/Project.swift"
    if [[ ! -f "$project_file" ]]; then
      fail "Projects/Feature/$feature is missing Project.swift."
      continue
    fi

    if ! grep -q 'Project.makeFeature' "$project_file"; then
      fail "$project_file must use Project.makeFeature(...)."
    fi

    if grep -Eq '\.external\(name:[[:space:]]*"ComposableArchitecture"\)' "$project_file"; then
      fail "$project_file duplicates ComposableArchitecture. makeFeature injects it automatically."
    fi

    for core in "${core_names[@]}"; do
      if grep -Eq "\\.project\\(target:[[:space:]]*\"$core\"" "$project_file"; then
        fail "$project_file duplicates Core dependency '$core'. makeFeature injects Core modules automatically."
      fi
    done

    for other in "${feature_names[@]}"; do
      if [[ "$other" != "$feature" ]] && grep -Eq "\\.project\\(target:[[:space:]]*\"$other\"" "$project_file"; then
        fail "$project_file depends on Feature implementation '$other'. Depend on '${other}Interface' instead."
      fi
    done
  done

  for core in "${core_names[@]}"; do
    core_project="Projects/Core/$core/Project.swift"
    if [[ ! -f "$core_project" ]]; then
      fail "Projects/Core/$core is missing Project.swift."
      continue
    fi

    if ! grep -q 'Project.makeCore' "$core_project"; then
      fail "$core_project must use Project.makeCore(...)."
    fi

    local target_dep
    while read -r target_dep; do
      if [[ -n "$target_dep" ]]; then
        if contains_name "$core" "${lower_core_names[@]}"; then
          fail "$core_project declares an internal project dependency '$target_dep'. Lower Core must remain independent."
        elif ! contains_name "$target_dep" "${lower_core_names[@]}"; then
          fail "$core_project declares a forbidden internal project dependency '$target_dep'. Upper Core can only depend on Lower Core."
        fi
      fi
    done < <(perl -0777 -ne 'while(/\.project\(\s*target:\s*"([^"]+)"/g){print "$1\n"}' "$core_project")
  done

  if ! grep -q 'Project.makeApp' Projects/App/Project.swift; then
    fail "Projects/App/Project.swift must use Project.makeApp(...)."
  fi
}

check_graph_edge() {
  local from="$1"
  local to="$2"

  if contains_name "$from" "${core_names[@]}"; then
    if ! contains_name "$from" "${lower_core_names[@]}" && contains_name "$to" "${lower_core_names[@]}"; then
      # 상위 Core -> 하위 Core 단방향 참조 허용
      return
    fi
    fail "docs/graph.dot has forbidden Core outgoing edge: $from -> $to"
    return
  fi

  if contains_name "$from" "${feature_interface_names[@]}"; then
    fail "docs/graph.dot has forbidden Interface outgoing edge: $from -> $to"
    return
  fi

  if contains_name "$from" "${feature_names[@]}"; then
    if contains_name "$to" "${core_names[@]}"; then
      return
    fi

    if contains_name "$to" "${feature_interface_names[@]}"; then
      return
    fi

    if contains_name "$to" "${feature_names[@]}"; then
      fail "docs/graph.dot has forbidden Feature implementation edge: $from -> $to"
      return
    fi

    if [[ "$to" == "$app_name" ]]; then
      fail "docs/graph.dot has forbidden Feature to App edge: $from -> $to"
      return
    fi

    fail "docs/graph.dot has unexpected Feature edge: $from -> $to"
    return
  fi

  if [[ "$from" == *Example && ( "$to" == "${from%Example}" || "$to" == "${from%Example}Testing" ) ]]; then
    return
  fi

  if [[ "$from" == *Example ]]; then
    fail "docs/graph.dot has unexpected Example edge: $from -> $to"
    return
  fi

  if [[ "$from" == *FeatureTesting ]]; then
    if contains_name "$to" "${feature_interface_names[@]}"; then
      return
    fi
    if contains_name "$to" "${core_names[@]}"; then
      return
    fi
    fail "docs/graph.dot has forbidden Testing outgoing edge: $from -> $to"
    return
  fi

  if [[ "$from" == "$app_name" ]]; then
    if contains_name "$to" "${feature_names[@]}" || contains_name "$to" "${core_names[@]}"; then
      return
    fi

    fail "docs/graph.dot has unexpected App edge: $from -> $to"
    return
  fi
}

check_graph_dot() {
  local line from to

  if [[ ! -f docs/graph.dot ]]; then
    fail "docs/graph.dot is missing. Regenerate it with tuist graph after dependency changes."
    return
  fi

  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*([A-Za-z0-9_]+)[[:space:]]*-\>[[:space:]]*([A-Za-z0-9_]+) ]]; then
      from="${BASH_REMATCH[1]}"
      to="${BASH_REMATCH[2]}"
      check_graph_edge "$from" "$to"
    fi
  done < docs/graph.dot
}

check_readme_mermaid() {
  if [[ ! -f README.md ]]; then return; fi

  local module
  local mermaid_content
  mermaid_content=$(sed -n '/```mermaid/,/```/p' README.md)

  for module in "${feature_names[@]}" "${feature_interface_names[@]}" "${core_names[@]}"; do
    if ! echo "$mermaid_content" | grep -q "\[$module\]"; then
      fail "README.md Mermaid diagram is missing module '$module'. Please update the logical architecture diagram."
    fi
  done

  local readme_modules=()
  while IFS= read -r module; do
    if [[ -n "$module" ]]; then
      readme_modules+=("$module")
    fi
  done < <(echo "$mermaid_content" | grep -o '\[[A-Za-z0-9_]*\]' | tr -d '[]')

  for module in "${readme_modules[@]}"; do
    if ! contains_name "$module" "${feature_names[@]}" "${feature_interface_names[@]}" "${core_names[@]}"; then
      fail "README.md Mermaid diagram contains module '$module' which does not exist physically. Please remove it from the diagram."
    fi
  done
}

check_core_imports
check_feature_imports
check_project_swift_files
check_graph_dot
check_readme_mermaid

if [[ "$failures" -eq 0 ]]; then
  printf 'Architecture validation passed.\n'
  exit 0
fi

printf 'Architecture validation failed with %d issue(s).\n' "$failures" >&2
exit 1
