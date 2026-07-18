/// HTTP 요청에 사용할 표준 메서드입니다.
public enum HTTPMethod: String, Sendable {
    /// 리소스를 조회합니다.
    case get = "GET"

    /// 새 리소스 또는 작업을 요청합니다.
    case post = "POST"

    /// 리소스 전체를 교체합니다.
    case put = "PUT"

    /// 리소스 일부를 수정합니다.
    case patch = "PATCH"

    /// 리소스를 삭제합니다.
    case delete = "DELETE"
}
