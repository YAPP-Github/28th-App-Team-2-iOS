# 🧩 Todak Example Question 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=2173-21550)

![Todak Example Question](../Images/Todak_Example_Question.png)

## 🏗️ Structure & Layout

- 🖼️ **Todak Example Question** (COMPONENT) `H: 48.0 min`
  - 🖼️ **User Chat** (INSTANCE) [Fill: primary50 (#f5f3fe) (op: 1.00) | Radius: 12]
    - 📝 **📅 중요한 일정 잡기 좋은 날인지 궁금해** [X: 18.0, Y: 12.0 | Font: dsBody2Regular (Figma LH: 24.0px) | Color: coolGray800]

## 폭 계약

- Figma의 `W: 284.0`은 해당 예시 문구가 만든 결과 폭이며, 컴포넌트의 고정 폭이 아니다.
- 질문 말풍선은 텍스트의 intrinsic width와 좌우 padding `18pt`로 폭을 결정한다.
- 부모가 제공하는 너비보다 긴 문구는 부모 폭 안에서 줄바꿈하며, `48pt`는 최소 높이로 유지한다.

## 콘텐츠 API

- `DSTodakExampleQuestion.Segment(text, isBold:)` 배열로 서버·로컬 문구의 일부 구간을 강조할 수 있다.
- 일반 구간은 `dsBody2Regular`, `coolGray800`으로 렌더링한다.
- 강조 구간은 `dsBody2SemiBold`, `coolGray900`으로 렌더링한다.
