# UI Verification

## 정적 검증

변경 범위에 맞는 최소 검증을 실행한다.

| 변경 범위 | 필수 검증 |
| --- | --- |
| SwiftUI View만 변경 | 변경 Swift 파일 SwiftLint, 소유 target 빌드 |
| Feature reducer·State·Action 변경 | 관련 TestStore 테스트 추가·실행 |
| Feature 단독 화면 변경 | FeatureExample이 있으면 빌드·실행하여 isolated rendering 확인 |
| App의 tab·navigation·safe area 조립 변경 | App target 빌드·실행하여 integration rendering 확인 |
| workspace 재생성이 필요한 설정 변경 | `mise exec -- tuist generate --no-open` |
| `Projects/App`, `Projects/Feature`, `Projects/Core`, `Tuist`, `Project.swift`, `docs/graph.dot` 변경 | 최종 `./scripts/sync-and-validate.sh` |

DesignSystem 소스 또는 리소스도 변경했다면 `design-system-development`의 추가 테스트와 asset 검증을 따른다.

## 실제 화면 검증

화면 전체·스크롤·이미지·텍스트 레이아웃을 변경했다면 최소 다음 폭 범주를 확인한다. 국소적인 색상·아이콘 교체는 영향 범위에 맞게 줄일 수 있다.

- 작은 지원 화면
- Figma 기준 화면과 가까운 화면
- 더 큰 화면

각 화면에서 다음을 확인한다.

- 좌우 edge와 의도한 horizontal inset
- 긴 텍스트와 여러 줄 텍스트의 잘림·겹침
- 이미지 비율, crop, 빈 배경 영역
- 흰 sheet나 card가 부모 너비를 넘지 않는지
- header와 status bar, bottom content와 tab bar 관계
- 최초 화면과 스크롤 후 화면
- 각 Button의 실제 탭 범위와 pressed surface
- loading·loaded·failed 상태가 있다면 각 상태

## 최신 바이너리 확인

UI 변경 후 검증은 다음 상태를 구분한다.

1. 소스가 수정됨
2. 새 바이너리 빌드가 성공함
3. 새 바이너리가 대상 simulator에 설치됨
4. 이전 앱 프로세스가 종료됨
5. 새 앱 프로세스가 실행됨
6. 사용자가 보는 simulator pane이 새 화면을 표시함

빌드 성공, PID 존재, UI hierarchy 접근 중 하나만으로 최신 화면이라고 결론 내리지 않는다. 마지막에는 새 실행의 screenshot과 UI hierarchy를 함께 확인한다. simulator·pane을 유지하라는 요청이 있으면 검증 후 임의 종료하지 않는다.

## 판정 방식

- Figma의 모든 좌표를 pixel 단위로 일치시키는 것을 목표로 하지 않는다.
- 디자인 의도, 컴포넌트 규격, 정렬, 간격, 비율, 상호작용 범위를 비교한다.
- Debug layout inspector가 있으면 App 또는 Example root에 이미 설치된 진입점을 사용하고 Feature View에 중복 설치하지 않는다.
- 검증에서 발견한 회귀와 요구사항 밖의 관찰을 구분해 보고한다.
