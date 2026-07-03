---
name: project-structure
description: 토닥운 프로젝트에서 Tuist 설정, Project.swift, Projects/App, Projects/Feature, Projects/Core 파일을 생성·수정하거나 App/Feature/Core 모듈 구조, 의존성, 타겟 설정을 변경할 때 사용합니다.
---

# 토닥운 프로젝트 모듈 및 의존성 규칙

## 적용 범위
이 스킬은 다음 파일군을 생성하거나 수정할 때 적용한다.

- `Tuist/**/*.swift`
- `**/Project.swift`
- `Projects/**/*.swift`
- `docs/graph.dot`
- `docs/graph.png`

## 필수 작업 루틴
구조 변경 또는 기능 구현을 시작하면 다음 순서를 따른다.

1. `README.md`의 Project Structure와 `docs/graph.dot`를 먼저 확인한다.
2. Feature 구현체 간 import, Core 간 import, Core에서 Feature/App import를 만들지 않는다.
3. 최종 보고 전 `./scripts/sync-and-validate.sh`를 실행하고 결과를 보고한다. (스크립트 내부에서 `.dot` 파일 검증과 함께 `.png` 시각화 파일도 자동 갱신해 줌)

## 자동 검증
`./scripts/validate-architecture.sh`는 다음 위반을 검사한다.

- Core가 다른 Core, Feature, App 모듈을 import하는 경우
- Feature 구현체가 다른 Feature 구현체나 App 모듈을 import하는 경우
- Feature Interface가 Feature, Core, TCA에 의존하는 경우
- Feature `Project.swift`가 `makeFeature` 자동 주입 대상(Core 4개, TCA)을 중복 선언하는 경우
- Feature `Project.swift`가 다른 Feature 구현체에 직접 의존하는 경우
- Core `Project.swift`가 내부 프로젝트 의존성을 선언하는 경우
- `docs/graph.dot`에 금지된 물리 의존성 엣지가 생긴 경우

## 1. 3계층 아키텍처 및 계층 정의
이 프로젝트는 **App - Feature - Core** 의 엄격한 3계층 아키텍처를 따른다.

- **App (`Projects/App`)**: 앱의 진입점. 모든 Feature와 필요한 Core 모듈을 엮어 앱 타겟을 빌드한다.
- **Feature (`Projects/Feature/*`)**: 독립적인 비즈니스 로직과 UI 화면 단위 (예: `ActionFeature`).
- **Core (`Projects/Core/*`)**: 앱 전반에서 사용되는 단일 목적의 공통 모듈 (예: `DesignSystem`, `NetworkCore`, `Model`, `Utils`).

## 2. 레이어 간 참조 및 의존성 규칙 (강제 사항)
에이전트는 코드 편집 및 모듈 설정 시 아래의 수평/수직 참조 규칙을 무조건 준수한다.

1. **상향 참조 금지**: 하위 레이어(Core)는 상위 레이어(Feature, App)를 절대 참조하거나 import 할 수 없다.
2. **Feature 간 결합 및 본체 의존성 절대 금지 (uFeature Architecture)**: 
   - `Feature` 모듈의 구체적인 본체(Implementation)끼리는 서로 수평/수직을 불문하고 **절대 import 하거나 참조하지 않는다**.
   - 각 피처는 Interface와 Sources로 분리되며, 피처 간 네비게이션(이동)이 필요할 때는 반드시 상대 피처의 **Interface 타겟**만을 의존하여 의존성 사이클을 끊는다.
   - **조립은 오직 App 레이어에서**: 화면 전환이나 하단 탭바 뼈대(예: `MainTabView`, `RootView`)의 최종 조립은 최상위 `App` 모듈 내부에 작성한다.
   - 피처 간 이동 처리 시, `App` 계층에서 각 피처 Interface의 구현체를 주입해주는 방식으로 제어권을 넘긴다.

3. **Core 간 참조 지양 (원칙적 금지)**: 
   - `Core` 모듈끼리도 서로 의존하지 않고 완전히 독립되도록 설계한다.
   - 만약 여러 코어 모듈이 공유해야 하는 모델이나 유틸이 있다면 하위 공통 모듈로 분리하거나 각각 정의한다.

4. **Tuist 템플릿 사용 및 중복 의존성 방지**:
   - `Project.swift`를 작성할 때 기본 API를 쓰지 않고 `Project.makeFeature(...)` 등의 커스텀 빌더를 사용한다.
   - `makeFeature` 함수 내부에서 `ComposableArchitecture`(TCA) 및 핵심 Core 모듈 4개(`DesignSystem`, `NetworkCore`, `Model`, `Utils`)를 자동 주입하므로, `Project.swift` 내부 `dependencies` 배열에 이들을 중복 선언하지 않는다.
   - `makeFeature(name: "...", hasInterface: true)` 속성을 통해 Interface 타겟과 Implementation 타겟을 생성하고 자동으로 분리시킨다.

5. **정적 프레임워크(Static Framework) 우선 원칙**:
   - 모든 피처 모듈 및 코어 모듈은 기본적으로 **정적 프레임워크(`.staticFramework`)**로 빌드한다.
   - 특정 라이브러리의 빌드 에러나 중복 리소스 충돌 등 정적 링킹이 아예 불가능한 예외적인 상황에서만 제한적으로 다이나믹 프레임워크(`.dynamicFramework`) 전환을 고려한다.

6. **구조 변경 시 문서 동기화 의무 (Synchronization Duty)**:
   - 새로운 모듈(Feature/Core)이 추가되거나, 기존 모듈이 삭제되거나, 모듈 간 의존성 관계가 변경된 경우 **반드시 아래 3가지 동기화 작업을 수행**해야 한다.
   - (1) **논리적 구조도 (Mermaid)**: 프로젝트 루트의 `README.md` 내에 있는 **Mermaid 다이어그램 구조도**에 새로운 모듈을 각 계층(App, Feature, Core) 서브그래프에 알맞게 추가/삭제하여 설계 의도를 최신화한다.
   - (2) **물리적 의존성 (AI용)**: 터미널에서 `mise exec -- tuist graph --skip-test-targets --skip-external-dependencies --format dot --no-open -o docs` 명령을 실행하여 `docs/graph.dot` 파일(실제 의존성 텍스트)을 최신화한다.
   - (3) **물리적 의존성 (인간용)**: 터미널에서 `mise exec -- tuist graph --skip-test-targets --skip-external-dependencies --format png --no-open -o docs` 명령을 실행하여 `docs/graph.png` 파일(인간 열람용 이미지)을 최신화한다.
