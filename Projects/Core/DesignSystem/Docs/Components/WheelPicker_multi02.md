# 🧩 WheelPicker_multi02 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=383-1347)

![WheelPicker_multi02](../Images/WheelPicker_multi02.png)

## 구현 범위

- `DSMultiWheelPicker(layout: .date)`는 292pt 너비의 년·월·일 wheel 선택 영역을 구현합니다.
- Figma 루트는 `DSWheelPickerPanel(layout: .date)`과 조합해 Drag Indicator, 제목, 저장 버튼과 흰색 패널까지 완성합니다.
- `dsWheelPickerSheet`의 custom overlay로 Liquid Glass 없이 dimming, swipe dismiss와 키보드 안전 영역 대응을 제공합니다.
- 생년월일 필수 여부, 미래 날짜 제한, `1900...현재 연도`, 월별 일수와 윤년 계산은 호출부가 담당합니다.
- 호출부는 위 정책으로 계산한 유효 항목만 각 열에 전달합니다.
- 선택된 년·월·일 셀을 누르면 숫자 키보드로 직접 입력할 수 있습니다.
- 직접 입력 `TextField`는 휠의 중앙 overlay에 배치하여 키보드 포커스가 각 열의 스크롤 위치를 바꾸지 않게 합니다.
- 연도는 숫자 4자리, 월·일은 각각 숫자 2자리까지만 입력할 수 있습니다.
- 최대 자릿수에 도달하면 별도 완료 버튼 없이 입력을 즉시 확정합니다. 연도 입력 후에는 월, 월 입력 후에는 일 열로 포커스가 자동 이동하며, 일 입력까지 끝나면 키보드를 닫습니다.
- 최대 자릿수 도달 전 시스템 또는 사용자 동작으로 포커스가 해제되거나 Picker가 사라져도 현재 입력을 동일한 규칙으로 확정합니다.
- 직접 입력 중 다른 열의 중앙 셀을 누르면 현재 입력을 확정하고 탭한 열로 입력 포커스를 옮깁니다. 다른 휠을 스크롤하면 현재 입력을 확정하고 키보드만 닫습니다. Picker나 이를 담은 Panel은 닫지 않습니다.
- Picker 바깥 화면 탭으로 키보드를 닫아야 하는 호출 화면은 자신의 hit-test 범위에 `dsWheelPickerDismissKeyboardOnTap()`을 적용합니다.
- 숫자가 아닌 입력은 제거하고 최대 자릿수를 넘는 숫자는 반영하지 않습니다.
- 입력 완료 시 전달받은 항목 중 숫자 차이가 가장 작은 값으로 보정하고 해당 위치로 스크롤합니다.
- 두 후보와의 차이가 같으면 더 작은 값을 선택합니다.
- 열의 항목이 갱신되어 기존 선택값이 사라져도 같은 최근접 규칙으로 선택과 스크롤을 동기화합니다.
- 열별로 유한/순환 동작을 선택할 수 있으며, 생년월일 조합의 월 열은 `12월 → 1월` 경계를 이어 표시합니다.
- 스크롤을 놓으면 각 열에서 가장 가까운 항목의 중심이 중앙 선택 영역의 중심에 맞춰집니다.
- 중앙 선택 항목이 바뀔 때 행의 타이포그래피와 색상은 `0.14초 easeOut`으로 보간하며, 사용자가 휠을 스크롤하는 동안 위치와 선택 상태에는 별도 애니메이션을 추가하지 않습니다.

## Motion Specification

- 중앙 행 강조 전환: `easeOut`, `0.14초`
- 직접 입력 확정 후 유효값 위치 이동: SwiftUI `snappy`
- 스크롤 중에는 별도 보간을 추가하지 않아 손가락 이동을 그대로 따릅니다.

## Runtime Specification

- Container: `292 × 178pt`
- Row stride: `34pt`
- Selected background: `292 × 50pt`, `primary50`, radius `8pt`
- Columns: `60pt + 40pt gap + 40pt + 40pt gap + 40pt`
- Selected: `body1Medium`, `black`
- Adjacent: `body2Regular`, `gray700`
- Outer: `body3Regular`, `gray400`

## 🏗️ Structure & Layout

- 🖼️ **WheelPicker_multi02** (COMPONENT) `W: 352.0, H: 322.0` [Fill: white (#ffffff) (op: 1.00) | Radius: 12]
  - 🟦 **Frame 1430106076** (FRAME) `W: 292.0, H: 238.0` [X: 30.0, Y: 44.0]
    - 🟦 **Frame 1430106131** (FRAME) `W: 292.0, H: 32.0` [X: 0.0, Y: 0.0]
      - 📝 **생년월일 입력** (TEXT) `W: 220.0, H: 32.0` [X: 0.0, Y: 0.0 | Font: dsHeading3Bold | Color: black (#000000) (op: 1.00)]
      - 🟦 **Frame 1430106132** (FRAME) `W: 44.0, H: 31.0` [X: 248.0, Y: 0.5 | Radius: 100]
        - 📝 **저장** (TEXT) `W: 32.0, H: 26.0` [X: 6.0, Y: 2.5 | Font: dsBody1Medium | Color: primary700 (#5757d7) (op: 1.00)]
    - 🟦 **Frame 1430106075** (FRAME) `W: 292.0, H: 178.0` [X: 0.0, Y: 60.0]
      - 🟦 **Frame 1430106071** (FRAME) `W: 220.0, H: 20.0` [X: 36.0, Y: 0.0]
        - 📝 **1997년** (TEXT) `W: 60.0, H: 20.0` [X: 0.0, Y: 0.0 | Font: dsBody3Regular | Color: gray400 (#b8b8b8) (op: 1.00)]
        - 📝 **12월** (TEXT) `W: 40.0, H: 20.0` [X: 100.0, Y: 0.0 | Font: dsBody3Regular | Color: gray400 (#b8b8b8) (op: 1.00)]
        - 📝 **11일** (TEXT) `W: 40.0, H: 20.0` [X: 180.0, Y: 0.0 | Font: dsBody3Regular | Color: gray400 (#b8b8b8) (op: 1.00)]
      - 🟦 **Frame 1430106070** (FRAME) `W: 220.0, H: 24.0` [X: 36.0, Y: 30.0]
        - 📝 **1998년** (TEXT) `W: 60.0, H: 24.0` [X: 0.0, Y: 0.0 | Font: dsBody2Regular | Color: gray700 (#737373) (op: 1.00)]
        - 📝 **1월** (TEXT) `W: 40.0, H: 24.0` [X: 100.0, Y: 0.0 | Font: dsBody2Regular | Color: gray700 (#737373) (op: 1.00)]
        - 📝 **12일** (TEXT) `W: 40.0, H: 24.0` [X: 180.0, Y: 0.0 | Font: dsBody2Regular | Color: gray700 (#737373) (op: 1.00)]
      - 🟦 **Frame 1430106074** (FRAME) `W: 292.0, H: 50.0` [X: 0.0, Y: 64.0 | Fill: primary50 (#f5f3fe) (op: 1.00) | Radius: 8]
        - 🟦 **Frame 1430106069** (FRAME) `W: 220.0, H: 26.0` [X: 36.0, Y: 12.0]
          - 📝 **1999년** (TEXT) `W: 60.0, H: 26.0` [X: 0.0, Y: 0.0 | Font: dsBody1Medium | Color: black (#000000) (op: 1.00)]
          - 📝 **2월** (TEXT) `W: 40.0, H: 26.0` [X: 100.0, Y: 0.0 | Font: dsBody1Medium | Color: black (#000000) (op: 1.00)]
          - 📝 **13일** (TEXT) `W: 40.0, H: 26.0` [X: 180.0, Y: 0.0 | Font: dsBody1Medium | Color: black (#000000) (op: 1.00)]
      - 🟦 **Frame 1430106072** (FRAME) `W: 220.0, H: 24.0` [X: 36.0, Y: 124.0]
        - 📝 **2000년** (TEXT) `W: 60.0, H: 24.0` [X: 0.0, Y: 0.0 | Font: dsBody2Regular | Color: gray700 (#737373) (op: 1.00)]
        - 📝 **3월** (TEXT) `W: 40.0, H: 24.0` [X: 100.0, Y: 0.0 | Font: dsBody2Regular | Color: gray700 (#737373) (op: 1.00)]
        - 📝 **14일** (TEXT) `W: 40.0, H: 24.0` [X: 180.0, Y: 0.0 | Font: dsBody2Regular | Color: gray700 (#737373) (op: 1.00)]
      - 🟦 **Frame 1430106073** (FRAME) `W: 220.0, H: 20.0` [X: 36.0, Y: 158.0]
        - 📝 **2001년** (TEXT) `W: 60.0, H: 20.0` [X: 0.0, Y: 0.0 | Font: dsBody3Regular | Color: gray400 (#b8b8b8) (op: 1.00)]
        - 📝 **4월** (TEXT) `W: 40.0, H: 20.0` [X: 100.0, Y: 0.0 | Font: dsBody3Regular | Color: gray400 (#b8b8b8) (op: 1.00)]
        - 📝 **15일** (TEXT) `W: 40.0, H: 20.0` [X: 180.0, Y: 0.0 | Font: dsBody3Regular | Color: gray400 (#b8b8b8) (op: 1.00)]
