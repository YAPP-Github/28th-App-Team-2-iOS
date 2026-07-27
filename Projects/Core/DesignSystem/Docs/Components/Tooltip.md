# 🧩 Tooltip 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1284-8181)

![Tooltip](../Images/Tooltip.png)

## 🏗️ Structure & Layout

- 🖼️ **Tooltip** (COMPONENT) `W: 186.0, H: 36.0`
  - 🟦 **Frame 1430106301** (FRAME) `W: 186.0, H: 30.0` [X: 0.0, Y: 0.0 | Fill: black (#000000) (op: 0.60) | Radius: 99]
    - 📝 **오늘 이 사람과 어디를 갈까?** (TEXT) `W: 154.0, H: 20.0` [X: 16.0, Y: 5.0 | Font: dsBody3Medium | Color: white (#ffffff) (op: 1.00)]
  - 🟦 **Polygon 4** (REGULAR_POLYGON) `W: 8.0, H: 8.0` [X: 89.0, Y: 28.0 | Fill: black (#000000) (op: 0.60)]

## 구현 계약

- Tooltip은 메시지를 표시하는 정적 컴포넌트이며 표시 여부와 화면상 위치는 부모가 결정합니다.
- 한 줄 메시지에서 캡슐의 최소 높이는 30pt이고, 여러 줄이면 콘텐츠 높이에 맞춰 세로로 확장됩니다.
- 화살표를 제외한 캡슐의 콘텐츠 인셋은 좌우 16pt, 상하 5pt입니다.
- 텍스트는 `Body3/Medium (14/20)`을 사용하고 줄 수 제한과 말줄임 없이 줄바꿈하며, 가운데 정렬합니다.
- Tooltip의 최대 너비는 화면 너비에서 좌우 여백 20pt씩을 제외한 영역입니다. 호출 화면은 부모 레이아웃에 좌우 20pt 여백을 적용하고, Tooltip은 부모가 제안한 최대 너비 안에서 줄바꿈합니다.
- 화살표는 Figma가 제공한 원본 벡터 에셋을 사용합니다.
- 화살표 SVG는 형태만 담당하며, 캡슐과 화살표의 색상·투명도는 Figma의 `Primitive/Opacity/60` 토큰에 대응하는 `opacity60` 컬러 에셋으로 관리합니다.
