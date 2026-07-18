---
name: feature-networking
description: Feature에서 서버 API 호출을 추가하거나 {Feature}Client, DTO, TCA 의존성, NetworkCore 기반 Live 구현, App 조립 및 네트워크 테스트 대역을 설계·구현할 때 적용합니다.
---

# Feature 네트워킹 규칙

## 의존성 경계

다음 흐름을 유지한다.

```text
Feature Reducer -> {Feature}Client -> HTTPClient -> HTTPClient.Transport -> URLSession
```

- Reducer는 `HTTPClient`, `Endpoint`, `HTTPClientError`를 직접 사용하지 않고 Feature 전용 Client 계약에만 의존한다.
- Feature 전용 Client 계약과 TCA 의존성 등록은 해당 Feature의 `Implementation` 타겟에 둔다.
- Live 구현에서만 `NetworkCore`를 import하고 `HTTPClient`를 사용한다.
- DTO는 Live 구현 가까이에 `internal` 또는 `private`으로 두고 도메인 모델이나 View 상태로 변환해 반환한다.
- `Interface` 타겟은 `NetworkCore`, `Model`, TCA에 의존하지 않으며 DTO나 네트워크 구현 세부사항을 노출하지 않는다.
- 공통 HTTP API 자체를 변경해야 하면 `network-core-development` 스킬도 함께 적용한다.

## 명칭과 역할

- Feature 전용 호출 계약은 `FortuneClient`, `AuthClient`처럼 `{Feature}Client`로 명명한다.
- `DomainClient`, `Manager`, 의미가 불분명한 범용 `Service` 명칭을 사용하지 않는다.
- 여러 데이터 소스를 조합하는 저장소 추상화가 실제로 필요할 때만 `Repository`를 사용한다.
- 여러 Client를 엮는 유스케이스 오케스트레이션이 필요할 때만 `Service`를 사용한다.

## 조립

- `App`에서 base URL, 인증, decoder를 반영한 `HTTPClient`를 한 번 구성한다.
- Feature `Implementation`은 App이 접근할 수 있는 `FeatureClient.live(httpClient:)` 같은 명시적인 `public` 조립 진입점을 제공한다.
- `App`이 동일한 `HTTPClient`를 각 Feature Client에 주입한다.
- `DependencyKey.liveValue` 안에서 `HTTPClient`를 새로 만들거나 Feature마다 base URL, 인증, decoder를 중복 구성하지 않는다.
- 토큰 갱신, 재시도, 로깅 같은 공통 정책을 Feature마다 중복 구현하지 않고, 요구가 확정되면 `NetworkCore`에서 확장한다.

## 오류와 테스트

- UI 동작이 달라지는 오류만 Feature 수준 오류로 변환하고, 원본 HTTP 상세를 Reducer 분기에 노출하지 않는다.
- Reducer 테스트에서는 `HTTPClient`가 아니라 Feature Client를 교체해 상태 전이와 Effect를 검증한다.
- Live Client의 요청·매핑을 검증할 때는 `HTTPClient.Transport` 클로저를 주입하고, `MockURLSession`이나 커스텀 `URLProtocol`을 새로 만들지 않는다.
- `NetworkCore`가 이미 보장하는 HTTP 동작을 Feature 테스트에서 중복 검증하지 않는다.
- 변경 후 `./scripts/lint.sh`, 관련 Feature 테스트, `./scripts/sync-and-validate.sh`를 실행한다.
