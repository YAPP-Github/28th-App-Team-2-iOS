# 토닥운 (todakun)

오늘의 운을 기반으로 사용자의 하루 선택과 행동을 설계하는 데일리 체크인형 자기관리 앱.

## 🛠️ Tech Stack & Architecture
- **Language**: Swift 6.0+
- **Platform**: iOS 17.0+
- **UI Framework**: SwiftUI
- **Architecture**: TCA (The Composable Architecture)
- **Project Generator**: Tuist (Static Frameworks)

## 📁 Project Structure
본 프로젝트는 **App - Feature - Core** 3계층 구조로 이루어진 멀티 모듈 아키텍처로 설계되었습니다. (아래 서술된 내용은 프로젝트가 지향하는 최종 아키텍처 모델이며, 현재는 구조적인 뼈대(Skeleton/Stub) 위주로 구성되어 개발 진행 중입니다.)

특히 **Feature 레이어**는 피처 간 참조 사이클을 방지하고 빌드 최적화를 달성하기 위해 **uFeature 아키텍처(Interface 분리)**를 채택했습니다.
- 각 피처는 `Interface` 타겟과 구체적인 본체 `Implementation` 타겟으로 분리됩니다. (현재는 모듈 분리 및 뼈대 인터페이스만 추가되어 있으며, 피처 기능 구현에 따라 실제 프로토콜이 정의될 예정입니다.)
- 피처의 본체끼리는 절대 서로 참조하지 않으며, 타 피처로의 화면 전환(네비게이션)이 필요할 때는 상대 피처의 **Interface** 타겟만을 의존합니다. (현재는 실제 화면 흐름 바인딩이 구현되지 않은 스텁 상태입니다.)
- `MainTab`이나 `Root`와 같이 전체 피처들을 조립하는 껍데기 화면 코드는 피처 레이어가 아닌 최상위 **`App` 레이어** 내부에 작성되어 최종 런타임 조립(Composition Root)을 담당합니다. (현재 `RootApp`은 임시 SwiftUI View로 구성되어 있으며, 실제 앱 조립은 스텁 상태입니다.)

```mermaid
graph TD
    subgraph AppLayer [App Layer]
        TodakunApp[Todakun App / RootView / MainTabView]
    end

    subgraph FeatureLayer [Feature Layer uFeature Architecture]
        Onboarding[OnboardingFeature]
        OnboardingIF[OnboardingFeatureInterface]
        Fortune[FortuneFeature]
        FortuneIF[FortuneFeatureInterface]
        Todak[TodakFeature]
        TodakIF[TodakFeatureInterface]
        LuckyAction[LuckyActionFeature]
        LuckyActionIF[LuckyActionFeatureInterface]
        MyPage[MyPageFeature]
        MyPageIF[MyPageFeatureInterface]

        Onboarding -.-> OnboardingIF
        Fortune -.-> FortuneIF
        Todak -.-> TodakIF
        LuckyAction -.-> LuckyActionIF
        MyPage -.-> MyPageIF
    end

    subgraph CoreLayer [Core Layer Common Infrastructure]
        DesignSystem[DesignSystem]
        NetworkCore[NetworkCore]
        Model[Model]
        Utils[Utils]
    end

    %% App Layer imports features
    TodakunApp --> Onboarding
    TodakunApp --> Fortune
    TodakunApp --> Todak
    TodakunApp --> LuckyAction
    TodakunApp --> MyPage
    
    %% Example of Feature Navigation via Interface
    LuckyAction -. "Routing (Example/Planned)" .-> FortuneIF
    
    %% Features depend on Core
    Onboarding --> CoreLayer_Nodes[Core Modules]
    Fortune --> CoreLayer_Nodes
    Todak --> CoreLayer_Nodes
    LuckyAction --> CoreLayer_Nodes
    MyPage --> CoreLayer_Nodes

    %% Styling
    classDef app fill:#ff9999,stroke:#333,stroke-width:2px;
    classDef feature fill:#99ccff,stroke:#333,stroke-width:2px;
    classDef interface fill:#ffcc99,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5;
    classDef core fill:#99ff99,stroke:#333,stroke-width:2px;
    
    class TodakunApp app;
    class Onboarding,Fortune,Todak,LuckyAction,MyPage feature;
    class OnboardingIF,FortuneIF,TodakIF,LuckyActionIF,MyPageIF interface;
    class DesignSystem,NetworkCore,Model,Utils core;
```

- **Projects/App**: 진입점 타겟 및 전체 기능 조립 (RootView, MainTabView 포함)
- **Projects/Feature**: 서로 완벽히 격리된 독립적인 비즈니스 로직 및 화면 단위
  - `OnboardingFeature`: 최초 설정 (닉네임, 생년월일, 성별, 관심 주제 선택)
  - `FortuneFeature`: 운세 리포트, 행운 액션 (운세 탭)
  - `TodakFeature`: 고민 결정 도우미 (토닥이 탭)
  - `LuckyActionFeature`: 오늘의 행동 추천 및 실행 (행운 액션 탭)
  - `MyPageFeature`: 설정 및 프로필 (마이 탭)
- **Projects/Core**: 앱 전반에 걸쳐 사용되는 공통 모듈
  - `DesignSystem`: 컬러, 폰트, 공통 UI 컴포넌트 및 에셋
  - `NetworkCore`: 네트워크 API 클라이언트
  - `Model`: 공통 데이터 객체
  - `Utils`: 각종 헬퍼 및 확장 파일

---

## 🚀 Getting Started

### 1. Requirements
본 프로젝트는 **Mise**를 통해 Tuist 버전을 관리합니다. 로컬 컴퓨터에 `mise`가 설치되어 있어야 합니다.
```bash
# mise 설치 (미설치 상태인 경우)
brew install mise

# 설정된 도구들(Tuist 등) 한번에 설치
mise install
```

### 2. Setup & Run
프로젝트 레포지토리를 클론한 후, **최초 1회** Git Hooks를 설정하여 아키텍처 검증 및 Git 컨벤션 룰을 활성화해야 합니다.

```bash
# Git Hooks 설정 (필수)
./scripts/setup-hooks.sh
```

의존성 패키지를 가져온 뒤, Xcode 프로젝트(.xcworkspace)를 생성하여 실행합니다.

*(※ `mise`가 셸에 활성화(`mise activate`)되어 있다면 `mise exec --` 접두사 없이 바로 `tuist` 명령어를 사용할 수 있습니다.)*

```bash
# 의존성 패키지 Fetch (TCA 등)
tuist install

# Xcode Workspace 생성 및 실행
tuist generate
```

### 3. Dependency Graph
프로젝트의 아키텍처 및 모듈 의존성 그래프를 시각화하여 확인하려면 아래 명령어를 사용합니다.
```bash
# 테스트 타겟 및 외부 의존성을 제외하고 코어/피처 아키텍처 및 데모 앱 타겟을 시각화 (png 형식으로 docs/graph.png 저장)
tuist graph --skip-test-targets --skip-external-dependencies --format png --no-open -o docs
```
*(실제 추출된 아키텍처 구조도)*
<br>
<img src="./docs/graph.png" alt="Architecture Graph" width="600">

### 4. Architecture Validation
App / Feature / Core 계층 규칙과 물리 의존성 위반 여부를 빠르게 확인하려면 아래 명령어를 실행합니다. (스크립트 내부에서 자동으로 `tuist graph`를 실행하여 최신 상태의 `docs/graph.dot`를 검증합니다.)
```bash
./scripts/sync-and-validate.sh
```
