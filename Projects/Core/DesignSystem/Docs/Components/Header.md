# 🧩 Header 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1284-15268)

![Header](../Images/Header.png)

## 🏗️ Structure & Layout

- 🟦 **Header** (COMPONENT_SET) `W: 433.0, H: 208.0` [Fill: #f6f6f6 (op: 1.00) | Radius: 5]
  - 🖼️ **Variant: Header_sub** (COMPONENT) `W: 393.0, H: 48.0` [X: 20.0, Y: 127.0 | Fill: whiteOpacity60 (#ffffff) (op: 1.00)]
    - 🟦 **chevron_left_narrow** (FRAME) `W: 20.0, H: 20.0` [X: 20.0, Y: 14.0]
      - 🟦 **chevron_left_narrow** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content_area** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
          - 🟦 **background** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
          - 🟦 **arrow** (GROUP) `W: 16.7, H: 16.7` [X: 1.7, Y: 1.7]
            - 🟦 **Rectangle 5397** (RECTANGLE) `W: 16.7, H: 16.7` [X: 0.0, Y: 0.0]
    - 🟦 **Group 1171275260** (GROUP) `W: 316.0, H: 6.0` [X: 56.0, Y: 21.0]
      - 🟦 **Rectangle 1744** (RECTANGLE) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0 | Radius: 10]
      - 🟦 **Mask group** (GROUP) `W: 210.0, H: 6.0` [X: 0.0, Y: 0.0]
        - 🟦 **Rectangle 1745** (RECTANGLE) `W: 210.0, H: 6.0` [X: 0.0, Y: 0.0 | Fill: black (#000000) (op: 1.00) | Radius: 10]
        - 🟦 **Rectangle 34625979** (RECTANGLE) `W: 316.0, H: 6.0` [X: 0.0, Y: 0.0]
    - 📝 **택일 운세** (TEXT) `W: 60.0, H: 24.0` [X: 167.0, Y: 13.5 | Font: dsBody2SemiBold | Color: black (#000000) (op: 1.00)]
    - 🖼️ **delete_line** (INSTANCE) `W: 20.0, H: 20.0` [X: 353.0, Y: 14.0]
      - 🟦 **delete_line** (GROUP) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content_area** (RECTANGLE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
        - 🟦 **content** (GROUP) `W: 16.7, H: 16.7` [X: 1.7, Y: 1.7]
          - 🟦 **Rectangle 939** (RECTANGLE) `W: 16.7, H: 16.7` [X: 0.0, Y: 0.0 | Fill: #131313 (op: 1.00)]
  - 🖼️ **Variant: Header_main** (COMPONENT) `W: 393.0, H: 60.0` [X: 20.0, Y: 39.0 | Fill: whiteOpacity60 (#ffffff) (op: 1.00)]
    - 🟦 **Frame 1430106352** (FRAME) `W: 107.0, H: 30.0` [X: 20.0, Y: 15.0]
      - 📝 **Title** (TEXT) `W: 47.0, H: 30.0` [X: 0.0, Y: 0.0 | Font: dsHeading4Bold | Color: black (#000000) (op: 1.00)]
      - 📝 **subtext** (TEXT) `W: 48.0, H: 20.0` [X: 59.0, Y: 5.0 | Font: dsBody3Regular | Color: gray500 (#9a9a9a) (op: 1.00)]
    - 🖼️ **Iconex/Light/Bell** (INSTANCE) `W: 24.0, H: 24.0` [X: 349.0, Y: 18.0]
      - 🟦 **Bell** (GROUP) `W: 15.7, H: 20.0` [X: 4.0, Y: 2.0]
        - 🟦 **Union** (BOOLEAN_OPERATION) `W: 15.7, H: 16.5` [X: 0.0, Y: 0.0 | Stroke: gray975 (#171717) (op: 1.00)]
