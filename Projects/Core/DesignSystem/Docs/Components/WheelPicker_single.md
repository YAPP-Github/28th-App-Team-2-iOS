# 🧩 WheelPicker_single 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=383-1630)

![WheelPicker_single](../Images/WheelPicker_single.png)

## 구현 범위

- `DSSingleWheelPicker`는 292pt 너비의 wheel 선택 영역을 구현합니다.
- Figma 루트는 `DSWheelPickerPanel(layout: .single)`과 조합해 Drag Indicator, 제목, 저장 버튼과 흰색 패널까지 완성합니다.
- `dsWheelPickerSheet`의 custom overlay로 Liquid Glass 없이 dimming, swipe dismiss와 키보드 안전 영역 대응을 제공합니다.
- 표시 항목과 선택값은 외부에서 입력하며, 컴포넌트는 도메인 값 변환을 수행하지 않습니다.
- 유한 목록의 첫 항목과 마지막 항목도 중앙 선택 영역까지 스크롤할 수 있습니다.
- 스크롤을 놓으면 가장 가까운 항목의 중심이 중앙 선택 영역의 중심에 맞춰집니다.
- 중앙 선택 항목이 바뀔 때 행의 타이포그래피와 색상은 `0.14초 easeOut`으로 보간합니다.

## Motion Specification

- 중앙 행 강조 전환: `easeOut`, `0.14초`
- 중앙 행 탭, 외부 selection 변경, 접근성 증감처럼 선택 위치를 프로그램적으로 변경할 때: SwiftUI `snappy`
- 사용자가 휠을 직접 스크롤하는 동안에는 별도 위치 애니메이션을 추가하지 않아 손가락 이동을 그대로 따릅니다.

## Runtime Specification

- Container: `292 × 175pt`
- Row stride: `34pt`
- Selected background: `292 × 47pt`, `primary50`, radius `8pt`
- Selected: `body1Medium`, `black`
- Adjacent: `body2Regular`, `gray700`
- Outer: `body3Regular`, `gray400`

## 🏗️ Structure & Layout

- 🖼️ **WheelPicker_single** (COMPONENT) `W: 352.0, H: 319.0` [Fill: white (#ffffff) (op: 1.00) | Radius: 12]
  - 🟦 **Frame 1430106076** (FRAME) `W: 292.0, H: 235.0` [X: 30.0, Y: 44.0]
    - 🟦 **Frame 1430106133** (FRAME) `W: 292.0, H: 32.0` [X: 0.0, Y: 0.0]
      - 📝 **태어난 시각 선택** (TEXT) `W: 220.0, H: 32.0` [X: 0.0, Y: 0.0 | Font: dsHeading3Bold | Color: black (#000000) (op: 1.00)]
      - 🟦 **Frame 1430106132** (FRAME) `W: 44.0, H: 31.0` [X: 248.0, Y: 0.0 | Radius: 100]
        - 📝 **저장** (TEXT) `W: 32.0, H: 26.0` [X: 6.0, Y: 2.5 | Font: dsBody1Medium | Color: primary700 (#5757d7) (op: 1.00)]
    - 🟦 **Frame 1430106075** (FRAME) `W: 292.0, H: 175.0` [X: 0.0, Y: 60.0]
      - 📝 **술시 (戌時): 19:30 ~ 21:29** (TEXT) `W: 159.0, H: 20.0` [X: 66.5, Y: 0.0 | Font: dsBody3Regular | Color: gray400 (#b8b8b8) (op: 1.00)]
      - 📝 **해시 (亥時): 21:30 ~ 23:29** (TEXT) `W: 184.0, H: 24.0` [X: 54.0, Y: 30.0 | Font: dsBody2Regular | Color: gray700 (#737373) (op: 1.00)]
      - 🟦 **Frame 1430106074** (FRAME) `W: 292.0, H: 47.0` [X: 0.0, Y: 64.0 | Fill: primary50 (#f5f3fe) (op: 1.00) | Radius: 8]
        - 📝 **자시 (子時): 23:30 ~ 01:29** (TEXT) `W: 220.0, H: 23.0` [X: 36.0, Y: 12.0 | Font: dsBody1Medium (Figma LH: 23.4px) | Color: black (#000000) (op: 1.00)]
      - 📝 **축시 (丑時): 01:30 ~ 03:29** (TEXT) `W: 184.0, H: 24.0` [X: 54.0, Y: 121.0 | Font: dsBody2Regular | Color: gray700 (#737373) (op: 1.00)]
      - 📝 **인시 (寅時): 03:30 ~ 05:29** (TEXT) `W: 163.0, H: 20.0` [X: 64.5, Y: 155.0 | Font: dsBody3Regular | Color: gray400 (#b8b8b8) (op: 1.00)]
