# 🧩 Bottom Navigation 상세 명세서

[🔗 Figma 원본 링크](https://www.figma.com/design/bLZr7Nh53PmRHuEjX7gNco?node-id=380-2848)

![Bottom Navigation](../Images/Bottom_Navigation.png)

## API

`DSBottomNavigation(selectedItem:)`은 선택된 탭을 `Binding<DSBottomNavigationItem>`으로 받습니다. 탭 전환에 따른 화면 라우팅은 App 레이어가 담당하며, 이 컴포넌트는 선택 상태 표시와 Binding 갱신만 담당합니다.

## Layout

| 항목 | 값 |
| --- | --- |
| 컨테이너 높이 | 56pt |
| 가로 패딩 | 12pt |
| Items HStack 상·하단 패딩 | 5.5pt |
| HStack 내부 Item 상단 패딩 | 4pt |
| 상단 모서리 반경 | 24pt |
| 아이콘 | 24 × 24pt |
| 아이콘–텍스트 간격 | 4pt |
| 배경 | white |
| 그림자 | black 6%, blur 20pt, y -4pt |

## Items & States

| 탭 | 기본 아이콘 | 선택 아이콘 | 기본 텍스트 | 선택 텍스트 |
| --- | --- | --- | --- | --- |
| 운세 | `navi_lucky_off` | `navi_lucky_on` | caption3Medium / gray500 | caption3SemiBold / gray975 |
| 토닥이 | `navi_ai_off` | `navi_ai_on` | caption3Medium / gray500 | caption3SemiBold / gray975 |
| 행운 액션 | `navi_action_off` | `navi_action_on` | caption3Medium / gray500 | caption3SemiBold / gray975 |
| 마이 | `navi_my_off` | `navi_my_on` | caption3Medium / gray500 | caption3SemiBold / gray975 |

아이콘은 선택 상태에 따라 형태도 달라지므로 template tint가 아닌 원본 SVG 색상으로 렌더링합니다.
