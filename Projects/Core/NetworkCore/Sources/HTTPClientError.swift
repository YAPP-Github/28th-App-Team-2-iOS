import Foundation

/// `HTTPClient`의 요청 생성, 전송, 응답 검증과 디코딩 과정에서 발생하는 오류입니다.
public enum HTTPClientError: Error, Sendable {
    /// 기준 URL과 Endpoint 경로로 유효한 URL을 만들 수 없습니다.
    case invalidURL

    /// URL 응답이 HTTP 응답 형식이 아닙니다.
    case invalidResponse

    /// 서버가 성공 범위를 벗어난 HTTP 상태 코드를 반환했습니다.
    ///
    /// - Parameters:
    ///   - code: 서버가 반환한 HTTP 상태 코드입니다.
    ///   - data: 에러 응답의 원본 본문입니다.
    case unacceptableStatusCode(code: Int, data: Data)

    /// 디코딩할 응답 본문이 비어 있습니다.
    case emptyResponse

    /// 응답 본문을 요청한 타입으로 디코딩하지 못했습니다.
    case decodingFailed(DecodingError)

    /// 요청 전송 계층에서 오류가 발생했습니다.
    ///
    /// - Parameters:
    ///   - code: `URLError`에서 추출한 코드입니다. 다른 오류 유형이면 `nil`입니다.
    ///   - description: 원본 전송 오류의 설명입니다.
    case transportFailed(code: URLError.Code?, description: String)
}
