# 🧩 Bottom_Navigation 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=380-2848)

![Bottom_Navigation](../Images/Bottom_Navigation.png)

## 🏗️ Structure & Layout

- 🖼️ **Bottom_Navigation** (COMPONENT) `W: 393.0, H: 90.0`
  - 🟦 **iOS** (FRAME) `W: 393.0, H: 56.0` [X: 0.0, Y: 0.0]
    - 🟦 **Bottom Navigation/Container** (FRAME) `W: 393.0, H: 56.0` [X: 0.0, Y: 0.0 | Fill: whiteOpacity60 (whiteOpacity60 (whiteOpacity60 (#ffffff))) (op: 1.00)]
      - 🟦 **Contents** (FRAME) `W: 369.0, H: 45.0` [X: 12.0, Y: 5.5]
        - 🟦 **Tab** (FRAME) `W: 92.2, H: 41.0` [X: 0.0, Y: 4.0 | Fill: whiteOpacity60 (whiteOpacity60 (whiteOpacity60 (#ffffff))) (op: 1.00)]
          - 🖼️ **ic_navi_lucky** (INSTANCE) `W: 24.0, H: 24.0` [X: 34.1, Y: 0.0]
            - 🟦 **Subtract** (BOOLEAN_OPERATION) `W: 20.0, H: 20.0` [X: 2.0, Y: 2.0 | Fill: gray975 (gray975 (gray975 (#171717))) (op: 1.00)]
              - 🟦 **Ellipse 46** (ELLIPSE) `W: 20.0, H: 20.0` [X: 0.0, Y: 0.0]
              - 🟦 **Group 1171275297** (GROUP) `W: 7.5, H: 12.8` [X: 3.2, Y: 3.2]
            - 🟦 **Union** (BOOLEAN_OPERATION) `W: 0.0, H: 0.0` [X: 29247.9, Y: 26733.5 | Fill: gray975 (gray975 (gray975 (#171717))) (op: 1.00)]
          - 📝 **운세** (TEXT) `W: 92.2, H: 13.0` [X: 0.0, Y: 28.0 | Font: dsCaption3SemiBold | Color: gray975 (gray975 (gray975 (#171717))) (op: 1.00)]
        - 🟦 **Tab** (FRAME) `W: 92.2, H: 41.0` [X: 92.2, Y: 4.0 | Fill: whiteOpacity60 (whiteOpacity60 (whiteOpacity60 (#ffffff))) (op: 1.00)]
          - 🖼️ **ic_navi_ai** (INSTANCE) `W: 24.0, H: 24.0` [X: 34.1, Y: 0.0]
            - 🟦 **Group 1171275307** (GROUP) `W: 8.4, H: 1.8` [X: 7.8, Y: 11.0]
          - 📝 **토닥이** (TEXT) `W: 92.2, H: 13.0` [X: 0.0, Y: 28.0 | Font: dsCaption3Medium | Color: gray500 (gray500 (gray500 (#9a9a9a))) (op: 1.00)]
        - 🟦 **Tab** (FRAME) `W: 92.2, H: 41.0` [X: 184.5, Y: 4.0 | Fill: whiteOpacity60 (whiteOpacity60 (whiteOpacity60 (#ffffff))) (op: 1.00)]
          - 🖼️ **ic_navi_action** (INSTANCE) `W: 24.0, H: 24.0` [X: 34.1, Y: 0.0]
            - 🟦 **Group 1171275295** (GROUP) `W: 20.0, H: 20.0` [X: 2.0, Y: 2.0]
          - 📝 **행운 액션** (TEXT) `W: 92.2, H: 13.0` [X: 0.0, Y: 28.0 | Font: dsCaption3Medium | Color: gray500 (gray500 (gray500 (#9a9a9a))) (op: 1.00)]
        - 🟦 **Tab** (FRAME) `W: 92.2, H: 41.0` [X: 276.8, Y: 4.0 | Fill: whiteOpacity60 (whiteOpacity60 (whiteOpacity60 (#ffffff))) (op: 1.00)]
          - 🖼️ **ic_navi_my** (INSTANCE) `W: 24.0, H: 24.0` [X: 34.1, Y: 0.0]
            - 🟦 **Union** (BOOLEAN_OPERATION) `W: 0.0, H: 0.0` [X: 28971.1, Y: 26733.5 | Fill: coolGray600 (coolGray600 (coolGray600 (#6b7486))) (op: 1.00)]
            - 🟦 **Union** (BOOLEAN_OPERATION) `W: 19.3, H: 19.4` [X: 2.4, Y: 2.3 | Fill: coolGray600 (coolGray600 (coolGray600 (#6b7486))) (op: 1.00)]
          - 📝 **마이** (TEXT) `W: 92.2, H: 13.0` [X: 0.0, Y: 28.0 | Font: dsCaption3Medium | Color: gray500 (gray500 (gray500 (#9a9a9a))) (op: 1.00)]
  - 🟦 **HomeIndicator** (FRAME) `W: 393.0, H: 34.0` [X: 0.0, Y: 56.0 | Fill: whiteOpacity60 (whiteOpacity60 (whiteOpacity60 (#ffffff))) (op: 1.00)]
    - 🟦 **Home Indicator** (RECTANGLE) `W: 134.0, H: 5.0` [X: 130.0, Y: 21.0 | Fill: black (black (black (#000000))) (op: 1.00) | Radius: 100]
