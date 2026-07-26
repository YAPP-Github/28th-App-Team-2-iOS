# 🧩 TextField 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1086-12434)

![TextField](../Images/TextField.png)

## Runtime State Contract

- TextField는 포커스 중 자체 상태를 우선한다. 빈 값은 `focus`, 값이 있으면 `insert`를 렌더링하며, 이때 전달된 `success`·`error` 피드백은 표시하지 않는다.
- 포커스가 해제되면 호출하는 화면이 현재 텍스트를 검증해 `validationState`로 결과를 전달한다. 유효성 규칙과 오류 문구는 화면마다 달라 공용 TextField가 결정하지 않는다.
- 사용자가 다시 편집하면 TextField는 별도의 상태 해제 호출 없이 `focus` 또는 `insert`로 전환된다.
- 화면은 `@FocusState` 바인딩을 `isFocused`로 전달해, 필요할 때 화면 정책에 맞춰 포커스를 해제할 수 있다.
- Figma의 `focus`/`insert`와 `success`/`error`는 동시에 표시되는 조합 상태가 아니므로, Playground 검증 결과는 blur 시 확정한다. 편집 중에는 `focus` 또는 `insert`를 표시한다.
- `insert` 상태의 clear 아이콘은 누르는 동안 `20×20pt` 레이아웃을 유지하고, 아이콘 이미지 자체에 `gray975` 색상을 `16%` opacity로 덮는다. 이 정책으로 아이콘 크기나 터치 영역을 확장하지 않는다.

### Playground Validation Rule

- Playground는 동작 확인을 위해 포커스 해제 시 빈 값을 `default`, `1~10자`를 `success`, `11자 이상`을 `error`로 표시한다. 이 규칙은 공용 `DSTextField`의 유효성 규칙이 아니다.
- Playground 프리뷰 카드의 `완료` 버튼은 포커스를 해제해 위 검증 규칙을 확인한다.
- 부모 레이아웃이 TextField의 가로 폭을 결정한다. Figma의 `W: 353.0`은 기준 캔버스 폭이다.

## 🏗️ Structure & Layout

- 🟦 **TextField** (COMPONENT_SET) `W: 393.0, H: 389.0` [Radius: 5]
  - 🖼️ **Variant: Default** (COMPONENT) `W: 353.0, H: 48.0` [X: 20.0, Y: 20.0 | Fill: gray25 (#fafafa) (op: 1.00) | Radius: 12]
    - 📝 **Placeholder** (TEXT) `W: 321.0, H: 21.0` [X: 16.0, Y: 13.5 | Font: dsBody2Regular | Color: gray600 (#8a8a8a) (op: 1.00)]
  - 🖼️ **Variant: focus** (COMPONENT) `W: 353.0, H: 48.0` [X: 20.0, Y: 88.0 | Fill: gray25 (#fafafa) (op: 1.00) | Stroke: gray975 (#171717) (op: 1.00) | Radius: 12]
    - 🟦 **Rectangle 34626000** (RECTANGLE) `W: 1.0, H: 24.0` [X: 16.0, Y: 12.0 | Fill: #0040ff (op: 1.00)]
    - 📝 **예) 토닥운** (TEXT) `W: 320.0, H: 21.0` [X: 17.0, Y: 13.5 | Font: dsBody2Regular | Color: gray600 (#8a8a8a) (op: 1.00)]
  - 🖼️ **Variant: insert** (COMPONENT) `W: 353.0, H: 48.0` [X: 20.0, Y: 156.0 | Fill: gray25 (#fafafa) (op: 1.00) | Stroke: gray975 (#171717) (op: 1.00) | Radius: 12]
    - 🟦 **Frame 1430106244** (FRAME) `W: 30.0, H: 24.0` [X: 16.0, Y: 12.0]
      - 📝 **text** (TEXT) `W: 29.0, H: 24.0` [X: 0.0, Y: 0.0 | Font: dsBody2Medium | Color: gray975 (#171717) (op: 1.00)]
      - 🟦 **Rectangle 34626000** (RECTANGLE) `W: 1.0, H: 24.0` [X: 29.0, Y: 0.0 | Fill: #0040ff (op: 1.00)]
    - 🖼️ **circle_x_fill** (INSTANCE) `W: 20.0, H: 20.0` [X: 317.0, Y: 14.0]
      - 🟦 **circle_x_fill** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content_area** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
      - 🟦 **Background** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
    - Text content ↔ clear icon gap: `10pt`
  - 🖼️ **Variant: success** (COMPONENT) `W: 353.0, H: 48.0` [X: 20.0, Y: 224.0 | Fill: gray25 (#fafafa) (op: 1.00) | Radius: 12]
    - 📝 **text** (TEXT) `W: 321.0, H: 24.0` [X: 16.0, Y: 12.0 | Font: dsBody2Medium | Color: gray975 (#171717) (op: 1.00)]
  - 🖼️ **Variant: error** (COMPONENT) `W: 353.0, H: 72.0` [X: 20.0, Y: 292.0 | Radius: 12]
    - 🟦 **Frame 1430106418** (FRAME) `W: 353.0, H: 72.0` [X: 0.0, Y: 0.0]
      - 🟦 **Frame 1430106417** (FRAME) `W: 353.0, H: 48.0` [X: 0.0, Y: 0.0 | Fill: red50 (#fff7f7) (op: 1.00) | Radius: 12]
        - 📝 **text** (TEXT) `W: 321.0, H: 24.0` [X: 16.0, Y: 12.0 | Font: dsBody2Medium | Color: gray975 (#171717) (op: 1.00)]
      - 🟦 **Frame 1430106416** (FRAME) `W: 353.0, H: 16.0` [X: 0.0, Y: 56.0]
        - 📝 **최대 10글자까지 입력 가능해요.** (TEXT) `W: 149.0, H: 16.0` [X: 4.0, Y: 0.0 | Font: dsCaption1Regular | Color: red500 (#ea4343) (op: 1.00)]
