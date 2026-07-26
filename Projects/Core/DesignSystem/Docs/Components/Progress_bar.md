# 🧩 Progress bar 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=381-1861)

![Progress bar](../Images/Progress_bar.png)

## Runtime Layout Interpretation

- Figma의 `W: 393.0`은 기준 캔버스 폭이다. 런타임 컴포넌트는 부모가 폭을 결정하며, 높이 `48pt`, leading inset `20pt`, trailing inset `21pt`, 아이콘 크기 `12×18pt`, 아이콘-트랙 간격 `24pt`만 고정한다.
- 트랙은 남은 가로 폭을 채운다. 기준 캔버스에서는 `316pt`로 렌더링된다.
- 트랙 배경은 `gray50 → gray200` 선형 그라데이션에 전체 opacity `50%`를 적용한다.
- 진행 fill은 전체 트랙 폭을 기준으로 한 `sky400 → primary600 → primary400` 선형 그라데이션이며, 현재 진행 폭만큼만 왼쪽부터 mask한다.

## 🏗️ Structure & Layout

- 🟦 **Progress bar** (COMPONENT_SET) `W: 433.0, H: 408.0` [Radius: 5]
  - 🖼️ **Variant: Default** (COMPONENT) `W: 393.0, H: 48.0` [X: 20.0, Y: 20.0]
    - 🟦 **Frame 1430105943** (FRAME) `W: 12.0, H: 16.0` [X: 20.0, Y: 16.0]
      - 🖼️ **Arrow** (INSTANCE) `W: 8.0, H: 16.0` [X: 2.0, Y: 0.0]
    - 🟦 **Group 1171275260** (GROUP) `W: 316.0, H: 6.0` [X: 56.0, Y: 21.0]
      - 🟦 **Rectangle 1744** (RECTANGLE) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0 | Radius: 10]
      - 🟦 **Mask group** (GROUP) `W: 79.0, H: 6.0` [X: 0.0, Y: 0.0]
        - 🟦 **Rectangle 1745** (RECTANGLE) `W: 79.0, H: 6.0` [X: 0.0, Y: 0.0 | Fill: black (#000000) (op: 1.00) | Radius: 10]
        - 🟦 **Rectangle 34625979** (RECTANGLE) `W: 237.8, H: 6.0` [X: 0.0, Y: 0.0]
  - 🖼️ **Variant: Variant2** (COMPONENT) `W: 393.0, H: 48.0` [X: 20.0, Y: 84.0]
    - 🟦 **Frame 1430105943** (FRAME) `W: 12.0, H: 16.0` [X: 20.0, Y: 16.0]
      - 🖼️ **Arrow** (INSTANCE) `W: 8.0, H: 16.0` [X: 2.0, Y: 0.0]
    - 🟦 **Group 1171275260** (GROUP) `W: 316.0, H: 6.0` [X: 56.0, Y: 21.0]
      - 🟦 **Rectangle 1744** (RECTANGLE) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0 | Radius: 10]
      - 🟦 **Mask group** (GROUP) `W: 158.0, H: 6.0` [X: 0.0, Y: 0.0]
        - 🟦 **Rectangle 1745** (RECTANGLE) `W: 158.0, H: 6.0` [X: 0.0, Y: 0.0 | Fill: black (#000000) (op: 1.00) | Radius: 10]
        - 🟦 **Rectangle 34625979** (RECTANGLE) `W: 237.8, H: 6.0` [X: 0.0, Y: 0.0]
  - 🖼️ **Variant: Variant3** (COMPONENT) `W: 393.0, H: 48.0` [X: 20.0, Y: 148.0]
    - 🟦 **Frame 1430105943** (FRAME) `W: 12.0, H: 16.0` [X: 20.0, Y: 16.0]
      - 🖼️ **Arrow** (INSTANCE) `W: 8.0, H: 16.0` [X: 2.0, Y: 0.0]
    - 🟦 **Group 1171275260** (GROUP) `W: 316.0, H: 6.0` [X: 56.0, Y: 21.0]
      - 🟦 **Rectangle 1744** (RECTANGLE) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0 | Radius: 10]
      - 🟦 **Mask group** (GROUP) `W: 237.0, H: 6.0` [X: 0.0, Y: 0.0]
        - 🟦 **Rectangle 1745** (RECTANGLE) `W: 237.0, H: 6.0` [X: 0.0, Y: 0.0 | Fill: black (#000000) (op: 1.00) | Radius: 10]
        - 🟦 **Rectangle 34625979** (RECTANGLE) `W: 356.6, H: 6.0` [X: 0.0, Y: 0.0]
  - 🖼️ **Variant: Variant4** (COMPONENT) `W: 393.0, H: 48.0` [X: 20.0, Y: 212.0]
    - 🟦 **Frame 1430105943** (FRAME) `W: 12.0, H: 16.0` [X: 20.0, Y: 16.0]
      - 🖼️ **Arrow** (INSTANCE) `W: 8.0, H: 16.0` [X: 2.0, Y: 0.0]
    - 🟦 **Group 1171275260** (GROUP) `W: 316.0, H: 6.0` [X: 56.0, Y: 21.0]
      - 🟦 **Rectangle 1744** (RECTANGLE) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0 | Radius: 10]
      - 🟦 **Mask group** (GROUP) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0]
        - 🟦 **Rectangle 1745** (RECTANGLE) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0 | Fill: black (#000000) (op: 1.00) | Radius: 10]
        - 🟦 **Rectangle 34625979** (RECTANGLE) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0]
  - 🖼️ **Variant: Variant5** (COMPONENT) `W: 393.0, H: 48.0` [X: 20.0, Y: 276.0]
    - 🟦 **Frame 1430105943** (FRAME) `W: 12.0, H: 16.0` [X: 20.0, Y: 16.0]
      - 🖼️ **Arrow** (INSTANCE) `W: 8.0, H: 16.0` [X: 2.0, Y: 0.0]
    - 🟦 **Group 1171275260** (GROUP) `W: 316.0, H: 6.0` [X: 56.0, Y: 21.0]
      - 🟦 **Rectangle 1744** (RECTANGLE) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0 | Radius: 10]
      - 🟦 **Mask group** (GROUP) `W: 105.0, H: 6.0` [X: 0.0, Y: 0.0]
        - 🟦 **Rectangle 1745** (RECTANGLE) `W: 105.0, H: 6.0` [X: 0.0, Y: 0.0 | Fill: black (#000000) (op: 1.00) | Radius: 10]
        - 🟦 **Rectangle 34625979** (RECTANGLE) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0]
  - 🖼️ **Variant: Variant6** (COMPONENT) `W: 393.0, H: 48.0` [X: 20.0, Y: 340.0]
    - 🟦 **Frame 1430105943** (FRAME) `W: 12.0, H: 16.0` [X: 20.0, Y: 16.0]
      - 🖼️ **Arrow** (INSTANCE) `W: 8.0, H: 16.0` [X: 2.0, Y: 0.0]
    - 🟦 **Group 1171275260** (GROUP) `W: 316.0, H: 6.0` [X: 56.0, Y: 21.0]
      - 🟦 **Rectangle 1744** (RECTANGLE) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0 | Radius: 10]
      - 🟦 **Mask group** (GROUP) `W: 210.0, H: 6.0` [X: 0.0, Y: 0.0]
        - 🟦 **Rectangle 1745** (RECTANGLE) `W: 210.0, H: 6.0` [X: 0.0, Y: 0.0 | Fill: black (#000000) (op: 1.00) | Radius: 10]
        - 🟦 **Rectangle 34625979** (RECTANGLE) `W: 632.0, H: 6.0` [X: 0.0, Y: 0.0]
