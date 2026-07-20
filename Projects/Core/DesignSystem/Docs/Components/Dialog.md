# 🧩 Dialog 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=394-5155)

> [!IMPORTANT]
> 다이얼로그(Dialog) 컴포넌트의 가로 폭(Width)은 **280px로 항상 고정**됩니다.


![Dialog](../Images/Dialog.png)

## 🏗️ Structure & Layout

- 🟦 **Dialog** (COMPONENT_SET) `W: 320.0, H: 191.0` [Radius: 5]
  - 🖼️ **Variant: Dialog** (COMPONENT) `W: 280.0, H: 152.0` [X: 20.0, Y: 20.0 | Fill: white (#ffffff) (op: 1.00) | Radius: 12]
    - 🟦 **Frame 625626** (FRAME) `W: 280.0, H: 68.0` [X: 0.0, Y: 0.0]
      - 🟦 **text** (FRAME) `W: 280.0, H: 68.0` [X: 0.0, Y: 0.0]
        - 🟦 **Frame 625625** (FRAME) `W: 240.0, H: 48.0` [X: 20.0, Y: 20.0]
          - 📝 **타이틀을 입력해주세요** (TEXT) `W: 240.0, H: 24.0` [X: 0.0, Y: 0.0 | Font: dsBody2SemiBold | Color: gray975 (#171717) (op: 1.00)]
          - 📝 **본문 내용을 입력해주세요.** (TEXT) `W: 240.0, H: 20.0` [X: 0.0, Y: 28.0 | Font: dsBody3Regular | Color: gray800 (#5c5c5c) (op: 1.00)]
      - 🖼️ **Button** (INSTANCE) `W: 280.0, H: 84.0` [X: 0.0, Y: 68.0]
      - 🖼️ **Button** (INSTANCE) `W: 240.0, H: 44.0` [X: 20.0, Y: 20.0]
        - 🖼️ **Button** (INSTANCE) `W: 240.0, H: 44.0` [X: 0.0, Y: 0.0 | Fill: primary600 (#7f73ea) (op: 1.00) | Radius: 12]
          - 📝 **다음 단계** (TEXT) `W: 36.0, H: 20.0` [X: 102.0, Y: 12.0 | Font: dsBody3SemiBold | Color: white (#ffffff) (op: 1.00)]
