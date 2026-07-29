# 🧩 Toast 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1284-5826)

![Toast](../Images/Toast.png)

## 🏗️ Structure & Layout

- 🖼️ **Toast / Standard** (COMPONENT) `Intrinsic W: 212.0, H: 36.0`
  - 배경: `opacity80 (#000000 80%)`
  - 모서리: `8pt`
  - 내부 여백: `8pt`
  - 콘텐츠 간격: `8pt`
  - 메시지: `dsBody3Regular`, `gray50 (#F7F7F8)`, line height `20pt`, single line
  - 닫기 버튼: `20 × 20pt`
  - 닫기 아이콘 프레임: `16 × 16pt`
  - 닫기 glyph: `13.3333 × 13.3333pt`, `gray50`

## 🔎 구현 해석

- `DSToast(_:onClose:)`로 메시지와 닫기 동작을 호출 화면이 주입한다.
- 너비는 콘텐츠가 결정하며 전역 표시 큐, 자동 제거 타이머와 singleton은 포함하지 않는다.
