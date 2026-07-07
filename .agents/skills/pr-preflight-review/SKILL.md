---
name: pr-preflight-review
description: Draft PR 생성 직후 또는 Ready for review 전환 전에 AI 서브 에이전트 검증을 Quick/Full/Skip 중 선택하도록 묻고, 선택 시 서로 다른 관점에서 비판적으로 검토한 뒤 메인 세션이 지적을 재검증해 타당한 것만 수용하는 검증 하네스. 사용자가 "PR 검증", "preflight", "서브 에이전트 리뷰", "AI 검증", "올리기 전에 검토", "비판적으로 검토" 등을 요청할 때 사용합니다.
---

# PR Preflight Review Harness

이 스킬은 AI가 구현한 변경을 Draft PR로 올린 뒤, 또는 Ready for review 전환 전에 여러 서브 에이전트가 서로 다른 관점에서 비판적으로 검토하도록 하는 검증 절차다. 테스트/빌드/CI를 대체하지 않고, 사람이 전체 코드를 모두 읽지 않아도 주요 위험을 발견하고 판단할 수 있게 돕는 보조 검증망으로 사용한다.

## 적용 범위

다음 상황에서 이 스킬을 적용한다.

- 사용자가 "PR 검증", "preflight", "서브 에이전트 리뷰", "AI 검증", "올리기 전에 검토" 등을 요청한 경우
- Draft PR 생성 직후, 사용자에게 Quick / Full / Skip 검증 여부를 물어야 하는 경우
- Ready for review 전환 전, 남은 위험을 한 번 더 확인해야 하는 경우
- Feature/Core/App 구현, Tuist 설정, 테스트, CI, 문서 등 PR 단위 변경을 마무리하는 경우

단순 오타, 설명 문구만의 수정, 사용자가 명시적으로 생략을 요청한 경우에는 실행하지 않아도 된다.

## 필수 작업 루틴

메인 세션은 다음 순서를 따른다.

1. Draft PR 생성 전에는 가능한 deterministic 검증(빌드, 테스트, 아키텍처 검증 등)을 먼저 실행한다.
2. Draft PR 생성 직후 사용자에게 `"PR Preflight Review를 실행할까요? Quick / Full / Skip 중 선택해주세요."`라고 묻는다.
3. 사용자가 Skip을 선택하면 PR 본문에 생략 사유를 남기고 서브 에이전트 검증을 실행하지 않는다.
4. 사용자가 Quick 또는 Full을 선택하면 변경 의도, 사용자 요구사항, 주요 diff, 이미 실행한 검증 명령을 정리한다.
5. 선택한 모드에 맞는 서로 다른 역할의 서브 에이전트를 병렬로 실행한다.
6. 메인 세션은 돌아온 모든 지적을 직접 재검증한다.
7. 근거가 있는 지적만 수정하고, 추측성/취향성 지적은 기각한다.
8. 수정 후 관련 테스트, 빌드, 아키텍처 검증을 실행한다.
9. 최종 응답과 PR 본문에는 채택/기각한 지적, 실행한 검증, 남은 위험을 보고한다.

## 사전 준비

서브 에이전트를 실행하기 전 아래 정보를 확보한다.

- 사용자 요구사항과 변경 의도
- `git status --short`로 staged, unstaged, untracked 파일 확인
- `git diff --stat`과 주요 변경 파일
- 필요 시 `git diff --cached --stat`과 untracked 파일 목록 확인
- 변경 범위: `Projects/App`, `Projects/Feature`, `Projects/Core`, `Tuist`, `.github`, `scripts`, `docs`, `.agents` 중 어디인지
- 이미 실행한 검증 명령과 결과
- 특히 의심되는 위험 영역

## 서브 에이전트 역할

기본값은 Quick Review이며, 3개 역할을 1라운드만 실행한다. Full Review는 사용자가 명시적으로 요청했거나 Quick Review에서 High/Blocker 위험이 확인된 경우에만 사용한다.

- **Quick Review**: Architecture Guard, Test Coverage & Regression, Build/Tooling & CI. 1라운드.
- **Full Review**: 아래 5개 역할 전체. 최대 2라운드.
- **Skip**: 사용자가 생략을 선택한 경우. PR 본문에 생략 사유를 남긴다.

### 1. Architecture Guard

검토 대상:

- App - Feature - Core 계층 방향
- Feature 구현체 간 직접 의존
- Interface/Testing 타겟의 역할 위반
- Tuist `Project.swift`, `makeFeature`, `makeCore`, `makeApp` 사용
- `docs/graph.dot`, README 구조 설명과 실제 의존성의 일치

필수 확인:

- `.agents/skills/project-structure/SKILL.md`
- `README.md`의 Project Structure
- `docs/graph.dot`
- `scripts/validate-architecture.sh`

### 2. TCA Behavior & State

검토 대상:

- Reducer 상태 전이
- Action 처리 누락
- Effect 생명주기, 취소, 동시성
- Dependency 주입 방식
- View와 Store 바인딩의 불일치

필수 확인:

- 사용자 플로우가 상태/액션으로 검증 가능한지
- 실패, 로딩, 빈 상태, 재시도 상태가 빠지지 않았는지
- 테스트가 실제 상태 변화를 검증하는지

### 3. Test Coverage & Regression

검토 대상:

- `XCTAssertTrue(true)` 같은 형식적 테스트만 추가되었는지
- 핵심 비즈니스 규칙과 회귀 위험이 테스트로 고정되었는지
- 테스트 더블이 `Testing` 타겟의 책임에 맞게 배치되었는지
- PR 설명의 검증 항목과 실제 테스트가 일치하는지

필수 확인:

- 실패 케이스와 경계값
- 기존 기능 회귀 가능성
- 사람이 수동으로 확인해야 하는 항목

### 4. UX Flow & Edge Cases

검토 대상:

- 사용자 입장에서 플로우가 끊기지 않는지
- 빈 화면, 에러, 로딩, 권한, 네트워크 실패 상태
- 접근성, 다크 모드, 작은 화면, 긴 텍스트
- SwiftUI preview/example app이 실제 검증에 도움이 되는지

필수 확인:

- UI 변경 시 Before/After 또는 스크린샷 필요 여부
- 수동 QA가 필요한 시나리오

### 5. Build, Tooling & CI

검토 대상:

- Tuist 설정, 타겟, 리소스, 번들 ID
- `tuist generate`, `tuist test`, `tuist graph` 영향
- Git hooks, PR template, GitHub Actions, verify script
- 문서와 자동화 스크립트의 드리프트

필수 확인:

- 로컬에서 재현 가능한 검증 명령
- CI에서 막히지 않을 설정 문제
- 변경된 문서/스크립트가 실행 권한이나 경로 문제를 만들지 않는지

## 서브 에이전트 지시문 템플릿

역할별 서브 에이전트에는 아래 템플릿을 채워 전달한다.

```text
당신은 Todakun 프로젝트의 PR preflight 비판 리뷰어입니다.

역할: <ROLE_NAME>

목표:
- 현재 작업 diff를 비판적으로 검토합니다.
- 역할 범위에 해당하는 실제 위험만 찾습니다.
- 취향, 근거 없는 리팩터링, 역할 밖의 의견은 제외합니다.

필수 프로젝트 규칙:
- App - Feature - Core 3계층 구조를 지킵니다.
- Feature 구현체끼리는 직접 의존하지 않습니다.
- Core 모듈끼리는 원칙적으로 서로 의존하지 않습니다.
- 구조 변경 시 docs/graph.dot과 README 구조 설명이 실제 구조와 어긋나면 안 됩니다.
- PR 전 검증은 테스트/빌드/아키텍처 검증 결과와 함께 판단해야 합니다.

검토 입력:
- 사용자 요구사항: <USER_REQUIREMENT>
- 변경 요약: <CHANGE_SUMMARY>
- 주요 변경 파일: <CHANGED_FILES>
- 이미 실행한 검증: <VERIFICATION_RESULTS>

출력 형식:
1. Findings
   - Severity: Blocker | High | Medium | Low
   - File/Line:
   - Problem:
   - Why it matters:
   - How to verify:
   - Suggested fix:

2. Non-issues
   - 검토했지만 문제로 보지 않은 항목과 이유

3. Residual risk
   - 자동 검증으로 충분히 확인되지 않는 남은 위험

규칙:
- 파일/라인 또는 구체적 근거가 없는 지적은 Findings에 넣지 마세요.
- 확실하지 않은 내용은 Residual risk에 넣으세요.
- 수정안을 직접 적용하지 말고 리뷰 결과만 보고하세요.
```

## 실행 모드와 반복 루틴

### Quick Review

기본 모드다. 작은 문서/설정 변경이나 일반 PR 검증에는 Quick Review를 우선 제안한다.

1. Architecture Guard, Test Coverage & Regression, Build/Tooling & CI 역할만 병렬로 실행한다.
2. 모든 리뷰 결과를 취합한다.
3. 각 지적을 메인 세션에서 재검증한다.
4. 타당한 지적만 수정한다.
5. 수정 후 관련 테스트 또는 검증 명령을 실행한다.
6. High/Blocker 지적이 남으면 Full Review를 제안하거나 사용자에게 Ready for review 전환 보류를 권고한다.

### Full Review

사용자가 명시적으로 요청했거나, Quick Review에서 High/Blocker 위험이 확인된 경우에만 사용한다.

1. 5개 역할 전체를 병렬로 실행한다.
2. 모든 리뷰 결과를 취합하고 메인 세션에서 재검증한다.
3. 타당한 지적만 수정한다.
4. 수정 diff를 포함해 최대 1회 더 반복한다.
5. 최종 검증 명령을 실행한다.

Full Review 이후에도 Blocker/High 지적이 남으면 Draft PR 자체를 삭제하거나 막지 않는다. 대신 Ready for review 전환을 권고하지 말고, 사용자에게 남은 위험과 선택지를 보고한다.

### Fallback

서브 에이전트 도구가 현재 세션에 없거나 실행할 수 없으면, 메인 세션이 Quick Review의 3개 역할을 순서대로 수행한다. 이 경우 최종 보고에 "서브 에이전트 미사용, 메인 세션 단독 리뷰"라고 명시한다.

## 수용 기준

서브 에이전트 지적은 아래 기준을 통과해야 수용한다.

- 실제 파일/라인 또는 재현 가능한 증거가 있다.
- 프로젝트 규칙, 사용자 요구사항, 테스트 실패, 빌드 실패, 명백한 UX 결함 중 하나와 연결된다.
- 수정했을 때 회귀 위험보다 이득이 크다.
- 역할 밖의 추측이나 취향 문제가 아니다.

채택하지 않은 지적은 최종 보고에 간단히 이유를 남긴다.

## 최종 검증 명령

변경 범위에 따라 실행한다.

- 아키텍처/모듈/Tuist/Project.swift/graph 변경: `./scripts/sync-and-validate.sh`
- 빠른 구조 검증만 필요한 경우: `./scripts/validate-architecture.sh`
- `.agents/skills/*/SKILL.md` 변경: `./scripts/validate-skills.sh` 또는 `./scripts/validate-skills.sh .agents/skills/<skill-name>`
- 테스트 가능한 구현 변경: `tuist test` 또는 해당 타겟 테스트
- 빌드 영향이 있는 변경: `tuist generate` 또는 해당 앱/타겟 빌드

현재 환경에서 명령 실행이 불가능하면, 실행하지 못한 이유와 사용자가 로컬/CI에서 확인해야 할 명령을 최종 보고에 명시한다.

## 최종 보고 형식

PR 전 검증을 마치면 메인 세션은 아래 항목을 보고한다.

- 실행한 라운드 수와 서브 에이전트 역할
- 채택한 지적과 수정 내용
- 기각한 주요 지적과 이유
- 실행한 검증 명령과 결과
- 남은 위험 또는 수동 QA 필요 항목
