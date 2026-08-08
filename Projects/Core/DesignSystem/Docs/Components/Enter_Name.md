# 🧩 Enter Name 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=381-2376)

![Enter Name](../Images/Enter_Name.png)

## Runtime Contract

- 구현 타입은 `DSEnterName`이며 이름 문자열, validation 상태와 선택적 focus binding을 외부에서 입력받습니다.
- 레이블은 `이름`, placeholder는 `예) 홍길동`으로 고정하며 호출자가 다른 문구를 주입하지 않습니다.
- 입력, focus, clear, success, error 렌더링은 하위 `DSTextField`에 위임합니다.
- validation에 따른 오류 문구와 추가 높이는 `DSTextField` 계약을 따르며 이 컴포넌트가 별도로 재정의하지 않습니다.
- 컴포넌트 너비는 고정하지 않고 부모가 제안한 너비를 채웁니다.

## 🏗️ Structure & Layout

- 🖼️ **Enter Name** (COMPONENT) `W: 353.0, H: 90.0`
  - 🟦 **Frame 1430106067** (FRAME) `W: 353.0, H: 26.0` [X: 0.0, Y: 0.0]
    - 📝 **이름** (TEXT) `W: 32.0, H: 26.0` [X: 0.0, Y: 0.0 | Font: dsBody1Bold | Color: black (#000000) (op: 1.00)]
  - 🖼️ **TextField** (INSTANCE) `W: 353.0, H: 48.0` [X: 0.0, Y: 42.0 | Fill: gray25 (#fafafa) (op: 1.00) | Radius: 12]
    - 📝 **Placeholder** (TEXT) `W: 321.0, H: 21.0` [X: 16.0, Y: 13.5 | Font: dsBody2Regular | Color: gray600 (#8a8a8a) (op: 1.00)]
