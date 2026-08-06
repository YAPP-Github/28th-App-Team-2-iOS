# 🧩 Checkbox 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=385-4002)

![Checkbox](../Images/Checkbox.png)

## Runtime Interaction Contract

- On/Off 여부와 무관하게 누르는 동안 기존 Checkbox 배경 위에 `gray975` 색상을 `16%` opacity로 덮는다.
- 기본 `DSCheckbox(isOn:)`은 Figma와 동일한 `20×20pt` 컨트롤입니다.
- 라벨 조합이 필요하면 `labelSpacing`, `contentInsets`, `@ViewBuilder label`을 전달합니다. indicator와 라벨은 중첩 컨트롤 없이 하나의 Toggle interaction을 공유하며, 터치 영역은 조합된 content 전체로 확장됩니다.
- 조합형에서도 pressed overlay는 기존 `20×20pt` indicator에만 적용하며 크기나 터치 영역을 변경하지 않습니다. 라벨 간격·내부 여백·배경은 사용하는 상위 컴포넌트가 소유합니다.

## 🏗️ Structure & Layout

- 🟦 **Checkbox** (COMPONENT_SET) `W: 60.0, H: 100.0` [Radius: 5]
  - 🖼️ **Variant: On** (COMPONENT) `W: 20.0, H: 20.0` [X: 20.0, Y: 20.0 | Fill: primary600 (#7f73ea) (op: 1.00) | Radius: 6]
    - 🖼️ **check_line** (INSTANCE) `W: 16.0, H: 16.0` [X: 2.0, Y: 2.0]
      - 🟦 **check_line** (GROUP) `W: 16.0, H: 16.0` [X: 0.0, Y: 0.0]
        - 🟦 **content_area** (RECTANGLE) `W: 16.0, H: 16.0` [X: 0.0, Y: 0.0]
        - 🟦 **content** (GROUP) `W: 13.3, H: 13.3` [X: 1.3, Y: 1.3]
          - 🟦 **Rectangle 5396** (RECTANGLE) `W: 13.3, H: 13.3` [X: 0.0, Y: 0.0]
  - 🖼️ **Variant: Off** (COMPONENT) `W: 20.0, H: 20.0` [X: 20.0, Y: 60.0 | Fill: white (#ffffff) (op: 1.00) | Stroke: gray300 (#dcdcdc) (op: 1.00) | Radius: 6]
