# 🧩 Select relationship 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1701-13906)

![Select relationship](../Images/Select_relationship.png)

## Runtime Contract

- 구현 타입은 `DSSelectRelationship`이며 Model의 `Relationship.partner`, `Relationship.friend`, `Relationship.colleague` 중 하나 또는 `nil`을 외부 `Binding`으로 입력받습니다.
- 선택값의 의미와 순서는 Model이 소유하고, `연인`·`친구`·`동료` 표시 문구는 DesignSystem이 소유합니다.
- 초기 미선택 상태를 허용하고 새 항목을 누르면 기존 선택을 교체합니다.
- 선택된 항목을 다시 눌러도 선택을 해제하지 않습니다. 전체 초기화는 호출자가 binding을 `nil`로 변경해 수행합니다.
- 세 선택지는 하위 `DSSelectBox`를 동일 비율로 배치하며 컴포넌트 너비는 부모가 결정합니다.

## 🏗️ Structure & Layout

- 🖼️ **Select relationship** (COMPONENT) `W: 353.0, H: 90.0`
  - 📝 **관계** (TEXT) `W: 32.0, H: 26.0` [X: 0.0, Y: 0.0 | Font: dsBody1Bold | Color: black (#000000) (op: 1.00)]
  - 🟦 **Frame 1430105946** (FRAME) `W: 353.0, H: 48.0` [X: 0.0, Y: 42.0]
    - 🖼️ **SelectBox** (INSTANCE) `W: 109.7, H: 48.0` [X: 0.0, Y: 0.0 | Fill: white (#ffffff) (op: 1.00) | Stroke: coolGray300 (#d6dce5) (op: 1.00) | Radius: 12]
      - 📝 **연인** (TEXT) `W: 77.7, H: 21.0` [X: 16.0, Y: 13.5 | Font: dsBody1Medium | Color: coolGray800 (#373c46) (op: 1.00)]
    - 🖼️ **SelectBox** (INSTANCE) `W: 109.7, H: 48.0` [X: 121.7, Y: 0.0 | Fill: white (#ffffff) (op: 1.00) | Stroke: coolGray300 (#d6dce5) (op: 1.00) | Radius: 12]
      - 📝 **친구** (TEXT) `W: 77.7, H: 21.0` [X: 16.0, Y: 13.5 | Font: dsBody1Medium | Color: coolGray800 (#373c46) (op: 1.00)]
    - 🖼️ **SelectBox** (INSTANCE) `W: 109.7, H: 48.0` [X: 243.3, Y: 0.0 | Fill: white (#ffffff) (op: 1.00) | Stroke: coolGray300 (#d6dce5) (op: 1.00) | Radius: 12]
      - 📝 **동료** (TEXT) `W: 77.7, H: 21.0` [X: 16.0, Y: 13.5 | Font: dsBody1Medium | Color: coolGray800 (#373c46) (op: 1.00)]
