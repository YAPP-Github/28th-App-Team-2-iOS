# 🧩 Toast_Lucky action 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=2113-25892)

![Toast_Lucky action](../Images/Toast_Lucky_action.png)

## 🏗️ Structure & Layout

- 🖼️ **Toast / Lucky Action** (COMPONENT) `Parent W: 353.0, Minimum H: 44.0`
  - 너비: 부모의 가용 폭 채움
  - 배경 그라디언트: `primary600 (#7F73EA) → primary800 (#4545B8) → sky600 (#7592F2)`
  - 그라디언트 위치: `0% / 50% / 100%`, leading → trailing
  - 모서리: `8pt`
  - 내부 여백: leading `18pt`, trailing `16pt`, vertical `12pt`
  - 메시지와 닫기 버튼 간격: `8pt`
  - 메시지: `dsBody3Regular`, `gray50 (#F7F7F8)`, line height `20pt`, 줄 수 제한 없음
  - 닫기 버튼: `20 × 20pt`
  - 닫기 아이콘 프레임: `16 × 16pt`
  - 닫기 glyph: `13.3333 × 13.3333pt`, `whiteOpacity60`
  - 고유 그림자: `X: 0, Y: 0, Blur: 20, Spread: 0, #9C8AF6 50%`

## 🔎 구현 해석

- `DSToast(luckyAction:onClose:)`로 메시지와 닫기 동작을 호출 화면이 주입한다.
- 메시지는 leading에서 `18pt`, 닫기 버튼은 trailing에서 `16pt`를 유지하며 메시지 영역이 남은 폭을 채운다.
- 메시지는 가용 폭을 초과하면 자동으로 줄바꿈되며, 줄 수에 맞춰 전체 높이가 `44pt` 이상으로 자연스럽게 늘어난다.
- 별도 공용 Shadow modifier는 만들지 않는다. 위 그림자는 Lucky Action Toast 자체 Specification에만 속한다.
