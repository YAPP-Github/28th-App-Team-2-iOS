public enum Route: Equatable, Sendable {
    case login
    case onboarding
    case home
}

public enum LoginPhase: Equatable, Sendable {
    case idle
    case authenticating(SocialProvider)
    case authenticatingWithServer
    case savingSession
    case failed(LoginFailure)

    public var isLoading: Bool {
        switch self {
        case .authenticating, .authenticatingWithServer, .savingSession:
            true
        case .idle, .failed:
            false
        }
    }
}

public enum SignupPhase: Equatable, Sendable {
    case idle
    case signingUp
    case savingSession
    case failed(SignupFailure)

    public var isLoading: Bool {
        switch self {
        case .signingUp, .savingSession:
            true
        case .idle, .failed:
            false
        }
    }

    public var errorMessage: String? {
        guard case let .failed(failure) = self else { return nil }
        return failure.message
    }
}

public enum SignupFailure: Equatable, Sendable {
    case signup(AuthClientError)
    case tokenStorage

    public var message: String {
        switch self {
        case .signup(.expired):
            "가입 정보가 만료되었어요. 처음부터 다시 진행해 주세요."
        case .signup(.notConfigured):
            "서버 주소 설정이 필요해요."
        case .signup:
            "회원가입을 완료하지 못했어요. 다시 시도해 주세요."
        case .tokenStorage:
            "로그인 정보를 안전하게 저장하지 못했어요. 다시 시도해 주세요."
        }
    }
}

public enum LoginFailure: Equatable, Sendable {
    case socialLogin(SocialLoginError)
    case serverLogin(AuthClientError)
    case tokenStorage(TokenStoreError)

    public var message: String {
        switch self {
        case .socialLogin(.notConfigured):
            "로그인 설정이 아직 준비되지 않았어요. 설정 후 다시 시도해 주세요."
        case .socialLogin(.cancelled):
            "로그인이 취소되었어요."
        case .socialLogin:
            "소셜 로그인을 완료하지 못했어요. 다시 시도해 주세요."
        case .serverLogin(.expired):
            "로그인 정보가 만료되었어요. 다시 로그인해 주세요."
        case .serverLogin(.notConfigured):
            "서버 주소 설정이 필요해요."
        case .serverLogin:
            "서버와 연결하지 못했어요. 잠시 후 다시 시도해 주세요."
        case .tokenStorage:
            "로그인 정보를 안전하게 저장하지 못했어요. 다시 시도해 주세요."
        }
    }
}

public enum DebugPreview: Equatable, Sendable {
    case newMember
    case existingMember
    case signupLoading
}

public enum OnboardingStep: Equatable, Sendable {
    case terms
    case name
    case fortuneInformation
    case userStatus
}

public enum DailyRoutine: String, CaseIterable, Equatable, Sendable {
    case student
    case jobSeeking
    case employed
    case selfEmployedOrFreelance
    case homemaker
    case leaveOrRetirement

    public var title: String {
        switch self {
        case .student: "학생"
        case .jobSeeking: "취업 준비중"
        case .employed: "직장인"
        case .selfEmployedOrFreelance: "자영업 · 프리랜서"
        case .homemaker: "주부"
        case .leaveOrRetirement: "휴직 · 은퇴"
        }
    }
}

public enum RomanticRelationshipStatus: String, CaseIterable, Equatable, Sendable {
    case single
    case dating
    case married
    case divorced

    public var title: String {
        switch self {
        case .single: "솔로"
        case .dating: "연애중"
        case .married: "기혼"
        case .divorced: "돌싱"
        }
    }
}

public struct OnboardingTerm: Equatable, Identifiable, Sendable {
    // swiftlint:disable:next identifier_name
    public let id: String
    public let title: String
    public let detailURLString: String
    public let isRequired: Bool
    public var isAgreed: Bool

    public init(
        termID: String,
        title: String,
        detailURLString: String,
        isRequired: Bool,
        isAgreed: Bool = false
    ) {
        self.id = termID
        self.title = title
        self.detailURLString = detailURLString
        self.isRequired = isRequired
        self.isAgreed = isAgreed
    }

    // 서버의 약관 목록 API 계약이 확정되면 이 카탈로그를 TermsClient의 응답으로 교체한다.
    public static let defaultTerms = [
        OnboardingTerm(
            termID: "service",
            title: "서비스 이용약관 동의",
            detailURLString: "https://app.notion.com/p/3b081c67484680aca6e5ec1d463c670d?source=copy_link",
            isRequired: true
        ),
        OnboardingTerm(
            termID: "privacy",
            title: "개인정보 수집 및 이용",
            detailURLString: "https://app.notion.com/p/3b081c6748468045a408eb20d27e2342?source=copy_link",
            isRequired: true
        ),
        OnboardingTerm(
            termID: "ai-personal-information-transfer",
            title: "AI 사주 분석을 위한 개인정보 국외 이전 동의",
            detailURLString: "https://app.notion.com/p/AI-3b281c67484680aaad1bf2c384d016e1?source=copy_link",
            isRequired: true
        ),
        OnboardingTerm(
            termID: "marketing",
            title: "마케팅 정보 수신",
            detailURLString: "https://app.notion.com/p/3b281c67484680e1812acb94654fdc31?source=copy_link",
            isRequired: false
        )
    ]
}
