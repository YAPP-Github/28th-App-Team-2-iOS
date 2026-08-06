# 🧩 Conversation History List 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1244-15351)

![Conversation History List](../Images/Conversation_History_List.png)

## 🏗️ Structure & Layout

- 🖼️ **Conversation History List** (COMPONENT) `W: 393.0, H: 96.0` [Figma Stroke: gray100 (#f1f1f1) (op: 1.00)]
  - 🟦 **Frame 1430106212** (FRAME) `W: 353.0, H: 26.0` [X: 20.0, Y: 20.0]
    - 🟦 **Frame 1430106405** (FRAME) `W: 320.0, H: 26.0` [X: 0.0, Y: 0.0]
      - 📝 **오늘 나의 행운의 숫자는?** (TEXT) `W: 178.0, H: 26.0` [X: 0.0, Y: 0.0 | Font: dsBody1Medium | Color: black (#000000) (op: 1.00)]
      - 🟦 **Ellipse 93** (ELLIPSE) `W: 6.0, H: 6.0` [X: 184.0, Y: 0.0 | Fill: red400 (#f86060) (op: 1.00)]
    - 🖼️ **delete** (INSTANCE) `W: 23.0, H: 23.0` [X: 330.0, Y: 0.0]
  - 📝 **30분 전** (TEXT) `W: 353.0, H: 20.0` [X: 20.0, Y: 56.0 | Font: dsBody3Regular | Color: gray600 (#8a8a8a) (op: 1.00)]

## 구현 경계

- 하단 구분선은 셀 컴포넌트가 아닌 부모 대화 목록의 책임이다. 마지막 셀에는 구분선을 렌더링하지 않도록 목록 구현에서 제어한다.
- **대화 제목:** 고정 높이 96pt 행의 레이아웃을 유지하기 위해 한 줄로 표시하고, 초과 텍스트는 말줄임표로 처리한다.
- 제목·읽지 않음 표시 영역은 320pt, 삭제 아이콘은 23pt이며 두 영역 사이 간격은 10pt다. 삭제 아이콘과 읽지 않음 표시는 제목의 상단에 맞춘다.
