# Adaptive Layout

## Figma 수치 분류

| 수치의 역할 | 기본 구현 |
| --- | --- |
| padding, spacing, radius | 디자인 상수로 사용 가능 |
| 아이콘, 고정 badge, 명확한 control 규격 | 의도된 고정 크기 사용 가능 |
| 가로 carousel의 카드 규격 | 반복 리듬이 요구되면 고정 가능 |
| 화면, 시트, 일반 section width | 부모가 제안한 너비 사용 |
| 텍스트 container height | 콘텐츠 기반 우선 |
| 카드 높이 | 고정보다 intrinsic 또는 `minHeight` 검토 |
| 이미지 | 원본 비율과 crop 정책 명시 |
| safe area와 tab bar 공간 | 실제 소유 계층에서 처리 |

고정값을 없애는 것이 목적이 아니다. 수치가 디자인 계약인지 특정 Figma 캔버스에서 나온 결과인지 구분한다.

## 컨테이너

- 기본 화면 너비는 부모가 제안한다. `UIScreen.main.bounds`를 레이아웃 입력으로 사용하지 않는다.
- 일반 세로 화면은 유동 width의 root, 명시적인 horizontal padding, 콘텐츠 기반 height로 시작한다.
- 자식의 큰 intrinsic size가 부모 너비를 밀어내는지 확인한다. 큰 이미지와 긴 고정 frame을 먼저 의심한다.
- `GeometryReader`는 부모 치수를 계산에 사용하는 배경, overlay, 비율 기반 배치 등에만 격리한다. 일반 콘텐츠 root로 사용해 크기를 강제하지 않는다.

## 이미지

이미지마다 다음을 결정한다.

1. 원본 크기를 유지하는가, `resizable`인가?
2. 비율을 유지하는가, 의도적으로 변형하는가?
3. 전체가 보여야 하는가, crop을 허용하는가?
4. 너비와 높이 중 무엇이 기준인가?
5. 이미지가 레이아웃 크기를 결정하는가, 배경으로만 그려지는가?

- 콘텐츠 이미지는 일반적으로 비율을 유지하고 부모가 허용한 영역 안에서 표시한다.
- 장식 배경은 기본적으로 스크롤 콘텐츠의 intrinsic size를 결정하지 않게 분리한다.
- 장식 배경의 크기는 viewport, container width, 고정 비율 중 디자인 의도에 맞는 기준으로 결정한다.
- 이미지 이후 남는 영역을 단색 배경이 채우는 디자인이라면 이미지 높이를 스크롤 높이에 맞춰 확대하지 않는다.
- 전체 콘텐츠와 함께 이어지는 패턴·그라데이션처럼 배경이 콘텐츠 높이를 따라야 하는 디자인은 예외이며 요구사항을 확인한다.
- 원본 asset 비율을 코드에 적어야 한다면 그 값이 화면 크기가 아니라 asset metadata라는 의미를 이름으로 드러낸다.

## 스크롤과 safe area

- 배경, scroll content, overlay, tab bar의 레이어와 크기 책임을 분리한다.
- Feature는 App이 소유한 MainTab이나 BottomNavigation을 내부에 중복 배치하지 않는다.
- tab bar로 인한 하단 공간은 최종 조립 계층이 소유한다.
- header가 safe area 안쪽인지 배경만 safe area를 무시하는지 구분한다.
- 고정 전체 높이로 스크롤 가능 여부를 제어하지 않는다. 콘텐츠가 작은 화면에서 자연스럽게 스크롤되는지 확인한다.

## modifier 순서

다음 순서를 의식적으로 결정한다.

- content layout
- padding과 visual frame
- background·overlay
- clip shape
- content shape
- pressed ButtonStyle
- 추가 hit area

시각 영역보다 큰 hit area가 필요하면 pressed style이 보는 label 크기와 바깥 hit area를 분리한다. modifier 순서를 바꾼 뒤에는 screenshot과 실제 터치로 확인한다.
