import ComposableArchitecture

extension MyPageFeature {
    @ObservableState
    public struct AppSettingsState: Equatable {
        public init() {}
    }

    @ObservableState
    public struct WithdrawalState: Equatable {
        public var reason: WithdrawalReason?
        public var draftReason: WithdrawalReason?
        public var detail = ""
        public var isReasonSheetPresented = false
        public var isAgreementPresented = false
        public var isAgreed = false
        public var isConfirmationPresented = false
        public var isSubmitting = false
        public var error: MyPageClientError?

        public init() {}

        var canProceed: Bool {
            guard let reason else { return false }
            return !reason.requiresDetail || !detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    public enum Delegate: Equatable {
        case sessionEnded
    }

    public enum AccountSettingsAction: Equatable {
        case dismissAppSettings
        case withdrawalTapped
        case dismissWithdrawal
        case reasonFieldTapped
        case reasonSheetPresented(Bool)
        case draftReasonSelected(WithdrawalReason)
        case saveReason
        case clearReason
        case detailChanged(String)
        case nextTapped
        case dismissAgreement
        case agreementChanged(Bool)
        case confirmationPresented(Bool)
        case confirmWithdrawal
        case withdrawalResponse(Result<Bool, MyPageClientError>)
        case dismissWithdrawalError
        case logoutConfirmationPresented(Bool)
        case confirmLogout
        case logoutResponse(Result<Bool, MyPageClientError>)
        case dismissLogoutError
    }

    // 앱 설정, 로그아웃, 회원 탈퇴 흐름을 메인 마이페이지 상태와 분리해 관리한다.
    // swiftlint:disable:next cyclomatic_complexity
    func reduceAccountSettings(
        _ state: inout State,
        action: Action
    ) -> Effect<Action>? {
        switch action {
        case .menuItemTapped(.appSettings):
            state.appSettings = AppSettingsState()
            return .none

        case .accountSettings(.dismissAppSettings):
            state.appSettings = nil
            return .none

        case .accountSettings(.withdrawalTapped):
            guard state.appSettings != nil else { return .none }
            state.withdrawal = WithdrawalState()
            return .none

        case .accountSettings(.dismissWithdrawal):
            state.withdrawal = nil
            return .none

        case .accountSettings(.reasonFieldTapped):
            guard state.withdrawal != nil else { return .none }
            let selectedReason = state.withdrawal?.reason ?? WithdrawalReason.allCases.first
            state.withdrawal?.draftReason = selectedReason
            state.withdrawal?.isReasonSheetPresented = true
            return .none

        case let .accountSettings(.reasonSheetPresented(isPresented)):
            state.withdrawal?.isReasonSheetPresented = isPresented
            return .none

        case let .accountSettings(.draftReasonSelected(reason)):
            state.withdrawal?.draftReason = reason
            return .none

        case .accountSettings(.saveReason):
            guard let draftReason = state.withdrawal?.draftReason else { return .none }
            state.withdrawal?.reason = draftReason
            state.withdrawal?.isReasonSheetPresented = false
            return .none

        case .accountSettings(.clearReason):
            state.withdrawal?.reason = nil
            state.withdrawal?.draftReason = nil
            state.withdrawal?.detail = ""
            return .none

        case let .accountSettings(.detailChanged(detail)):
            state.withdrawal?.detail = String(detail.prefix(200))
            return .none

        case .accountSettings(.nextTapped):
            guard state.withdrawal?.canProceed == true else { return .none }
            state.withdrawal?.isAgreementPresented = true
            return .none

        case .accountSettings(.dismissAgreement):
            state.withdrawal?.isAgreementPresented = false
            return .none

        case let .accountSettings(.agreementChanged(isAgreed)):
            state.withdrawal?.isAgreed = isAgreed
            return .none

        case let .accountSettings(.confirmationPresented(isPresented)):
            state.withdrawal?.isConfirmationPresented = isPresented
            return .none

        case .accountSettings(.confirmWithdrawal):
            guard let withdrawal = state.withdrawal,
                  let reason = withdrawal.reason,
                  withdrawal.isAgreed,
                  withdrawal.canProceed,
                  !withdrawal.isSubmitting else { return .none }
            state.withdrawal?.isConfirmationPresented = false
            state.withdrawal?.isSubmitting = true
            state.withdrawal?.error = nil
            let request = WithdrawalRequest(reason: reason, detail: withdrawal.detail)
            return .run { send in
                await send(
                    .accountSettings(.withdrawalResponse(
                        Result {
                            try await myPageClient.withdraw(request)
                            return true
                        }
                            .mapError(MyPageClientError.init)
                    ))
                )
            }
            .cancellable(id: AccountSettingsCancelID.withdraw, cancelInFlight: true)

        case .accountSettings(.withdrawalResponse(.success)):
            state.withdrawal?.isSubmitting = false
            return .send(.delegate(.sessionEnded))

        case let .accountSettings(.withdrawalResponse(.failure(error))):
            state.withdrawal?.isSubmitting = false
            state.withdrawal?.error = error
            return .none

        case .accountSettings(.dismissWithdrawalError):
            state.withdrawal?.error = nil
            return .none

        case .menuItemTapped(.logout):
            state.isLogoutConfirmationPresented = true
            state.logoutError = nil
            return .none

        case let .accountSettings(.logoutConfirmationPresented(isPresented)):
            state.isLogoutConfirmationPresented = isPresented
            return .none

        case .accountSettings(.confirmLogout):
            state.isLogoutConfirmationPresented = false
            state.logoutError = nil
            return .run { send in
                await send(
                    .accountSettings(.logoutResponse(
                        Result {
                            try await myPageClient.logout()
                            return true
                        }
                            .mapError(MyPageClientError.init)
                    ))
                )
            }
            .cancellable(id: AccountSettingsCancelID.logout, cancelInFlight: true)

        case .accountSettings(.logoutResponse(.success)):
            return .send(.delegate(.sessionEnded))

        case let .accountSettings(.logoutResponse(.failure(error))):
            state.logoutError = error
            return .none

        case .accountSettings(.dismissLogoutError):
            state.logoutError = nil
            return .none

        default:
            return nil
        }
    }
}

private enum AccountSettingsCancelID {
    case withdraw
    case logout
}
