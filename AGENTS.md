# Todakun Project — AI Context Harness

토닥운 프로젝트(YAPP 28기)의 AI 코딩 어시스턴트를 위한 중앙 인덱스 문서다.

## 프로젝트 개요
- **기술 스택**: SwiftUI, TCA (The Composable Architecture) 1.25.5, Tuist
- **아키텍처**: App - Feature - Core 의 3계층 멀티 모듈 아키텍처

### 🏗️ 전역 아키텍처 및 의존성 구조 (Dependency Graph)
에이전트는 코드 수정 전 아래의 구조를 반드시 숙지할 것. 
- **조립은 오직 App 레이어에서**: 화면 전환 및 탭바 뼈대(`MainTabView`, `RootView`)는 최상위 `App` 모듈 내부에 위치하며, 모든 피처를 직접 임포트하여 조립한다.
- **Feature 레이어 (uFeature 패턴 도입)**:
  - 각 피처는 `Interface` 타겟과 구체적인 본체 `Implementation` 타겟으로 분리된다.
  - 피처 본체끼리는 절대 서로 참조하거나 의존하지 않는다. 다른 피처로의 이동이 필요할 때는 상대 피처의 `Interface` 타겟만 의존하여 사이클을 끊는다.
- **Core 레이어 내부**: Core 모듈끼리도 원칙적으로 서로 의존/참조하지 않는다 (`Projects/Core/*`).
- **정적 프레임워크 우선 원칙**: 모든 내부 모듈은 기본적으로 **정적 프레임워크(`.staticFramework`)** 형식으로 설계한다. 예외적인 빌드 이슈 시에만 다이나믹 전환을 고려한다.
- **아키텍처 검증 필수**: `Projects/App`, `Projects/Feature`, `Projects/Core`, `Tuist`, `Project.swift`, `docs/graph.dot` 중 하나라도 수정했다면 최종 보고 전 `./scripts/validate-architecture.sh`를 실행하고 결과를 보고한다.

> **참조**: 아키텍처 다이어그램(Mermaid)은 프로젝트 루트의 [`README.md`](./README.md) 내 **Project Structure** 섹션을 확인하라.
> **참고**: 실제 빌드 상의 물리적 의존성 연결 실체는 [`docs/graph.dot`](./docs/graph.dot) (DOT 텍스트 포맷)을 읽고 분석하라.
> 또한 `Tuist`의 `makeFeature` 템플릿을 사용하면 Feature 레이어의 타겟에 `Core Layer` 및 `ComposableArchitecture`가 **자동으로 의존성 주입**된다. 

### Default Workflow (Issue-Driven Development)
AI가 이 프로젝트 내에서 기능 추가, 버그 수정, 리팩토링 등의 작업을 진행할 때는 무조건 [project-management](./.agents/skills/project-management/SKILL.md) 스킬에 정의된 이슈 수립 및 보드 연동 흐름을 최우선으로 준수한다.

요약 워크플로우 파이프라인:
- **작업 개시**: 이슈 조회 및 생성, 프로젝트 보드 연동 ➡️ [issue-management](./.agents/skills/issue-management/SKILL.md)
- **개발 진행**: 브랜치 생성 및 커밋 메시지 작성 ➡️ [git-harness](./.agents/skills/git-harness/SKILL.md)
- **작업 마무리**: PR 생성 및 본문 작성 ➡️ [pull-request-management](./.agents/skills/pull-request-management/SKILL.md)


### Architecture Guardrail
AI가 구조 변경 또는 기능 구현을 수행할 때는 다음 순서를 따른다.

1. 변경 전 `.agents/skills/project-structure/SKILL.md`, `README.md`의 Project Structure, `docs/graph.dot`를 확인한다.
2. 구현 중 Feature 구현체 간 import, Core 간 import, Core → Feature/App import를 만들지 않는다.
3. 최종 응답 전 `./scripts/sync-and-validate.sh`를 실행한다. (스크립트가 자동으로 `docs/graph.dot` 검증과 함께 시각화 자료인 `docs/graph.png`도 알아서 최신화해 줌)

## 세부 규칙 (Skills & Rules)
이 프로젝트는 AI의 컨텍스트를 절약하고 정확성을 높이기 위해 **모듈형 하이브리드 규칙(Hybrid Modular Rules)**을 사용한다. 특정 폴더의 파일을 수정하거나 관련 작업을 수행할 때, 다음의 스킬/규칙이 자동으로 로드되거나 트리거된다.

- `project-management`: 이 프로젝트의 전반적인 작업 수립, 이슈 조회/생성 여부 질문 프로세스 및 프로젝트 보드 연동 시 무조건 참고함 (이슈 탐색, PR 닫기 연동 등)
- `issue-management`: 큰 요구사항을 하위 작업으로 쪼개고, 템플릿과 라벨에 맞춘 이슈 생성 규칙 (하위 이슈 분리, 템플릿 및 라벨 적용 등)
- `pull-request-management`: PR 템플릿 작성 규칙 및 UI 변경 시 스크린샷/WebP 파일 임베딩 지침 (PR 템플릿, 시각 자료 첨부 등)
- `project-structure`: 모듈 생성, 구조 변경, 파일 수정 시 트리거됨 (3계층 구조 강제, Feature/Core 결합 금지 등)
- `git-harness`: 커밋 메시지 작성, 브랜치 생성, 푸시(push) 작업 등 Git 관련 행동 시 트리거됨 (Conventional Commits, Force Push 차단 등)
- `pr-preflight-review`: Draft PR 생성 직후 또는 Ready for review 전환 전 검증 요청 시 트리거됨 (Quick/Full/Skip 선택형 서브 에이전트 리뷰)

> ⚠️ **AI 지시사항**: 모듈 설정이나 파일 구조 변경 시, `.agents/skills/`의 스킬 규칙을 직접 참조할 것.

## PR Preflight Review
Draft PR 생성 직후, Ready for review 전환 전, 또는 사용자가 "PR 검증", "preflight", "서브 에이전트 리뷰", "AI 검증" 등을 요청하면 [`.agents/skills/pr-preflight-review/SKILL.md`](./.agents/skills/pr-preflight-review/SKILL.md)의 절차를 따른다. 세부 실행 모드와 반복 정책은 해당 스킬 문서를 단일 기준으로 삼는다.
