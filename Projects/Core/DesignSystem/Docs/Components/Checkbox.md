# 🧩 Checkbox 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=385-4002)

![Checkbox](../Images/Checkbox.png)

## 🏗️ Structure & Layout

- 🟦 **Checkbox** (COMPONENT_SET) `W: 60.0, H: 100.0` [Radius: 5]
  - 🖼️ **Variant: On** (COMPONENT) `W: 20.0, H: 20.0` [X: 20.0, Y: 20.0 | Fill: primary600 (#7f73ea) (op: 1.00) | Radius: 6]
    - 🖼️ **check_line** (INSTANCE) `W: 16.0, H: 16.0` [X: 2.0, Y: 2.0]
      - 🟦 **check_line** (GROUP) `W: 16.0, H: 16.0` [X: 0.0, Y: 0.0]
        - 🟦 **content_area** (RECTANGLE) `W: 16.0, H: 16.0` [X: 0.0, Y: 0.0]
        - 🟦 **content** (GROUP) `W: 13.3, H: 13.3` [X: 1.3, Y: 1.3]
          - 🟦 **Rectangle 5396** (RECTANGLE) `W: 13.3, H: 13.3` [X: 0.0, Y: 0.0]
  - 🖼️ **Variant: Off** (COMPONENT) `W: 20.0, H: 20.0` [X: 20.0, Y: 60.0 | Fill: white (#ffffff) (op: 1.00) | Stroke: gray300 (#dcdcdc) (op: 1.00) | Radius: 6]
