# 🧩 Popover 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1417-22826)

![Popover](../Images/Popover.png)

## 🏗️ Structure & Layout

- 🖼️ **Popover** (COMPONENT) `W: 116.0, H: 108.0`
  - 배경: `white (#FFFFFF)`
  - 모서리: `12pt`
  - 내부 여백: `8pt`
  - 항목 간격: `4pt`
  - 고유 그림자: `X: 0, Y: 0, Blur: 10, Spread: 1, #000000 8%`
- 🖼️ **Cell** (INSTANCE) `Minimum W: 100.0, H: 44.0`
  - 모서리: `8pt`
  - 수평 여백: `12pt`
  - 제목: `dsBody3Medium`, `gray925 (#131313)`, line height `20pt`
  - pressed 정책: DesignSystem 공통 `DSPressedOverlay.standard`

## 🔎 Figma 교차 검증

- Popover 항목은 텍스트와 선택 동작만 입력받으며 아이콘 슬롯을 제공하지 않는다.
- 항목 콘텐츠와 선택 동작은 호출 화면이 주입하며, anchor 및 화면상 위치 계산은 Popover 범위에 포함하지 않는다.
- 각 항목의 SwiftUI identity가 상태 변경에도 유지되도록 호출 화면이 안정적인 문자열 identifier를 주입한다.
- 별도 공용 Shadow modifier는 만들지 않는다. 위 그림자는 Popover 자체 렌더링 Specification에만 속한다.
