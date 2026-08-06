# 🧩 Enter date of birth 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=381-2411)

![Enter date of birth](../Images/Enter_date_of_birth.png)

## Runtime Contract

- 구현 타입은 `DSEnterDateOfBirth`이며 Model의 `BirthDate?`와 focus 여부, 탭 action을 외부에서 입력받습니다.
- 레이블은 `생년월일`, placeholder는 `생년월일 선택`으로 고정하며 선택값은 `yyyy년 M월 d일` 형태로 표시합니다.
- 선택값 표시, clear, chevron과 pressed 상태는 하위 `DSSelectField`에 위임합니다.
- Picker 표시 여부, 년·월·일 항목, 날짜 범위, 윤년과 미래 날짜 정책은 호출자가 소유합니다. `BirthDate`는 검증을 수행하지 않는 선택 결과 값입니다.
- `DSWheelPickerPanel(layout: .date)`와 `DSMultiWheelPicker(layout: .date)` 조합은 Example과 Feature에서 구성합니다.

## 🏗️ Structure & Layout

- 🖼️ **Enter date of birth** (COMPONENT) `W: 353.0, H: 90.0`
  - 📝 **생년월일** (TEXT) `W: 63.0, H: 26.0` [X: 0.0, Y: 0.0 | Font: dsBody1Bold | Color: black (#000000) (op: 1.00)]
  - 🖼️ **SelectField** (INSTANCE) `W: 353.0, H: 48.0` [X: 0.0, Y: 42.0 | Fill: gray25 (#fafafa) (op: 1.00) | Radius: 12]
    - 📝 **Placeholder** (TEXT) `W: 291.0, H: 21.0` [X: 16.0, Y: 13.5 | Font: dsBody2Regular | Color: gray600 (#8a8a8a) (op: 1.00)]
    - 🟦 **chevron_small_bottom** (FRAME) `W: 20.0, H: 20.0` [X: 317.0, Y: 14.0]
      - 🟦 **chevron_small_bottom** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content_area** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content** (GROUP) `W: 16.7, H: 16.7` [X: 1.7, Y: 1.7]
          - 🟦 **background** (RECTANGLE) `W: 16.7, H: 16.7` [X: 0.0, Y: 0.0]
