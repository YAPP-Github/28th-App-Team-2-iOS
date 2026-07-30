# 🧩 Todak Header 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1244-15359)

![Todak Header](../Images/Todak%20Header.png)

## 🏗️ Structure & Layout

- 🖼️ **Todak Header** (COMPONENT) `W: 393.0, H: 100.0` [Fill: white (#ffffff) (op: 1.00)]
  - 🟦 **Header** (FRAME) `W: 393.0, H: 48.0` [X: 0.0, Y: 52.0 | Fill: white (#ffffff) (op: 1.00)]
    - 🖼️ **delete_line** (INSTANCE) `W: 20.0, H: 20.0` [X: 20.0, Y: 14.0]
      - 🟦 **content** (VECTOR) `W: 20.0, H: 20.0` [Color: gray925 (#303030)]
    - 🟦 **Frame 1430106412** (FRAME) `W: 152.0, H: 24.0` [X: 121.0, Y: 13.5]
      - 📝 **토닥이** (TEXT) `W: 42.0, H: 24.0` [X: 0.0, Y: 0.0 | Font: dsBody2SemiBold | Color: black (#000000) (op: 1.00)]
      - 📝 **오늘 무료 채팅 2/3** (TEXT) `W: 106.0, H: 20.0` [X: 46.0, Y: 2.0 | Prefix Font: dsBody3Regular | Count/Limit Font: dsBody3Medium | Prefix Color: gray500 (#9a9a9a) (op: 1.00) | Remaining Count Color: gray800]
    - 🟦 **Frame 1430106404** (FRAME) `W: 52.0, H: 20.0` [X: 321.0, Y: 14.0]
      - 🖼️ **Chat / add chat** (INSTANCE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0 | Color: coolGray975]
      - 🖼️ **notes** (INSTANCE) `W: 20.0, H: 20.0` [X: 32.0, Y: 0.0 | Color: coolGray975]

## 📐 Layout Contract

- Figma의 `393 x 100`은 기준 기기 폭과 상단 safe area/status bar 영역을 포함한 참조 프레임입니다.
- 구현 시 전체 가로 폭은 고정하지 않고 부모/기기 폭을 채웁니다.
- DesignSystem 컴포넌트 자체는 상단 safe area를 포함하지 않고 실제 헤더 컨텐츠 `48pt`만 렌더링합니다.
- 노치/Dynamic Island 아래 배치와 상단 safe area 처리는 컴포넌트를 사용하는 부모 화면의 SwiftUI 레이아웃이 담당합니다.
- 좌측 닫기 버튼은 `20 x 20`이며, 헤더 좌측에서 `20pt`, 상단에서 `14pt` 떨어져 배치합니다.
- 우측 액션은 `rightItems` 배열로 주입합니다.
- 우측 액션 버튼은 각각 `20 x 20`이며, 버튼 사이 간격은 `12pt`입니다.
- Figma 기준 기본 우측 액션 구성은 `chatAdd`, `notes` 순서의 `2개`입니다.
- 중앙 타이틀 그룹은 헤더 컨텐츠 영역의 수평 중앙에 정렬합니다.

## 🧾 Content Contract

- 타이틀 문구는 Figma 기준 `토닥이`로 고정합니다.
- 보조 문구는 `오늘 무료 채팅 n/3` 형식입니다.
- `오늘 무료 채팅 ` 문구는 `body3Regular`, `n/3` 영역은 `body3Medium`입니다.
- 보조 문구 전체 기본 색상은 `gray500`이며, `n`에 해당하는 `remainingFreeChatCount` 숫자만 `gray800`으로 표시합니다.
- `n`은 서버 또는 상위 Feature 상태에서 주입되는 오늘의 무료 채팅 잔여 횟수입니다.
- 기본 일일 무료 채팅 총량은 `3`으로 고정합니다.
- `n`의 유효 범위 `0...3` 보장은 서버 또는 상위 Feature 상태의 책임입니다. DesignSystem 컴포넌트는 전달받은 값을 조용히 보정하지 않습니다.
- `n`은 채팅 사용 후 감소할 수 있습니다.

## 🎛️ Interaction Contract

- DesignSystem 컴포넌트는 비즈니스 동작을 직접 소유하지 않습니다.
- 좌측 닫기 버튼과 우측 액션 버튼의 action closure는 외부에서 주입받습니다.
- 우측 액션 버튼의 아이콘 색상은 `coolGray975`입니다.
- 우측 액션은 `DSTodakHeader.RightItem(identifier:icon:action:)`로 전달하되, 버튼 크기·색상·pressed 상태·간격은 DesignSystem 컴포넌트가 소유합니다.
- 스크롤, expanded/collapsed, shadow, 투명도 변화 상태는 없습니다.
- pressed 상태가 필요한 경우 프로젝트 공통 pressed 정책을 따릅니다.

## 🧪 DesignSystemExample

- 무료 채팅 잔여 횟수 `3`, `2`, `1`, `0`을 입력 또는 선택해 볼 수 있어야 합니다.
- 세 버튼을 각각 눌렀을 때 어떤 버튼이 눌렸는지 아래 설명 영역에 표시합니다.
- Example은 DesignSystem 컴포넌트의 시각 상태와 action closure 연결만 확인하며, 실제 채팅 생성/기록 이동/화면 닫기 로직은 포함하지 않습니다.

## 🔗 Asset Mapping

- 좌측 닫기 아이콘: `DSIconAsset.deleteLine`
- 기본 우측 새 채팅 아이콘: `DSIconAsset.chatAdd`
- 기본 우측 기록/노트 아이콘: `DSIconAsset.notes`
