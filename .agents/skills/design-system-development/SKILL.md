---
name: design-system-development
description: DesignSystem 모듈 자체의 컴포넌트, 리소스, Example Playground·Catalog, Specification, 매핑 테스트를 개발하거나 유지보수할 때 사용하는 SSOT 및 검증 가이드
---

# Design System Development Guidelines

Figma를 디자인 값의 원본으로 사용하고, 승인된 값을 해석한 프로덕션 `Specification`을 렌더링·Example·테스트의 런타임 SSOT로 사용한다.

## 1. Specification SSOT

- variant·size·state를 입력받아 완전히 해석된 read-only `Specification`을 컴포넌트별로 정의한다.
- `Specification`에는 렌더링에 필요한 치수, 형태, 타이포그래피, 에셋만 포함한다. title, action, `Binding` 같은 콘텐츠와 동작 입력은 포함하지 않는다.
- 특정 상태에 존재하지 않는 border, icon 등의 속성은 임의 값이나 투명 색상으로 채우지 말고 `nil`로 표현한다.
- View와 SwiftUI Style은 렌더링 디자인 값을 `Specification`에서만 가져온다. 같은 값을 별도 상수나 switch로 다시 결정하지 않는다.
- Example 사양표와 매핑 테스트도 동일한 public 조회 API를 사용한다.
- 현재 필드 구성이 같다는 이유만으로 서로 다른 컴포넌트의 Specification 타입이나 프로토콜을 공통화하지 않는다.
- Example에서도 표시용 Specification이나 공통 중간 모델을 만들지 말고 각 컴포넌트의 Specification을 직접 읽는다.
- 저장 프로퍼티만 public read-only로 노출하고 public initializer는 제공하지 않는다.

## 2. 상태·형태·API

- Figma 또는 요구사항에서 상태, 수치, 동작, API가 불명확하면 추측하지 말고 사용자에게 확인한다. 다른 컴포넌트의 값으로 유추하지 않는다.
- selected·checked처럼 화면이 소유하는 상태는 값이나 `Binding`으로 입력받는다.
- enabled/disabled처럼 SwiftUI가 제공하는 상태는 Environment를 사용하고, pressed 같은 순간 상태는 Style의 `Configuration`을 사용한다.
- Figma에 정의되지 않은 pressed·disabled·loading 상태를 임의로 추가하지 않는다. 승인되면 Specification 입력과 테스트를 함께 확장한다.
- 여러 독립 축을 하나의 조합 enum으로 합치지 않는다. variant, size, state를 독립 입력으로 유지한다.
- 정적 표시 컴포넌트는 no-op action이나 불필요한 ButtonStyle을 만들지 않는다.
- 인터랙티브 컴포넌트의 `ButtonStyle`/`ToggleStyle`은 internal로 두고 resolved Specification만 소비하게 한다.
- Capsule은 숫자 radius로 흉내 내지 말고 `DSComponentShape.capsule`로 표현한다.
- 컴포넌트 사이 간격처럼 부모 레이아웃이 결정할 값은 Specification에 포함하지 않는다.
- Base init을 기본 API로 사용하고, 팀이 합의한 다중 조합에만 convenience wrapper를 제공한다.

## 3. Example 및 Debug 지원

- Playground Preview에는 현재 선택한 컴포넌트 하나만 렌더링한다.
- Preview 이름은 실제 렌더링하는 public 타입과 일치시킨다. wrapper를 렌더링하면서 base 타입명을 표시하지 않는다.
- 사양표는 Specification 값을 포맷할 뿐 디자인 값을 문자열이나 조건문으로 재정의하지 않는다.
- `DesignSystemDebugExtensions`는 hex, 에셋 표시 이름, `pt` 단위 등 표시만 담당한다. 변환 실패 시 실제 디자인 값처럼 보이는 fallback을 만들지 않는다.
- Capsule은 숫자 radius 없이 형태명으로 표시하고, Example 전용 View와 helper는 불필요하게 public으로 노출하지 않는다.

### DEBUG 레이아웃 검사기

- `dsDebugLayoutInspector()`는 App 또는 Example 루트에 한 번만 설치한다. Feature 사용처의 개별 View에는 검사 modifier를 등록하지 않는다.
- DesignSystem 컴포넌트가 외곽과 내부의 의미 있는 영역을 자기 구현 안에서 보고한다.
- 검사기 진입 API·구현 타입·상태·테스트는 모두 `#if DEBUG`에서만 컴파일한다.
- 컴포넌트 호출부의 분기를 없애기 위해 internal geometry helper는 Release에서 이름을 평가하지 않고 `Self`를 반환하는 no-op을 제공한다. no-op에 View modifier나 상태를 추가하지 않는다.
- 컴포넌트 디버그 이름은 저장 프로퍼티로 만들지 않고 private 계산 프로퍼티 또는 `@autoclosure` 표현식으로 둔다. 이름 문자열 보간과 계산 프로퍼티 접근은 geometry helper 또는 `dsFont(_:debugName:)`의 인자 위치에 직접 작성하고, `body`의 지역 `let`·`var`로 미리 계산하지 않는다.
- App·Example처럼 DesignSystem 외부 모듈에서 호출하는 `dsDebugLayoutInspector()`만 DEBUG 빌드에서 public으로 선언한다. DesignSystem 내부에서만 사용하는 geometry helper와 구현 타입은 internal 또는 private로 제한한다.
- DEBUG 전용 구현을 검사하는 테스트 파일은 전체를 `#if DEBUG`로 감싼다.

## 4. 리소스

1. 모든 리소스를 `Projects/Core/DesignSystem/Resources` 아래에서 관리한다. 컬러와 아이콘은 `Resources/Assets.xcassets`에, `.otf` 폰트는 `Resources`에 둔다.
2. 리소스를 추가·삭제·이름 변경한 경우 프로젝트 루트에서 `mise exec -- tuist generate --no-open`을 실행해 Swift 접근 코드를 갱신한다.
3. `Derived/Sources`의 Tuist 생성 파일은 직접 수정하지 않는다.
4. 컬러와 아이콘은 `DesignSystemColor.swift`·`DesignSystemIcon.swift`의 `.ds` API에 연결하고, 폰트는 `DesignSystemFont.swift`의 `FontStyle`과 `.ds` API에 연결한다.
5. Color/Icon/Font Catalog에 등록한다.
6. 컬러·아이콘 리소스 또는 `.ds` 브릿지·Catalog를 변경한 경우 `./scripts/validate-design-system-assets.sh`를 실행한다. 이 검증은 DesignSystem 리소스 작업에만 적용한다.

## 5. 컴포넌트 작업 순서

1. Figma의 variant·size·state·값을 확인하고 애매한 항목을 사용자에게 확인한다.
2. 컴포넌트 전용 public read-only Specification과 조회 API를 구현한다.
3. View/Style의 렌더링 디자인 값을 Specification에 연결한다.
4. DEBUG 레이아웃 검사기에서 컴포넌트 외곽과 측정 가치가 있는 내부 영역을 구현 안에서 보고한다. 컴포넌트 외곽은 `dsDebugGeometry`, 행간을 포함한 Text 영역은 `dsFont(_:debugName:)`, 그 밖의 서로 다른 내부 레이아웃 영역은 `dsDebugDetailGeometry`를 사용한다. 내부의 모든 View에 기계적으로 적용하지 않고 아이콘·콘텐츠 그룹·상태 표시·슬롯 등 레이아웃 경계나 Specification 값을 확인할 수 있는 영역만 등록한다. 배경·테두리·그림자처럼 장식 목적이거나 기존 영역과 프레임이 같은 요소는 제외한다. 이미 geometry를 보고하는 하위 DesignSystem 컴포넌트를 조합할 때는 동일 영역을 부모에서 중복 등록하지 않고, 부모가 추가한 외곽·컨테이너·padding 경계만 등록한다. 각 helper의 Release no-op을 사용하므로 컴포넌트 호출부를 `#if DEBUG`로 분기하지 않는다.
5. 단일 컴포넌트 Playground와 사양표를 추가한다.
6. Components Catalog에 등록한다.
7. 컴포넌트별 테스트 파일에 모든 Specification 조합의 매핑 테스트를 추가한다.

## 6. 검증

전체 workspace를 먼저 생성하고, 이후 테스트와 Example 빌드는 workspace를 다시 생성하지 않는 `tuist xcodebuild`로 실행한다.

테스트 실행 전 `xcrun simctl list devices available`로 사용 가능한 기기를 확인한다. `Booted` 상태의 iOS Simulator를 우선 선택하고, 없으면 사용 가능한 iOS Simulator를 선택한다. 선택한 실제 UDID를 현재 셸의 `SIMULATOR_ID`에 설정하며 placeholder 문자열을 값으로 사용하지 않는다.

```bash
mise exec -- tuist generate --no-open
./scripts/validate-design-system-assets.sh # 컬러·아이콘 리소스 또는 브릿지·Catalog 변경 시
xcrun simctl list devices available
```

실제 UDID를 `SIMULATOR_ID`에 설정한 현재 셸에서 다음 검증을 실행한다.

```bash
: "${SIMULATOR_ID:?실제 iOS Simulator UDID를 설정하세요.}"
DESTINATION="platform=iOS Simulator,id=$SIMULATOR_ID"
mise exec -- tuist xcodebuild test -workspace todakun.xcworkspace -scheme DesignSystem -destination "$DESTINATION" CODE_SIGNING_ALLOWED=NO
mise exec -- tuist xcodebuild build -workspace todakun.xcworkspace -scheme DesignSystemExample -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
./scripts/sync-and-validate.sh
```

위 DesignSystem 테스트와 Debug Example 빌드는 모든 DesignSystem 코드 변경에 적용한다.

레이아웃 검사기의 구현, DEBUG/Release 컴파일 경계, Release no-op helper, 디버그 이름 평가 방식, 접근 제어 또는 빌드 설정을 변경했다면 `./scripts/validate-design-system-layout-inspector-release.sh`를 추가로 실행한다. 이 스크립트는 Release Example을 별도 DerivedData에 빌드한 뒤 앱·정적 DesignSystem 산출물의 검사기 구현 심볼, 환경변수·UI·디버그 이름 문자열, 공개 ABI의 디버그 API 노출 여부를 검사한다. 기존 helper를 사용해 컴포넌트의 geometry 영역만 추가·수정한 경우에는 이 Release 검증을 생략한다.
