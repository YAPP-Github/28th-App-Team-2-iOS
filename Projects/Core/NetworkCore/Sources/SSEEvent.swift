// SSE 표준 필드 이름을 공개 API에 그대로 사용합니다.
// swiftlint:disable identifier_name

/// SSE 스트림에서 빈 줄로 구분된 하나의 표준 필드 블록입니다.
public struct SSEEvent: Equatable, Sendable {
    /// 하나 이상의 `data` 필드를 줄바꿈으로 결합한 값입니다.
    ///
    /// `id` 또는 `retry`만 포함된 제어 블록에서는 `nil`입니다.
    /// 값이 없는 `data` 필드가 포함된 이벤트는 빈 문자열입니다.
    public let data: String?

    /// 이벤트 블록의 `event` 필드입니다.
    public let event: String?

    /// 이벤트 블록의 `id` 필드입니다.
    ///
    /// 자동 재연결과 `Last-Event-ID` 상태 관리는 이 타입의 책임이 아닙니다.
    public let id: String?

    /// 이벤트 블록의 유효한 `retry` 밀리초 값입니다.
    ///
    /// 자동 재연결 정책은 이 타입의 책임이 아닙니다.
    public let retry: Int?

    /// SSE 이벤트를 생성합니다.
    ///
    /// - Parameters:
    ///   - data: 하나 이상의 `data` 필드를 줄바꿈으로 결합한 값입니다.
    ///     제어 블록에서는 `nil`입니다.
    ///   - event: 이벤트 블록의 `event` 필드입니다.
    ///   - id: 이벤트 블록의 `id` 필드입니다.
    ///   - retry: 이벤트 블록의 유효한 `retry` 밀리초 값입니다.
    public init(
        data: String?,
        event: String? = nil,
        id: String? = nil,
        retry: Int? = nil
    ) {
        self.data = data
        self.event = event
        self.id = id
        self.retry = retry
    }
}

// swiftlint:enable identifier_name
