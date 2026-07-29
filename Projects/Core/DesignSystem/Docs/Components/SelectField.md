# 🧩 SelectField 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1086-16782)

![SelectField](../Images/SelectField.png)

## 구현 메모

- SelectField는 직접 입력 필드가 아니라 선택 화면 진입 버튼으로 구현한다.
- `selection`은 외부 `Binding<String?>`으로 제어하며, 값이 있을 때 clear 버튼으로 `nil`을 전달한다.
- `isFocused`는 wheel picker 등 선택 화면이 열린 상태를 부모가 표시하기 위한 값이며, focused 상태에서는 stroke를 표시한다.
- focused 상태에서는 chevron을 위 방향으로 회전하고 색상을 gray975로 표시한다.
- `isFocused == true`가 우선이고, `isFocused == false && selection != nil`일 때 success 상태로 해석한다.

## 🏗️ Structure & Layout

- 🟦 **SelectField** (COMPONENT_SET) `W: 393.0, H: 224.0` [Radius: 5]
  - 🖼️ **Variant: Default** (COMPONENT) `W: 353.0, H: 48.0` [X: 20.0, Y: 20.0 | Fill: gray25 (#fafafa) (op: 1.00) | Radius: 12]
    - 📝 **Placeholder** (TEXT) `W: 291.0, H: 21.0` [X: 16.0, Y: 13.5 | Font: dsBody2Regular | Color: gray600 (#8a8a8a) (op: 1.00)]
    - 🟦 **chevron_small_bottom** (FRAME) `W: 20.0, H: 20.0` [X: 317.0, Y: 14.0]
      - 🟦 **chevron_small_bottom** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content_area** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content** (GROUP) `W: 16.7, H: 16.7` [X: 1.7, Y: 1.7]
          - 🟦 **background** (RECTANGLE) `W: 16.7, H: 16.7` [X: 0.0, Y: 0.0]
  - 🖼️ **Variant: success** (COMPONENT) `W: 353.0, H: 48.0` [X: 20.0, Y: 156.0 | Fill: gray25 (#fafafa) (op: 1.00) | Radius: 12]
    - 📝 **Placeholder** (TEXT) `W: 261.0, H: 21.0` [X: 16.0, Y: 13.5 | Font: dsBody2Medium | Color: gray975 (#171717) (op: 1.00)]
    - 🖼️ **circle_x_fill** (INSTANCE) `W: 20.0, H: 20.0` [X: 287.0, Y: 14.0]
      - 🟦 **circle_x_fill** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content_area** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
          - 🟦 **Background** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
    - 🟦 **chevron_small_bottom** (FRAME) `W: 20.0, H: 20.0` [X: 317.0, Y: 14.0]
      - 🟦 **chevron_small_bottom** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content_area** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content** (GROUP) `W: 16.7, H: 16.7` [X: 1.7, Y: 1.7]
          - 🟦 **background** (RECTANGLE) `W: 16.7, H: 16.7` [X: 0.0, Y: 0.0]
  - 🖼️ **Variant: focus** (COMPONENT) `W: 353.0, H: 48.0` [X: 20.0, Y: 88.0 | Fill: gray25 (#fafafa) (op: 1.00) | Stroke: gray975 (#171717) (op: 1.00) | Radius: 12]
    - 📝 **Text** (TEXT) `W: 291.0, H: 21.0` [X: 16.0, Y: 13.5 | Font: dsBody2Medium | Color: gray975 (#171717) (op: 1.00)]
    - 🟦 **chevron_small_bottom** (FRAME) `W: 20.0, H: 20.0` [X: 317.0, Y: 14.0]
      - 🟦 **chevron_small_bottom** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content_area** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content** (GROUP) `W: 16.7, H: 16.7` [X: 1.7, Y: 1.7]
          - 🟦 **background** (RECTANGLE) `W: 16.7, H: 16.7` [X: 0.0, Y: 0.0]
