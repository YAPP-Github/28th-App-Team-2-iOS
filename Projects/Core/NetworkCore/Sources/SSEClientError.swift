import Foundation

/// `SSEClient`의 응답 검증과 스트림 전송 과정에서 발생하는 오류입니다.
public enum SSEClientError: Error, Sendable {
    /// URL 응답이 HTTP 응답 형식이 아닙니다.
    case invalidResponse

    /// 서버가 성공 범위를 벗어난 HTTP 상태 코드를 반환했습니다.
    ///
    /// - Parameter code: 서버가 반환한 HTTP 상태 코드입니다.
    case unacceptableStatusCode(code: Int)

    /// 응답의 미디어 타입이 `text/event-stream`이 아닙니다.
    ///
    /// - Parameter actual: 서버가 반환한 미디어 타입입니다.
    case invalidContentType(actual: String?)

    /// 스트림 전송 계층에서 오류가 발생했습니다.
    ///
    /// - Parameters:
    ///   - code: `URLError`에서 추출한 코드입니다. 다른 오류 유형이면 `nil`입니다.
    ///   - description: 원본 전송 오류의 설명입니다.
    case transportFailed(code: URLError.Code?, description: String)
}
