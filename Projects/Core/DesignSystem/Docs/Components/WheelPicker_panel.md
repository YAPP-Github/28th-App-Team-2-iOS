# 🧩 WheelPicker Panel 상세 명세서

Figma 원본:

- [WheelPicker_single](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=383-1630)
- [WheelPicker_multi](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=1417-23096)
- [WheelPicker_multi02](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=383-1347)

![WheelPicker Panel](../Images/WheelPicker_multi02.png)

## 구현 범위

- `DSWheelPickerPanel`은 Figma 루트 컴포넌트의 흰색 패널, Drag Indicator, 제목, 저장 버튼과 내부 Picker 배치를 구현합니다.
- `.single`, `.time`, `.date` 레이아웃을 제공하며 각각 `DSSingleWheelPicker` 또는 `DSMultiWheelPicker`를 콘텐츠로 조합합니다.
- 패널 제목과 저장 동작은 외부에서 입력합니다.
- `dsWheelPickerSheet`는 화면 전체 modal host 안에 custom overlay로 패널을 표시합니다.
- Sheet 표시 상태, 저장 이후 처리, 날짜 유효성 정책과 도메인 모델은 사용하는 Feature가 소유합니다.
- 커스텀 Drag Indicator를 사용하므로 별도 벡터 에셋은 사용하지 않습니다.

## Runtime Specification

- Container width: `352pt`
- Container height:
  - Single: `319pt`
  - Time: `309pt`
  - Date: `322pt`
- Container background: `white`
- Container shape: radius `12pt`
- Container shadow: `X: 0, Y: 0, Blur: 20, black 5%`
- Horizontal content padding: `30pt`
- Drag Indicator: `44 × 4pt`, `gray200`, capsule
- Top → Drag Indicator: `14pt`
- Drag Indicator → Header: `26pt`
- Header: `292 × 32pt`
- Title: `220pt`, `heading3Bold`, `black`
- Header gap: `28pt`
- Save action: 높이 `31pt`, `body1Medium`, `primary700`, 가로 `6pt` 콘텐츠 여백, capsule; 세로 콘텐츠 여백 없이 텍스트를 중앙 정렬합니다. 기본 `저장` 텍스트에서는 결과 크기가 `44 × 31pt`이며, pressed 시 현재 콘텐츠 영역에 공통 `gray975` 16% overlay를 적용합니다.
- Header → Picker: `28pt`
- Picker → Panel bottom: `40pt`
- Panel → Sheet bottom: `40pt`
- Panel → Keyboard: `12pt`
- Background dimming: `opacity20`

## Sheet Presentation

- 시스템 `.sheet`를 사용하지 않고 투명한 full-screen modal host에 custom overlay를 합성하여 Liquid Glass presentation 표면이 개입하지 않게 합니다.
- `opacity20` scrim과 흰색 Panel만 렌더링합니다.
- full-screen modal host의 시스템 transition은 비활성화하여 scrim을 즉시 표시합니다.
- Panel 표시 상태를 host와 분리하고 Panel에만 SwiftUI `snappy` 애니메이션을 사용한 bottom move transition을 적용합니다.
- 닫을 때는 Panel transition이 끝난 뒤 scrim과 modal host를 제거합니다.
- scrim 탭 또는 커스텀 Drag Indicator의 아래 방향 swipe로 닫을 수 있습니다.
- Drag Indicator 영역은 Top padding, indicator height, indicator-to-header spacing의 합으로 계산합니다.
- Drag Indicator를 dismiss 임계값인 `80pt` 미만으로 당겼다가 놓으면 SwiftUI `snappy` 애니메이션으로 원래 위치에 복귀합니다. 드래그 중 위치 갱신에는 애니메이션을 적용하지 않습니다.
- scrim 탭은 Sheet 전체를 닫는 동작입니다. Picker 내부의 다른 날짜 열 탭은 현재 입력을 확정하고 해당 열로 포커스를 옮기며, 휠 스크롤은 직접 입력을 확정하고 키보드만 닫습니다.
- inline 조합에서 Picker 바깥 탭으로 키보드만 닫으려면 호출 화면에 `dsWheelPickerDismissKeyboardOnTap()`을 적용합니다.
- 키보드 표시 여부에 따라 패널 하단 간격만 `40pt`에서 `12pt`로 조정합니다.
- Panel은 키보드 안전 영역 위에 배치하며, 표시 중에는 배경 콘텐츠를 접근성 트리에서 숨깁니다.
