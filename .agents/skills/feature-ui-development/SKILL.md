---
name: feature-ui-development
description: Todakun의 Projects/Feature 또는 Projects/App에서 SwiftUI 화면을 구현·수정·리뷰하거나 Figma·기획 화면을 기존 DesignSystem으로 조립할 때 적용합니다. TCA 화면 상태와 View 책임, 화면 전용 조합 View의 경계, DesignSystem public API 선택, 반응형 레이아웃·이미지·스크롤·safe area, 버튼 상호작용 및 실제 기기 렌더링 검증을 다룹니다. DesignSystem 모듈 자체 개발, Feature API 연동, 접근성 정책 수립에는 사용하지 않습니다.
---

# Feature UI Development

기획·Figma의 시각적 의도를 특정 캔버스의 고정 좌표가 아니라 SwiftUI 레이아웃으로 해석하고, 기존 DesignSystem과 TCA 경계를 지키며 화면을 구현한다.

## 책임 경계

- 코드나 파일을 변경하는 작업의 개시와 이슈 관리는 `project-management`를 따른다. 읽기 전용 설계·리뷰에는 변경 작업용 이슈 절차를 기계적으로 요구하지 않는다.
- 모듈·타겟·Feature 간 의존성은 `project-structure`를 따른다.
- DesignSystem 소스·Specification·Docs·Catalog·리소스를 변경하면 `design-system-development`로 전환한다.
- Feature API client·DTO·live dependency·네트워크 effect는 `feature-networking`으로 분리한다.
- 특정 Figma 도구나 추출 경로를 요구하지 않는다. 이용 가능한 방법으로 원본 화면과 필요한 상태를 확보한다.
- 접근성, 현지화, motion은 팀의 별도 요구사항이 있을 때만 해당 범위로 추가한다.

## 필요한 참조

- 화면이 여러 섹션, TCA 상태, 컬렉션을 포함하면 [view-composition.md](references/view-composition.md)를 읽는다.
- Figma 화면, 기기별 레이아웃, 이미지, 배경, 스크롤을 다루면 [adaptive-layout.md](references/adaptive-layout.md)를 읽는다.
- DesignSystem을 사용하는 모든 화면은 [design-system-consumption.md](references/design-system-consumption.md)를 읽는다.
- UI 변경 완료 전 [verification.md](references/verification.md)를 읽고 실제 렌더링을 검증한다.

## 구현 흐름

### 1. 화면 계약 파악

1. 구현할 화면, 진입점, 사용자 동작, loading·loaded·failed 등 필요한 상태를 확인한다.
2. 화면 요소를 다음으로 분류한다.
   - 기존 DesignSystem 완성 컴포넌트
   - DesignSystem의 공개 컬러·타이포그래피·아이콘·이미지·상호작용 API로 조립할 화면 전용 UI
   - 여러 화면에서 반복될 가능성이 있는 신규 공용 컴포넌트 후보
   - Feature 상태와 사용자 Action
   - 다른 Feature 또는 App 조립 계층으로 전달할 이동 의도
3. Figma 수치를 `고정`, `유동`, `최솟값`, `비율`, `콘텐츠 기반`으로 분류한다. Figma 프레임의 결과값을 분류 없이 코드에 옮기지 않는다.
4. 원본에서 모호한 상태·동작·레이아웃은 다른 화면을 근거로 추측하지 않는다.

### 2. TCA와 공개 경계 결정

- State에는 화면 렌더링·동작·effect·테스트의 source of truth가 되는 값과, 화면 계약을 결정하는 immutable 입력·mode·identity를 둔다.
- 고정 섹션 제목, 고정 설명, spacing, radius 같은 표현 값은 State에 넣지 않는다.
- View는 상태를 렌더링하고 사용자 입력을 Action으로 전달한다. API 호출과 비즈니스 effect를 View에서 실행하지 않는다.
- 다른 Feature로의 이동이 필요하면 자식 Feature는 목적지 구현 타입을 import하지 않고 자기 도메인의 의미 기반 delegate를 내보낸다. 목적지 Feature 구현체를 사용하는 최종 전환과 조립은 App 레이어가 담당하며, 같은 Feature 도메인 내부의 child 화면 조립과 구분한다. 목적지 타입을 컴파일 시점에 참조해야 하는 실제 계약이 있을 때만 `project-structure`에 따라 Interface를 사용한다.
- 순수 시각 섹션마다 Reducer를 만들지 않는다. 독립 상태·effect·navigation 수명이 있을 때만 하위 Feature 분리를 검토한다.
- 외부 진입점만 public으로 두고 화면 내부 타입은 필요한 최소 접근 수준을 사용한다.

### 3. DesignSystem으로 화면 조립

- 화면과 의미가 일치하는 완성 컴포넌트가 있으면 public API를 사용한다.
- 완성 컴포넌트가 없고 화면에만 속하는 카드·배너·섹션이면 공개 DesignSystem API로 Feature 내부에서 조립한다.
- 이름이 비슷하다는 이유로 배경·상태·동작 계약이 다른 컴포넌트를 억지로 사용하지 않는다.
- Feature에서 DesignSystem 내부 구현이나 private/internal API를 복제하거나 의존하지 않는다.
- 누락된 공용 계약을 Feature의 수치 복사로 우회하지 않는다. 공용화가 필요하면 후보와 근거를 보고하고 승인된 범위에서 DesignSystem 작업으로 전환한다.

### 4. SwiftUI 레이아웃 구성

- 부모가 제안하는 크기, 콘텐츠 intrinsic size, 명시적으로 합의된 컴포넌트 규격을 우선한다.
- 화면·시트·일반 섹션 너비를 Figma 캔버스나 특정 기기 너비로 고정하지 않는다.
- padding·spacing·radius·아이콘·의도된 카드 규격은 역할이 명확하면 고정 디자인 값으로 사용할 수 있다.
- 고정 높이는 텍스트 변화와 작은 화면에서 잘림을 만드는지 확인하고, 가능하면 콘텐츠 기반 크기나 `minHeight`를 우선 검토한다.
- 이미지의 표시 목적을 콘텐츠, 배경, 장식으로 구분하고 크기 기준과 content mode를 명시한다.
- `GeometryReader`는 부모 크기가 실제 계산 입력일 때만 좁은 범위에서 사용한다.
- modifier 순서가 시각 영역, clip, content shape, pressed overlay, hit area에 미치는 영향을 확인한다.

### 5. 상호작용 연결

- 단일 탭 액션은 기본적으로 `Button`을 사용하고 Store Action으로 연결한다.
- 카드 전체와 내부 액션 중 실제 탭 범위를 디자인과 동작 의미에 맞게 결정한다.
- 특정 최소 터치 크기를 일괄 강제하지 않는다. 필요하면 시각 영역과 터치 영역을 분리하되 인접 액션과 겹치지 않게 한다.
- 공용 pressed 효과는 화면 루트가 아니라 해당 surface 또는 icon에 선택적으로 적용한다.
- `onTapGesture`는 Button으로 표현할 수 없는 제스처가 실제 요구될 때만 사용한다.

### 6. 완료 검증

- reducer를 변경했다면 Action과 상태 전이를 TestStore로 검증한다.
- 화면 fixture는 production 기본 State에 넣지 않고 Example 또는 Test에 둔다.
- Feature 단독 UI는 대상 Feature 테스트와 FeatureExample에서, App 소유 tab·navigation·safe area 조립은 App host에서 검증한다.
- 프로젝트 코드 변경 후 `./scripts/sync-and-validate.sh`를 실행한다.
- 작은 화면, 디자인 기준 화면, 큰 화면에서 실제 렌더링을 확인한다.
- 최신 바이너리를 설치한 뒤 기존 프로세스를 종료하고 다시 실행하여, 새 실행 화면을 screenshot과 UI hierarchy로 확인한다.
- 빌드 성공이나 프로세스 존재만으로 사용자에게 보이는 화면이 최신이라고 판단하지 않는다.

## 금지 사항

- `UIScreen.main.bounds` 또는 Figma 캔버스 너비로 화면 전체 레이아웃 계산
- 텍스트 컨테이너를 측정된 Figma width·height로 이유 없이 고정
- `body` 평가마다 UUID 생성 또는 배열 index를 `ForEach` identity로 사용
- 화면 전용 View를 근거 없이 DesignSystem public 컴포넌트로 승격
- Feature가 다른 Feature Implementation을 import
- production State에 Example mock 콘텐츠 삽입
- DesignSystem과 동일한 색상·타이포그래피·pressed 값을 Feature에 복제
- 오래 실행 중인 앱을 최신 빌드로 간주하고 실제 재실행 검증 생략
