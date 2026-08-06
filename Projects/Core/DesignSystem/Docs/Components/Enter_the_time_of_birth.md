# 🧩 Enter the time of birth 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=383-1123)

![Enter the time of birth](../Images/Enter_the_time_of_birth.png)

## Runtime Contract

- 구현 타입은 `DSEnterTimeOfBirth`이며 Model의 `BirthTimePeriod?`, focus 여부, 시간 모름 여부와 탭 action을 외부에서 입력받습니다.
- 레이블은 `태어난 시간`, placeholder는 `태어난 시간 선택`으로 고정합니다. 선택값은 Picker item과 동일한 `인시 (寅時): 03:30 ~ 05:29` 형식으로 표시하며, 필드 너비를 넘으면 하위 `DSSelectField`의 한 줄 tail truncation으로 처리합니다.
- 선택값 표시, clear, chevron과 pressed 상태는 하위 `DSSelectField`에 위임합니다.
- `시간 모름` 영역은 라벨 조합 API를 사용하는 하나의 `DSCheckbox`입니다. 체크박스와 텍스트를 포함한 배경 전체가 동일한 Toggle interaction을 공유하고, pressed overlay는 Checkbox indicator의 `20×20pt` 영역에만 표시합니다.
- `시간 모름` 영역의 너비와 높이는 고정하지 않습니다. `DSCheckbox` 20pt, 라벨 간격 6pt, 텍스트의 intrinsic size, 좌우 16pt·상하 14pt padding으로 자연스럽게 결정됩니다. Figma의 `117×48pt`는 이 구성값에서 나온 기준 문자열의 결과 크기로만 검증합니다.
- 시간 선택과 `시간 모름`은 상호 배타적입니다. `시간 모름`을 켜면 기존 시간 선택을 초기화하고, 새 시간을 선택하면 `시간 모름`을 해제합니다. `시간 모름`을 끌 때 이전 시간은 복원하지 않으며 SelectField는 계속 사용할 수 있습니다.
- 자시부터 해시까지의 선택 의미·순서와 23:30~23:29 구간 경계는 `BirthTimePeriod`가 소유하고, 한글·한자 및 Picker 표시 문구는 DesignSystem이 소유합니다.
- Picker 표시 여부와 임시 선택·저장 동작은 호출자가 소유합니다. Example은 `DSWheelPickerPanel(layout: .single)`과 `DSSingleWheelPicker`를 `BirthTimePeriod.allCases`로 구성합니다.

## 🏗️ Structure & Layout

- 🖼️ **Enter the time of birth** (COMPONENT) `W: 353.0, H: 90.0`
  - 📝 **태어난 시간** (TEXT) `W: 82.0, H: 26.0` [X: 0.0, Y: 0.0 | Font: dsBody1Bold | Color: black (#000000) (op: 1.00)]
  - 🟦 **Frame 1430106068** (FRAME) `W: 353.0, H: 48.0` [X: 0.0, Y: 42.0]
    - 🖼️ **SelectField** (INSTANCE) `W: 224.0, H: 48.0` [X: 0.0, Y: 0.0 | Fill: gray25 (#fafafa) (op: 1.00) | Radius: 12]
      - 📝 **Placeholder** (TEXT) `W: 162.0, H: 21.0` [X: 16.0, Y: 13.5 | Font: dsBody2Regular | Color: gray600 (#8a8a8a) (op: 1.00)]
      - 🟦 **chevron_small_bottom** (FRAME) `W: 20.0, H: 20.0` [X: 188.0, Y: 14.0]
        - 🟦 **chevron_small_bottom** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
          - 🟦 **content_area** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
          - 🟦 **content** (GROUP) `W: 16.7, H: 16.7` [X: 1.7, Y: 1.7]
            - 🟦 **background** (RECTANGLE) `W: 16.7, H: 16.7` [X: 0.0, Y: 0.0]
    - 🟦 **Frame 1430105945** (FRAME) `W: 117.0, H: 48.0` [X: 236.0, Y: 0.0 | Fill: gray25 (#fafafa) (op: 1.00) | Radius: 12]
      - 🖼️ **Checkbox** (INSTANCE) `W: 20.0, H: 20.0` [X: 16.0, Y: 14.0 | Fill: white (#ffffff) (op: 1.00) | Stroke: gray300 (#dcdcdc) (op: 1.00) | Radius: 6]
      - 📝 **시간 모름** (TEXT) `W: 59.0, H: 21.0` [X: 42.0, Y: 13.5 | Font: dsBody3Medium | Color: gray975 (#171717) (op: 1.00)]
