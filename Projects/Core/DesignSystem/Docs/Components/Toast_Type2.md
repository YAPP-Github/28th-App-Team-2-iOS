# 🧩 Toast_Type2 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1318-12830)

![Toast_Type2](../Images/Toast_Type2.png)

## 🏗️ Structure & Layout

- 🖼️ **Toast / Compact** (INSTANCE) `Intrinsic W: 184.0, H: 36.0`
  - 배경: `opacity80 (#000000 80%)`
  - 모서리: `8pt`
  - 내부 여백: `8pt`
  - 메시지: `dsBody3Regular`, `gray50 (#F7F7F8)`, line height `20pt`, single line
  - 닫기 버튼: 없음

## 🔎 구현 해석

- `DSToast(compact:)`는 직접 interaction이 없는 정적 표시 형태다.
- 너비는 콘텐츠가 결정한다.
