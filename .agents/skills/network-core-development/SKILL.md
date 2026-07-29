---
name: network-core-development
description: Projects/Core/NetworkCore의 HTTPClient, Endpoint, HTTPClientError, Transport 등 범용 HTTP 계층 자체를 구현·수정하거나 공통 네트워크 정책과 테스트를 변경할 때 적용합니다.
---

# NetworkCore 개발 규칙

## 책임 경계

- `NetworkCore`에는 URL 요청 생성, 전송, 응답 검증, 디코딩, 공통 오류처럼 도메인과 무관한 HTTP 책임만 둔다.
- 특정 Feature의 API 메서드, DTO, 도메인 모델, TCA `DependencyKey`를 추가하지 않는다.
- Feature 작업을 선행한다는 이유로 사용처가 확정되지 않은 도메인 Client를 미리 만들지 않는다.
- `Core`에서 `Feature` 또는 `App`을 참조하지 않는다. 공통 타입이 필요하면 계층 규칙에 따라 하위 `Model` 또는 `Utils`만 의존한다.

## 구현 원칙

- 범용 요청 실행 타입은 `HTTPClient`, 공통 오류는 `HTTPClientError`, 전송 추상화는 `HTTPClient.Transport`로 명명한다.
- 실제 전송은 `URLSession.data(for:)`를 사용하고 취소가 상위 호출자까지 전파되게 유지한다.
- `HTTPClient`와 스트리밍 클라이언트가 함께 사용하는 base URL, 기본 헤더, `Endpoint` 변환은 내부 `URLRequestBuilder`에서 조립한다.
- 인증, 로깅, 재시도 같은 공통 정책은 여러 Feature에서 공유할 요구가 확인될 때만 `NetworkCore`에 둔다.
- 테스트 대역은 `HTTPClient.Transport` 클로저로 주입한다. `MockURLSession`이나 `URLProtocol` 기반 대역을 새로 만들지 않는다.

## SSE 스트리밍 원칙

- SSE 전송 타입은 `SSEClient`, 원문 이벤트는 `SSEEvent`, 전송 추상화는 `SSEClient.StreamTransport`로 명명한다.
- 실제 SSE 전송은 `URLSession.bytes(for:)`와 UTF-8 라인 스트림을 사용하며, 일반 HTTP 응답처럼 전체 본문을 메모리에 모으지 않는다.
- `SSEClient`는 HTTP 성공 상태와 `text/event-stream` 미디어 타입을 검증하고 표준 `data`, `event`, `id`, `retry` 필드만 파싱한다.
- 스트림이 해제·종료되거나 소비 Task가 취소되면 전달 Task와 기반 `URLSessionDataTask`까지 취소한다. 스트림을 보관한 채 반복문만 중단하는 조기 종료는 감지할 수 없으므로 소비 Task 취소 또는 스트림 해제를 호출자 계약으로 명시한다.
- Feature DTO 변환, `[DONE]` 해석, 자동 재연결, `Last-Event-ID` 정책은 서버 명세가 확정된 Feature Client에서 담당한다.
- SSE 테스트 대역은 `SSEClient.StreamTransport`와 `StreamConnection`으로 주입하며 실제 서버나 커스텀 `URLProtocol`에 의존하지 않는다.
- 외부 사용처가 확인되지 않은 `LineStream`, `StreamConnection`, `StreamTransport`와 커스텀 전송 initializer는 테스트 주입 경계로만 사용하고 `internal`로 유지한다.

## 공개 API 문서화

- 외부 모듈이 사용하는 `public` 타입과 함수에 DocC 주석을 작성한다.
- 함수 주석에는 필요한 경우 `Parameters`, `Returns`, `Throws`를 포함한다.
- 구현 절차보다 호출자가 알아야 할 계약, 입력 제약, 오류 조건을 설명한다.

## 테스트와 검증

- NetworkCore 테스트는 Swift Testing의 `@Test`, `#expect`, `#require`를 사용한다. 새 테스트에 XCTestCase와 XCTAssert 계열 API를 추가하지 않는다.
- 요청 구성, 헤더 병합, 응답 디코딩, 빈 응답, 상태 코드, 전송 실패, 취소 전파를 `NetworkCore` 테스트에서 검증한다.
- SSE 변경 시 표준 필드 파싱, 빈 줄 이벤트 완성, 여러 `data` 필드 결합, 주석·미지원 필드 무시, 응답 미디어 타입과 취소 전파를 검증한다.
- 변경 후 다음 명령을 실행한다.

```bash
./scripts/lint.sh
mise exec -- tuist test NetworkCore
./scripts/sync-and-validate.sh
```
