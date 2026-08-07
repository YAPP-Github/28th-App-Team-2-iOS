# 🧩 Todak Example Question 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=2173-21550)

![Todak Example Question](../Images/Todak_Example_Question.png)

## 🏗️ Structure & Layout

- 🖼️ **Todak Example Question** (COMPONENT) `W: 284.0, H: 48.0`
  - 🖼️ **User Chat** (INSTANCE) `W: 284.0, H: 48.0` [X: 0.0, Y: 0.0 | Fill: primary50 (#f5f3fe) (op: 1.00) | Radius: 12]
    - 📝 **📅 중요한 일정 잡기 좋은 날인지 궁금해** (TEXT) `W: 248.0, H: 24.0` [X: 18.0, Y: 12.0 | Font: dsBody2Regular (Figma LH: 24.0px) | Color: coolGray800]

## 콘텐츠 API

- `DSTodakExampleQuestion.Segment(text, isBold:)` 배열로 서버·로컬 문구의 일부 구간을 강조할 수 있다.
- 일반 구간은 `dsBody2Regular`, `coolGray800`으로 렌더링한다.
- 강조 구간은 `dsBody2SemiBold`, `coolGray900`으로 렌더링한다.
