# 🧩 Tab 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1245-6385)

![Tab](../Images/Tab.png)

## Runtime Layout Contract

- Tab의 가로 폭은 텍스트 폭과 좌우 `16pt` 패딩으로 결정한다. Figma의 `W: 60.0`은 `전체` 레이블을 사용한 기준값이며 최소·고정 너비가 아니다.
- Body2의 `24pt` line height와 상하 `6pt` 패딩으로 높이 `36pt`를 구성한다. 별도의 고정 높이는 두지 않는다.
- 레이블은 한 줄로 표시한다.

## 🏗️ Structure & Layout

- 🟦 **Tab** (COMPONENT_SET) `W: 100.0, H: 132.0` [Radius: 5]
  - 🖼️ **Variant: on** (COMPONENT) `W: 60.0, H: 36.0` [X: 20.0, Y: 20.0 | Fill: gray975 (#171717) (op: 1.00) | Radius: 99]
    - 📝 **전체** (TEXT) `W: 28.0, H: 24.0` [X: 16.0, Y: 6.0 | Font: dsBody2Medium | Color: white (#ffffff) (op: 1.00)]
  - 🖼️ **Variant: off** (COMPONENT) `W: 60.0, H: 36.0` [X: 20.0, Y: 76.0 | Fill: coolGray100 (#eff2f8) (op: 1.00) | Radius: 99]
    - 📝 **전체** (TEXT) `W: 28.0, H: 24.0` [X: 16.0, Y: 6.0 | Font: dsBody2Regular | Color: coolGray500 (#8f9aad) (op: 1.00)]
