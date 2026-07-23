# 🧩 Tooltip 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1284-8181)

![Tooltip](../Images/Tooltip.png)

## 🏗️ Structure & Layout

- 🖼️ **Tooltip** (COMPONENT) `W: 186.0, H: 36.0`
  - 🟦 **Frame 1430106301** (FRAME) `W: 186.0, H: 30.0` [X: 0.0, Y: 0.0 | Fill: black (#000000) (op: 0.80) | Radius: 99]
    - 📝 **오늘 이 사람과 어디를 갈까?** (TEXT) `W: 154.0, H: 20.0` [X: 16.0, Y: 5.0 | Font: dsBody3Medium | Color: white (#ffffff) (op: 1.00)]
  - 🟦 **Polygon 4** (REGULAR_POLYGON) `W: 8.0, H: 8.0` [X: 89.0, Y: 28.0 | Fill: black (#000000) (op: 0.80)]

## 구현 계약

- Tooltip은 메시지를 표시하는 정적 컴포넌트이며 표시 여부와 화면상 위치는 부모가 결정합니다.
- 캡슐의 높이는 30pt이고 전체 높이는 아래쪽 화살표를 포함해 36pt입니다.
- 화살표를 제외한 캡슐의 좌우 콘텐츠 인셋은 16pt이며, 상하 padding보다 30pt 고정 높이를 우선합니다.
- 텍스트는 `Body3/Medium (14/20)`을 사용하며 30pt 캡슐 안에서 수직 중앙 정렬합니다.
- 화살표는 Figma가 제공한 원본 벡터 에셋을 사용합니다.
