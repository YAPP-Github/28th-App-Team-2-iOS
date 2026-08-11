# View Composition and TCA

## 화면 루트와 섹션

- 화면 루트는 Store 상태를 읽고 의미 있는 섹션 View를 조립하는 역할에 집중한다.
- header, hero, list, footer처럼 독립된 의미 영역은 별도 `View` 타입으로 분리한다.
- 긴 `body`를 감추기 위한 `private var section: some View` 또는 `@ViewBuilder` helper는 별도 invalidation 경계를 만들지 않는다. 섹션 분리가 필요하면 구체적인 `View` 타입을 사용한다.
- 한두 modifier만 가진 장식 조각까지 타입으로 기계적으로 분리하지 않는다.
- 별도 파일은 타입의 크기, 반복 사용, 독립 리뷰 필요성을 기준으로 결정한다. 파일 하나당 타입 하나를 강제하지 않는다.

## 입력 범위

- 하위 View에는 실제로 표시하거나 하위에 전달하는 값과 Action closure만 전달한다.
- 큰 Feature State나 서버 payload 전체를 제목 하나만 표시하는 View에 넘기지 않는다.
- 화면 View가 API DTO를 직접 해석하지 않도록 Feature domain 또는 render model 경계를 둔다.
- View `init`은 입력 저장만 수행한다. 디코딩, 파일 접근, 네트워크, 큰 정렬·필터, formatter 생성은 넣지 않는다.

## 상태 소유권

- 서버 데이터, 화면 단계, validation, navigation처럼 동작과 테스트에 영향을 주는 상태는 TCA State가 소유한다.
- TCA State와 같은 값을 View `@State`에 복제하지 않는다.
- 포커스나 드래그 진행처럼 View 수명에만 속하고 비즈니스 동작과 무관한 상태는 로컬 상태로 둘 수 있다.
- derived collection의 계산 비용이 데이터 크기에 비례하면 `body` 또는 `ForEach` 인자에서 매번 sort·filter하지 않고 reducer/domain에서 준비한다. 작은 고정 목록의 단순 변환은 과도하게 추상화하지 않는다.

## 컬렉션 identity

- 서버 ID, domain enum, 영속적으로 저장한 UUID처럼 항목과 함께 이동하는 안정적인 ID를 사용한다.
- `indices`, `offset`, 매번 새로 생성한 UUID, 수정 가능한 표시 문자열을 identity로 사용하지 않는다.
- 자연스러운 identity가 있으면 `Identifiable`을 선호한다.
- lazy container의 row는 구체적인 단일 root View를 사용하고 `AnyView`로 타입을 지우지 않는다.

## Feature 분리 판단

다음이 모두 없는 시각 섹션은 순수 View로 유지한다.

- 독립적인 상태 수명
- 독립 effect 또는 dependency
- 독립 navigation
- 부모와 별도로 테스트할 reducer 동작

다른 화면에서도 보인다는 이유만으로 Reducer나 Interface를 만들지 않는다. 재사용되는 것은 View인지, domain인지, DesignSystem 계약인지 먼저 구분한다.
