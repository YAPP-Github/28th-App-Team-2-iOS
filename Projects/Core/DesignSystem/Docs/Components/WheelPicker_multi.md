# 🧩 WheelPicker_multi 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1417-23096)

![WheelPicker_multi](../Images/WheelPicker_multi.png)

## 구현 범위

- `DSMultiWheelPicker(layout: .time)`은 292pt 너비의 2열 wheel 선택 영역을 구현합니다.
- Figma 루트는 `DSWheelPickerPanel(layout: .time)`과 조합해 Drag Indicator, 제목, 저장 버튼과 흰색 패널까지 완성합니다.
- `dsWheelPickerSheet`의 custom overlay로 Liquid Glass 없이 dimming, swipe dismiss와 키보드 안전 영역 대응을 제공합니다.
- 시간 계산과 유효성 정책은 호출부가 담당하고, 각 열의 표시 항목과 선택값을 컴포넌트에 전달합니다.
- 시간형 레이아웃은 직접 키보드 입력을 제공하지 않습니다.
- 스크롤을 놓으면 각 열에서 가장 가까운 항목의 중심이 중앙 선택 영역의 중심에 맞춰집니다.
- 중앙 선택 항목이 바뀔 때 행의 타이포그래피와 색상은 `0.14초 easeOut`으로 보간합니다.

## Motion Specification

- 중앙 행 강조 전환: `easeOut`, `0.14초`
- 중앙 행 탭, 외부 selection 변경, 접근성 증감처럼 선택 위치를 프로그램적으로 변경할 때: SwiftUI `snappy`
- 사용자가 휠을 직접 스크롤하는 동안에는 별도 위치 애니메이션을 추가하지 않아 손가락 이동을 그대로 따릅니다.

## Runtime Specification

- Container: `292 × 165pt`
- Row stride: `34pt`
- Selected background: `292 × 50pt`, `primary50`, radius `8pt`
- Columns: `40pt + 64pt gap + 40pt`
- Selected: `body1Medium`, `black`
- Adjacent: `body2Regular`, `gray700`
- Outer: `body3Regular`, `gray400`

## 🏗️ Structure & Layout

- 🖼️ **WheelPicker_multi** (COMPONENT) `W: 352.0, H: 309.0` [Fill: white (#ffffff) (op: 1.00) | Radius: 12]
  - 🟦 **Frame 1430106076** (FRAME) `W: 292.0, H: 225.0` [X: 30.0, Y: 44.0]
    - 🟦 **Frame 1430106131** (FRAME) `W: 292.0, H: 32.0` [X: 0.0, Y: 0.0]
      - 📝 **받을 시간 입력** (TEXT) `W: 220.0, H: 32.0` [X: 0.0, Y: 0.0 | Font: dsHeading3Bold | Color: black (#000000) (op: 1.00)]
      - 🟦 **Frame 1430106132** (FRAME) `W: 44.0, H: 31.0` [X: 248.0, Y: 0.5 | Radius: 100]
        - 📝 **저장** (TEXT) `W: 32.0, H: 26.0` [X: 6.0, Y: 2.5 | Font: dsBody1Medium | Color: primary700 (#5757d7) (op: 1.00)]
    - 🟦 **Frame 1430106075** (FRAME) `W: 292.0, H: 165.0` [X: 0.0, Y: 60.0]
      - 🟦 **Frame 1430106071** (FRAME) `W: 40.0, H: 20.0` [X: 74.0, Y: 0.0]
        - 📝 **06** (TEXT) `W: 40.0, H: 20.0` [X: 0.0, Y: 0.0 | Font: dsBody3Regular | Color: gray400 (#b8b8b8) (op: 1.00)]
      - 🟦 **Frame 1430106070** (FRAME) `W: 40.0, H: 24.0` [X: 74.0, Y: 28.0]
        - 📝 **07** (TEXT) `W: 40.0, H: 24.0` [X: 0.0, Y: 0.0 | Font: dsBody2Regular | Color: gray700 (#737373) (op: 1.00)]
      - 🟦 **Frame 1430106074** (FRAME) `W: 292.0, H: 50.0` [X: 0.0, Y: 59.0 | Fill: primary50 (#f5f3fe) (op: 1.00) | Radius: 8]
        - 🟦 **Frame 1430106069** (FRAME) `W: 144.0, H: 26.0` [X: 74.0, Y: 12.0]
          - 📝 **08** (TEXT) `W: 40.0, H: 26.0` [X: 0.0, Y: 0.0 | Font: dsBody1Medium | Color: black (#000000) (op: 1.00)]
          - 📝 **00** (TEXT) `W: 40.0, H: 26.0` [X: 104.0, Y: 0.0 | Font: dsBody1Medium | Color: black (#000000) (op: 1.00)]
      - 🟦 **Frame 1430106072** (FRAME) `W: 144.0, H: 24.0` [X: 74.0, Y: 116.0]
        - 📝 **09** (TEXT) `W: 40.0, H: 24.0` [X: 0.0, Y: 0.0 | Font: dsBody2Regular | Color: gray700 (#737373) (op: 1.00)]
        - 📝 **30** (TEXT) `W: 40.0, H: 24.0` [X: 104.0, Y: 0.0 | Font: dsBody2Regular | Color: gray700 (#737373) (op: 1.00)]
      - 🟦 **Frame 1430106073** (FRAME) `W: 40.0, H: 20.0` [X: 74.0, Y: 147.0]
        - 📝 **10** (TEXT) `W: 40.0, H: 20.0` [X: 0.0, Y: 0.0 | Font: dsBody3Regular | Color: gray400 (#b8b8b8) (op: 1.00)]
