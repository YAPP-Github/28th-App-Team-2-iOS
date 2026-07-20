# 🧩 Chat Type box 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1460-20866)

![Chat Type box](../Images/Chat_Type_box.png)

## 📝 Designer Notes (최신 변경사항)
- **박스 최대 높이:** 104px 고정
- **박스 라운드(Corner Radius):** 24px
- **여백(Margin):** 좌측 22px, 우측 20px
- **긴 텍스트 처리:** 3줄 초과 시 텍스트 박스 내에서 위로 스크롤되며 가려짐. 가려지는 부분에 `#FFFFFF` 60% 레이어 씌움.

## 🏗️ Structure & Layout

- 🟦 **Chat Type box** (COMPONENT_SET) `W: 1194.0, H: 188.0` [Radius: 5]
  - 🖼️ **Variant: Default** (COMPONENT) `W: 353.0, H: 64.0` [X: 20.0, Y: 20.0 | Fill: whiteOpacity60 (#ffffff) (op: 1.00) | Stroke: gray50 (#f5f5f5) (op: 1.00) | Radius: 24]
    - 🟦 **Frame 1430106199** (FRAME) `W: 267.0, H: 23.0` [X: 22.0, Y: 20.5]
      - 📝 **토닥이에게 운세 물어보기** (TEXT) `W: 161.0, H: 24.0` [X: 0.0, Y: -1.0 | Font: dsBody2Regular | Color: gray400 (#b8b8b8) (op: 1.00)]
    - 🟦 **Group 1171275304** (GROUP) `W: 32.0, H: 32.0` [X: 301.0, Y: 16.0]
      - 🟦 **Ellipse 57** (ELLIPSE) `W: 32.0, H: 32.0` [X: 0.0, Y: 0.0 | Fill: gray50 (#f5f5f5) (op: 1.00)]
      - 🖼️ **arrow_upward** (INSTANCE) `W: 24.0, H: 24.0` [X: 4.0, Y: 4.0]
  - 🖼️ **Variant: Filled** (COMPONENT) `W: 353.0, H: 64.0` [X: 20.0, Y: 104.0 | Fill: whiteOpacity60 (#ffffff) (op: 1.00) | Stroke: gray50 (#f5f5f5) (op: 1.00) | Radius: 24]
    - 🟦 **Group 1171275306** (GROUP) `W: 267.0, H: 24.0` [X: 22.0, Y: 20.0]
      - 📝 **오늘 나의 행운의 숫자는?** (TEXT) `W: 267.0, H: 24.0` [X: 0.0, Y: 0.0 | Font: dsBody2Regular | Color: black (#000000) (op: 1.00)]
    - 🟦 **Group 1171275303** (GROUP) `W: 32.0, H: 32.0` [X: 301.0, Y: 16.0]
      - 🟦 **Ellipse 57** (ELLIPSE) `W: 32.0, H: 32.0` [X: 0.0, Y: 0.0 | Fill: primary600 (#7f73ea) (op: 1.00)]
      - 🖼️ **arrow_upward** (INSTANCE) `W: 24.0, H: 24.0` [X: 4.0, Y: 4.0]
  - 🖼️ **Variant: Variant3** (COMPONENT) `W: 353.0, H: 104.0` [X: 398.0, Y: 19.0 | Fill: whiteOpacity60 (#ffffff) (op: 1.00) | Stroke: gray50 (#f5f5f5) (op: 1.00) | Radius: 24]
    - 🟦 **Group 1171275306** (GROUP) `W: 267.0, H: 72.0` [X: 22.0, Y: 16.0]
      - 📝 **3줄의 긴 질문을 작성한 경우...** (TEXT) `W: 267.0, H: 72.0` [X: 0.0, Y: 0.0 | Font: dsBody2Regular | Color: black (#000000) (op: 1.00)]
    - 🟦 **Group 1171275303** (GROUP) `W: 32.0, H: 32.0` [X: 301.0, Y: 56.0]
      - 🟦 **Ellipse 57** (ELLIPSE) `W: 32.0, H: 32.0` [X: 0.0, Y: 0.0 | Fill: primary600 (#7f73ea) (op: 1.00)]
      - 🖼️ **arrow_upward** (INSTANCE) `W: 24.0, H: 24.0` [X: 4.0, Y: 4.0]
  - 🖼️ **Variant: Variant4** (COMPONENT) `W: 353.0, H: 104.0` [X: 767.0, Y: 19.0 | Fill: whiteOpacity60 (#ffffff) (op: 1.00) | Stroke: gray50 (#f5f5f5) (op: 1.00) | Radius: 24]
    - 🟦 **Group 1171275306** (GROUP) `W: 267.0, H: 102.0` [X: 22.0, Y: -14.0]
      - 📝 **3줄이 넘는 긴 질문을 작성한 경우...** (TEXT) `W: 267.0, H: 102.0` [X: 0.0, Y: 0.0 | Font: dsBody2Regular | Color: black (#000000) (op: 1.00)]
    - 🟦 **Group 1171275303** (GROUP) `W: 32.0, H: 32.0` [X: 301.0, Y: 56.0]
      - 🟦 **Ellipse 57** (ELLIPSE) `W: 32.0, H: 32.0` [X: 0.0, Y: 0.0 | Fill: primary600 (#7f73ea) (op: 1.00)]
      - 🖼️ **arrow_upward** (INSTANCE) `W: 24.0, H: 24.0` [X: 4.0, Y: 4.0]
    - 🟦 **Rectangle 34626017** (RECTANGLE) `W: 353.0, H: 16.0` [X: 0.0, Y: 0.0 | Fill: whiteOpacity60 (#ffffff) (op: 0.60)]
