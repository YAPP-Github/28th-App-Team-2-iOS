# 🧩 Header 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1284-15268)

![Header](../Images/Header.png)

## 🏗️ Structure & Layout

- 🟦 **Header** (COMPONENT_SET) `W: 433.0, H: 208.0` [Fill: #f6f6f6 (op: 1.00) | Radius: 5]
  - 🖼️ **Variant: Header_sub** (COMPONENT) `W: 393.0, H: 48.0` [X: 20.0, Y: 127.0 | Fill: white (#ffffff) (op: 1.00)]
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
  - 🖼️ **Variant: Header_main** (COMPONENT) `W: 393.0, H: 60.0` [X: 20.0, Y: 39.0 | Fill: white (#ffffff) (op: 1.00)]
    - 🟦 **Frame 1430106352** (FRAME) `W: 107.0, H: 30.0` [X: 20.0, Y: 15.0]
      - 📝 **Title** (TEXT) `W: 47.0, H: 30.0` [X: 0.0, Y: 0.0 | Font: dsHeading4Bold | Color: black (#000000) (op: 1.00)]
      - 📝 **subtext** (TEXT) `W: 48.0, H: 20.0` [X: 59.0, Y: 5.0 | Font: dsBody3Regular | Color: gray500 (#9a9a9a) (op: 1.00)]
    - 🖼️ **Iconex/Light/Bell** (INSTANCE) `W: 24.0, H: 24.0` [X: 349.0, Y: 18.0]
      - 🟦 **Bell** (GROUP) `W: 15.7, H: 20.0` [X: 4.0, Y: 2.0]
        - 🟦 **Union** (BOOLEAN_OPERATION) `W: 15.7, H: 16.5` [X: 0.0, Y: 0.0 | Stroke: gray975 (#171717) (op: 1.00)]

## 📐 Layout Contract

### Header Main (`DSHeaderMain`)

- 전체 가로 폭은 고정하지 않고 부모 폭을 채우며, 컨텐츠 높이는 `60pt`입니다.
- 좌우 horizontal padding은 `20pt`입니다.
- 좌측에는 title과 선택적 subtitle을 `12pt` 간격으로 배치합니다.
- title은 `heading4Bold`, `black`이고 subtitle은 `body3Regular`, `gray500`입니다.
- 우측 액션 아이콘은 `24 x 24`이며, 현재 명세는 우측 액션 1개를 기준으로 합니다.

### Header Sub (`DSHeaderSub`)

- 전체 가로 폭은 고정하지 않고 부모 폭을 채우며, 컨텐츠 높이는 `48pt`입니다.
- 좌우 horizontal padding은 `20pt`입니다.
- title은 헤더 전체의 수평 중앙에 고정하며 `body2SemiBold`, `black`입니다.
- 좌측 액션과 우측 액션 아이콘은 `20 x 20`이며, 현재 명세는 좌측 액션 1개와 우측 액션 1개를 기준으로 합니다.
- safe area와 헤더 외부 간격은 부모 화면이 결정합니다.

## 🧾 Content & Interaction Contract

- title, subtitle과 버튼 동작은 사용하는 화면이 소유하고 Header에 주입합니다.
- Main의 subtitle은 `nil`이면 렌더링하지 않습니다.
- Main의 우측 액션, Sub의 좌측·우측 액션은 모두 `DSHeaderActionItem(identifier:icon:action:)`으로 전달합니다.
- `DSHeaderActionItem`은 아이콘과 action을 표현하고, 버튼 크기·색상·pressed 상태는 각 Header 컴포넌트가 소유합니다.
- `nil` 액션은 해당 슬롯을 렌더링하지 않습니다.
- 실제 화면 전환, 알림, 뒤로가기, 닫기 동작은 DesignSystem이 소유하지 않습니다.
- pressed 상태는 아이콘 이미지에 프로젝트 공통 `gray975` 16% overlay 정책을 적용합니다.

## 🧪 DesignSystemExample

- Main/Sub를 전환해 한 번에 하나의 public 컴포넌트를 렌더링합니다.
- subtitle과 좌·우 액션의 표시 여부를 바꾸고 action closure 연결 결과를 확인할 수 있어야 합니다.

## 🔗 Asset Mapping

- Main 기본 우측 알림 아이콘: `DSIconAsset.bell`
- Sub 기본 좌측 뒤로가기 아이콘: `DSIconAsset.chevronLeftNarrow`
- Sub 기본 우측 닫기 아이콘: `DSIconAsset.deleteLine`
