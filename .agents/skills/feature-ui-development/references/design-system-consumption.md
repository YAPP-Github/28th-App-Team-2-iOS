# DesignSystem Consumption

## 탐색 원칙

모든 요소에 동일한 탐색 비용을 강제하지 않는다. 먼저 완성 컴포넌트인지 기초 API인지 분류한다.

### 완성 컴포넌트 후보

Button, Header, SelectField, Dialog, BottomNavigation처럼 완성 컴포넌트 후보가 있으면 다음 순서를 따른다.

1. 화면 원본에서 요소의 역할과 상태를 파악한다.
2. `Projects/Core/DesignSystem/Docs/Figma_Specification.md`의 이미지와 구현 매핑으로 시각적·의미적 후보를 찾는다.
3. `Projects/Core/DesignSystem/Sources/Components`의 public 선언에서 실제 initializer, variant, size, state, Binding, action 입력을 확인한다.
4. 배경·상태·레이아웃·동작 계약이 모호할 때만 관련 `Docs/Components/*.md`를 읽는다.
5. presentation이나 상태 조립이 복잡할 때만 `DesignSystem/Example/Sources/Playgrounds`를 참고한다.

Docs는 디자인 의미를, public 코드는 실제 사용 가능한 API를 판단한다. Example은 사용 예시이며 SSOT가 아니다.

### 기초 공개 API

컬러, 타이포그래피, 아이콘, 이미지, 공용 pressed API는 public 코드와 Catalog에서 직접 탐색한다. 상세 Component Docs 확인을 기계적으로 요구하지 않는다.

- `DesignSystemColor.swift`
- `DesignSystemFont.swift`
- `DesignSystemIcon.swift`
- `DesignSystemImage.swift`
- `Components/Common`

### 화면 전용 조합 UI

- 동일한 완성 DS 컴포넌트가 없음을 확인한다.
- 공개 컬러·타이포그래피·아이콘·이미지·shape·pressed API로 Feature 내부에서 조립한다.
- 모든 Figma group을 별도 View로 만들지 않고 의미 있는 섹션, 반복되는 카드, 독립 상호작용 단위만 추출한다.
- 한 화면에서만 쓰인다는 이유로 모든 값을 raw literal로 복제하지 않고 기존 공개 token과 helper를 우선한다.
- Feature 고유 값에 공용 token이 없으면 의미 있는 로컬 이름으로 둘 수 있다.
- 한 화면에서만 쓰면 private, 같은 Feature의 여러 화면에서 재사용하면 Feature-internal로 둔다. 여러 Feature에서 반복되거나 공용 계약으로 승인될 때 DesignSystem 후보가 된다.

## 이미지 리소스 소유권

- **Feature 전용 이미지**: 특정 Feature에서만 소비하는 이미지/일러스트 에셋은 해당 Feature의 `Resources/Assets.xcassets` 하위에 두고 `Project.swift`에 `resources: ["Resources/**"]`를 선언한다. Tuist가 생성하는 Feature 전용 typed accessor(예: `{Feature}Asset.Images.*.swiftUIImage`)를 사용하며 raw string 입력을 금지한다.
- **Cross-feature 공용 이미지**: 온보딩, 브랜드 탭, 복수 Feature 간 공유가 확인된 에셋(예: `fortuneLogo`, `fortuneSpaceBackground`, `chevronSmallRight`)만 DesignSystem의 `DSImageAsset` / `DSIconAsset` 등의 typed public API로 관리한다.
- 신규 이미지가 추가되거나 리소스 소유권이 조정될 때는 Figma 재사용 분석에 기반하여 Feature 전용 에셋과 Cross-feature 공용 에셋을 분리하고 해당 모듈의 asset bundle test를 작성한다.

## 불일치와 누락

- Docs의 디자인 계약과 public 코드가 다르면 Feature에서 수치나 동작을 복제해 우회하지 않는다.
- 현재 컴파일 가능한 계약은 public 코드가 결정하지만, 디자인 불일치는 별도 DesignSystem 결함으로 보고한다.
- 공용 컴포넌트 또는 리소스 변경이 필요하면 `design-system-development` 절차를 적용한다.
- Tuist가 생성한 Derived source를 직접 수정하지 않는다.

## 상호작용 API

- DesignSystem 완성 control이 interaction을 이미 소유하면 외부에서 중복 Button이나 gesture를 감싸지 않는다.
- 화면 전용 surface Button에는 `dsSurfaceButtonStyle(shape:)`를 선택적으로 사용한다.
- 화면 전용 icon Button에는 `dsIconButtonStyle(_:width:height:)`를 선택적으로 사용한다.
- pressed overlay의 색상·opacity를 Feature가 복제하지 않는다.
- 공용 ButtonStyle을 화면 root에 일괄 적용하지 않는다.
