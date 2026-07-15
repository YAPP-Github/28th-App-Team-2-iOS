---
name: network-core
description: NetworkCore의 HTTPClient, Endpoint, HTTPClientError를 구현·수정하거나 Feature에서 도메인 Client로 네트워크 호출을 감싸는 구조를 설계할 때 적용합니다.
---

# NetworkCore 사용 규칙

## 책임 경계

- `NetworkCore`에는 HTTP 요청 생성, 전송, 상태 코드 검증, 응답 디코딩 같은 범용 네트워크 기능만 둔다.
- `NetworkCore`에 특정 Feature의 API 메서드, DTO, 도메인 모델, TCA `DependencyKey`를 두지 않는다.
- NetworkCore만 구현하는 작업에서는 미래 사용 예시를 위해 도메인 Client를 미리 만들지 않는다.
- Core에서 Feature 또는 App을 import하지 않는다. 하위 Core가 꼭 필요할 때만 `Model`, `Utils` 단방향 의존을 허용한다.

## 명칭

- 범용 HTTP 실행기는 `HTTPClient`, 공통 오류는 `HTTPClientError`로 명명한다.
- 완성된 `URLRequest`를 전송하고 `(Data, URLResponse)`를 반환하는 경계는 `HTTPClient.Transport`로 명명한다.
- Feature 의존성은 실제 기능명을 사용해 `FortuneClient`, `MyPageClient`처럼 명명한다.
- 의미가 불분명한 `DomainClient`, `Manager`, 단순 우회 목적의 `Service` 명칭을 사용하지 않는다.
- 로컬 저장소와 원격 API 등 여러 데이터 소스를 조합할 때만 `Repository`를 고려한다.
- 여러 의존성을 조합해 업무 규칙을 수행할 때만 `Service`를 고려한다.

## Feature에서 사용

다음 의존 방향을 유지한다.

```text
Feature Reducer -> {Feature}Client -> HTTPClient -> Transport -> URLSession
```

- Reducer는 `{Feature}Client`의 도메인 동작에만 의존하고 `HTTPClient`, `Endpoint`, `HTTPClientError`를 직접 사용하지 않는다.
- `{Feature}Client` 계약과 TCA 의존성 등록은 해당 Feature Implementation에 둔다.
- 실제 서버와 통신하는 운영 구현(Live implementation) 파일만 `NetworkCore`를 import하고 Endpoint 생성, DTO 디코딩, 도메인 모델 변환을 담당하게 한다.
- 서버 요청·응답 DTO는 해당 운영 구현 근처에 `internal` 또는 `private`으로 두고 Reducer State에 노출하지 않는다.
- UI 동작이 달라지는 오류만 Feature 수준 오류로 변환한다. 원본 HTTP 상세를 Reducer 분기에 누출하지 않는다.
- Feature Interface 타겟은 NetworkCore, Model, TCA에 의존하지 않는 기존 규칙을 유지한다.

## 조립

- App에서 base URL, 인증 헤더, 디코더 정책을 적용한 `HTTPClient`를 한 번 구성한다.
- 운영 환경의 `Transport`에는 `URLSession.data(for:)`를 연결한다.
- 단위 테스트에서는 원하는 응답이나 오류를 반환하는 Transport 클로저를 주입한다.
- Transport 테스트 클로저가 Stub 또는 Spy 역할을 하므로 별도의 `MockURLSession`이나 커스텀 `URLProtocol`을 만들지 않는다.
- 같은 `HTTPClient`를 각 `{Feature}Client.live(httpClient:)` 생성에 주입한다.
- Feature마다 base URL이나 인증 정책이 중복된 `HTTPClient`를 생성하지 않는다.
- 토큰 저장, 갱신, retry, 로깅 정책은 Feature Client마다 중복 구현하지 말고 공통 정책이 확정된 뒤 NetworkCore에서 확장한다.

## 공개 API 문서

- NetworkCore의 모든 `public` 타입과 함수에 `///` DocC 주석을 작성한다.
- 함수에는 해당되는 `- Parameters:`, `- Returns:`, `- Throws:`를 작성하여 Xcode Quick Help에서 계약을 확인할 수 있게 한다.
- 주석은 구현 방식보다 호출자가 알아야 할 입력, 출력, 우선순위, 오류 조건을 설명한다.

## 검증

- NetworkCore 단위 테스트에서 요청 생성, 헤더 우선순위, 성공 디코딩, 빈 응답, 상태 코드, 전송, 취소를 검증한다.
- Feature Reducer 테스트에서는 `{Feature}Client`만 대체하고 HTTP 계층을 재검증하지 않는다.
- 변경 후 `./scripts/lint.sh`, `mise exec -- tuist test NetworkCore`, `./scripts/sync-and-validate.sh`를 실행한다.
