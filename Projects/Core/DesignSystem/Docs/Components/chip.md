# 🧩 chip 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1024-17820)

![chip](../Images/chip.png)

## Runtime Interaction Contract

- 선택 여부와 무관하게 누르는 동안 기존 Chip 배경 위에 `gray975` 색상을 `16%` opacity로 덮는다.
- 오버레이는 Chip의 기존 capsule 영역에만 적용하며 크기나 터치 영역을 변경하지 않는다.

## 🏗️ Structure & Layout

- 🟦 **chip** (COMPONENT_SET) `W: 108.0, H: 150.0` [Radius: 5]
  - 🖼️ **Variant: off** (COMPONENT) `W: 68.0, H: 48.0` [X: 20.0, Y: 20.0 | Fill: gray25 (#fafafa) (op: 1.00) | Radius: 100]
    - 📝 **학생** (TEXT) `W: 28.0, H: 24.0` [X: 20.0, Y: 12.0 | Font: dsBody2Medium | Color: coolGray700 (#505866) (op: 1.00)]
  - 🖼️ **Variant: on** (COMPONENT) `W: 68.0, H: 48.0` [X: 20.0, Y: 85.0 | Fill: primary500 (#9c8af6) (op: 1.00) | Radius: 100]
    - 📝 **학생** (TEXT) `W: 28.0, H: 24.0` [X: 20.0, Y: 12.0 | Font: dsBody2SemiBold | Color: white (#ffffff) (op: 1.00)]
