import Foundation

public enum WithdrawalReason: String, CaseIterable, Equatable, Sendable, Identifiable {
    case contentInappropriate = "CONTENT_INAPPROPRIATE"
    case chatbotUnsatisfactory = "CHATBOT_UNSATISFACTORY"
    case lowUsage = "LOW_USAGE"
    case missingFeature = "MISSING_FEATURE"
    case paymentInconvenience = "PAYMENT_INCONVENIENCE"
    case privacyConcern = "PRIVACY_CONCERN"
    case frequentErrors = "FREQUENT_ERRORS"
    case switchingService = "SWITCHING_SERVICE"
    case etc = "ETC"

    // swiftlint:disable:next identifier_name
    public var id: Self { self }

    public var title: String {
        switch self {
        case .contentInappropriate:
            "사주·운세 결과가 아쉬워요"
        case .chatbotUnsatisfactory:
            "토닥이 답변이 아쉬워요"
        case .lowUsage:
            "자주 쓰지 않아요"
        case .missingFeature:
            "원하는 기능이 없어요"
        case .paymentInconvenience:
            "유료 결제/과금 방식이 불편해요"
        case .privacyConcern:
            "개인정보 제공이 불안해요"
        case .frequentErrors:
            "오류가 잦아요 (버그, 앱이 느려요)"
        case .switchingService:
            "다른 앱/서비스로 이동해요"
        case .etc:
            "기타"
        }
    }

    var requiresDetail: Bool { self == .etc }
}

public struct WithdrawalRequest: Equatable, Sendable {
    public let reason: WithdrawalReason
    public let detail: String

    public init(reason: WithdrawalReason, detail: String) {
        self.reason = reason
        self.detail = detail
    }
}
