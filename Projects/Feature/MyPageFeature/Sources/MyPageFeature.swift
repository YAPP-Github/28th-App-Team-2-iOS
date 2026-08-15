import ComposableArchitecture
import Foundation
import Model
import Utils

// swiftlint:disable file_length
@Reducer
// swiftlint:disable:next type_body_length
public struct MyPageFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var dashboard: MyPageDashboard?
        public var phase: Phase = .idle
        public var edit: EditState?
        public var sajuDetail: SajuDetailState?
        public var notificationSettings: NotificationSettingsState?
        public var appSettings: AppSettingsState?
        public var withdrawal: WithdrawalState?
        public var isLogoutConfirmationPresented = false
        public var logoutError: MyPageClientError?
        public var sajuManagement: SajuManagementState?
        public var isPendingEditPresentation: Bool = false
        public var isEditDashboardLoading = false

        public init() {}
    }

    @ObservableState
    public struct NotificationSettingsState: Equatable {
        public var settings: NotificationSettings?
        public var pickerHour = 8
        public var pickerMinute = 0
        public var isTimePickerPresented = false
        public var isPermissionAlertPresented = false
        public var error: MyPageClientError?

        public init() {}
    }

    @ObservableState
    public struct SajuManagementState: Equatable {
        public var partners: [MyPagePartnerSaju] = []
        public var isLoading = true
        public var form: PartnerFormState?
        public var expandedMenuLinkID: String?
        public var toastMessage: String?
        public var error: MyPageClientError?

        public init() {}
    }

    @ObservableState
    public struct PartnerFormState: Equatable {
        public let editingLinkID: String?
        public var name = ""
        public var gender: Gender?
        public var calendar: BirthDateCalendar?
        public var birthDate: BirthDate?
        public var birthTime: BirthTimePeriod?
        public var isBirthTimeUnknown = false
        public var relationshipCode = "LOVER"
        public var isSaving = false

        var relationship: Relationship {
            get {
                switch relationshipCode {
                case "FRIEND": .friend
                case "COLLEAGUE": .colleague
                default: .partner
                }
            }
            set {
                relationshipCode = switch newValue {
                case .partner: "LOVER"
                case .friend: "FRIEND"
                case .colleague: "COLLEAGUE"
                }
            }
        }

        init(partner: MyPagePartnerSaju? = nil) {
            editingLinkID = partner?.linkID
            name = partner?.name ?? ""
            gender = partner?.gender == "FEMALE" ? .female : (partner == nil ? nil : .male)
            calendar = partner?.calendarType == "LUNAR" ? .lunar : (partner == nil ? nil : .solar)
            birthDate = partner.flatMap(Self.birthDate)
            birthTime = partner.flatMap { BirthTimePeriod(apiValue: $0.birthTime) }
            isBirthTimeUnknown = partner?.isTimeUnknown ?? false
            relationshipCode = partner?.relationshipCode ?? "LOVER"
        }

        var nameValidationMessage: String? {
            guard !name.isEmpty else { return nil }
            if name.count > 10 { return "이름은 최대 10글자까지 가능해요." }
            if name.unicodeScalars.contains(where: { !$0.isKoreanNameScalar }) {
                return "이름은 한글만 가능해요."
            }
            return nil
        }

        var isValid: Bool {
            !name.isEmpty && nameValidationMessage == nil && gender != nil && calendar != nil
                && birthDate != nil && (birthTime != nil || isBirthTimeUnknown)
                && BirthDatePolicy.validateNotInFuture(for: birthDate, asOf: Date()) == nil
        }

        func input() -> MyPagePartnerSajuInput? {
            guard let gender, let calendar, let birthDate else { return nil }
            return MyPagePartnerSajuInput(
                name: name,
                gender: gender == .female ? "FEMALE" : "MALE",
                calendarType: calendar == .lunar ? "LUNAR" : "SOLAR",
                birthDate: String(format: "%04d-%02d-%02d", birthDate.year, birthDate.month, birthDate.day),
                birthTime: isBirthTimeUnknown ? "UNKNOWN" : birthTime?.apiValue ?? "UNKNOWN",
                relationshipType: relationshipCode
            )
        }

        private static func birthDate(_ partner: MyPagePartnerSaju) -> BirthDate? {
            let values = partner.birthDate.split(separator: "-").compactMap { Int($0) }
            guard values.count == 3 else { return nil }
            return BirthDate(year: values[0], month: values[1], day: values[2])
        }
    }

    public enum HelpSheet: String, Equatable, Hashable, Identifiable {
        case sajuOriginal
        case ohaeng

        // swiftlint:disable:next identifier_name
        public var id: Self { self }
    }

    @ObservableState
    public struct EditState: Equatable {
        public var gender: Gender?
        public var calendar: BirthDateCalendar?
        public var birthDate: BirthDate?
        public var birthTime: BirthTimePeriod?
        public var isBirthTimeUnknown: Bool
        public var job: MyPageJob?
        public var relationshipStatus: MyPageRelationshipStatus?
        public var isStatusSheetPresented = false
        public var isSaving = false
        public var error: MyPageClientError?

        init(profile: MyPageProfile) {
            gender = profile.gender == "FEMALE" ? .female : .male
            calendar = profile.calendarType == "LUNAR" ? .lunar : .solar
            birthDate = Self.birthDate(profile.birthDate)
            birthTime = BirthTimePeriod(apiValue: profile.birthTime)
            isBirthTimeUnknown = profile.isTimeUnknown
            job = MyPageJob(apiValue: profile.job)
            relationshipStatus = MyPageRelationshipStatus(apiValue: profile.relationshipStatus)
        }

        var isValid: Bool {
            gender != nil && calendar != nil && birthDate != nil
                && BirthDatePolicy.validateNotInFuture(for: birthDate, asOf: Date()) == nil
                && BirthDatePolicy.validateMinimumAge(for: birthDate, asOf: Date()) == nil
                && (birthTime != nil || isBirthTimeUnknown)
                && job != nil && relationshipStatus != nil
        }

        private static func birthDate(_ value: String) -> BirthDate? {
            BirthDate(yyyyMMdd: value)
        }
    }

    public enum Phase: Equatable {
        case idle
        case loading
        case loaded
        case failed(MyPageClientError)
    }

    public enum Action: Equatable {
        case task
        case retryButtonTapped
        case dashboardResponse(Result<MyPageDashboard, MyPageClientError>)
        case presentEdit
        case discardPendingEditPresentation
        case editButtonTapped
        case editDismissButtonTapped
        case editGenderChanged(Gender?)
        case editCalendarChanged(BirthDateCalendar?)
        case editBirthDateChanged(BirthDate?)
        case editBirthTimeChanged(BirthTimePeriod?)
        case editBirthTimeUnknownChanged(Bool)
        case editStatusSheetPresented(Bool)
        case editJobChanged(MyPageJob)
        case editRelationshipStatusChanged(MyPageRelationshipStatus)
        case editSaveButtonTapped
        case editResponse(Result<MyPageDashboard, MyPageClientError>)
        case calendarButtonTapped
        case sajuDetailDismissButtonTapped
        case sajuDetailHelpButtonTapped(HelpSheet)
        case sajuDetailHelpSheetDismissed
        case sajuManagementButtonTapped
        case sajuManagementTask
        case sajuManagementResponse(Result<[MyPagePartnerSaju], MyPageClientError>)
        case sajuManagementDismissButtonTapped
        case partnerAddButtonTapped
        case partnerMenuButtonTapped(String)
        case partnerEditButtonTapped(String)
        case partnerDeleteButtonTapped(String)
        case partnerFormDismissButtonTapped
        case partnerNameChanged(String)
        case partnerGenderChanged(Gender?)
        case partnerCalendarChanged(BirthDateCalendar?)
        case partnerBirthDateChanged(BirthDate?)
        case partnerBirthTimeChanged(BirthTimePeriod?)
        case partnerBirthTimeUnknownChanged(Bool)
        case partnerRelationshipChanged(Relationship)
        case partnerSaveButtonTapped
        case partnerSaveResponse(Result<Bool, MyPageClientError>)
        case partnerDeleteResponse(Result<Bool, MyPageClientError>)
        case partnerToastDismissed
        case menuItemTapped(MenuItem)
        case notificationSettingsTask
        case notificationSettingsResponse(Result<NotificationSettings, MyPageClientError>)
        case notificationSettingsDismissButtonTapped
        case notificationSettingToggleChanged(NotificationSettingToggle, Bool)
        case notificationToggleAuthorizationStatus(
            NotificationSettingToggle,
            NotificationAuthorizationStatus
        )
        case notificationToggleAuthorizationRequest(
            NotificationSettingToggle,
            NotificationAuthorizationStatus
        )
        case notificationSettingsUpdateResponse(Result<NotificationSettings, MyPageClientError>)
        case notificationSettingsTimeButtonTapped
        case notificationSettingsTimePickerPresented(Bool)
        case notificationSettingsPickerHourChanged(Int)
        case notificationSettingsPickerMinuteChanged(Int)
        case notificationSettingsTimeSaveButtonTapped
        case notificationPermissionAlertPresented(Bool)
        case accountSettings(AccountSettingsAction)
        case delegate(Delegate)
    }

    public enum MenuItem: Equatable, CaseIterable {
        case sajuManagement
        case notificationSettings
        case appSettings
        case inquiry
        case logout
    }

    @Dependency(\.myPageClient) var myPageClient
    @Dependency(\.notificationSettingsAuthorizationClient)
    var notificationSettingsAuthorizationClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            if let effect = reduceAccountSettings(&state, action: action) {
                return effect
            }

            if let effect = reduceNotificationSettings(&state, action: action) {
                return effect
            }

            switch action {
            case .task:
                guard state.dashboard == nil, state.phase != .loading else { return .none }
                state.phase = .loading
                state.isEditDashboardLoading = false
                return .run { send in
                    await send(
                        .dashboardResponse(
                            Result { try await myPageClient.loadDashboard() }
                                .mapError(MyPageClientError.init)
                        )
                    )
                }
                .cancellable(id: CancelID.loadDashboard, cancelInFlight: true)

            case .retryButtonTapped:
                guard state.phase != .loading else { return .none }
                state.phase = .loading
                state.isEditDashboardLoading = false
                return .run { send in
                    await send(
                        .dashboardResponse(
                            Result { try await myPageClient.loadDashboard() }
                                .mapError(MyPageClientError.init)
                        )
                    )
                }
                .cancellable(id: CancelID.loadDashboard, cancelInFlight: true)

            case let .dashboardResponse(.success(dashboard)):
                state.dashboard = dashboard
                state.phase = .loaded
                state.isEditDashboardLoading = false
                if state.isPendingEditPresentation {
                    state.isPendingEditPresentation = false
                    state.edit = EditState(profile: dashboard.profile)
                }
                return .none

            case let .dashboardResponse(.failure(error)):
                state.phase = .failed(error)
                state.isPendingEditPresentation = false
                state.isEditDashboardLoading = false
                return .none

            case .presentEdit:
                if let profile = state.dashboard?.profile {
                    state.edit = EditState(profile: profile)
                    state.isPendingEditPresentation = false
                    return .none
                } else {
                    state.isPendingEditPresentation = true
                    guard state.phase != .loading else { return .none }
                    state.phase = .loading
                    state.isEditDashboardLoading = true
                    return .run { send in
                        await send(
                            .dashboardResponse(
                                Result { try await myPageClient.loadDashboard() }
                                    .mapError(MyPageClientError.init)
                            )
                        )
                    }
                    .cancellable(id: CancelID.loadDashboardForEdit, cancelInFlight: true)
                }

            case .discardPendingEditPresentation:
                let wasEditDashboardLoading = state.isEditDashboardLoading
                state.edit = nil
                state.isPendingEditPresentation = false
                state.isEditDashboardLoading = false
                if wasEditDashboardLoading {
                    state.phase = state.dashboard == nil ? .idle : .loaded
                }
                return .cancel(id: CancelID.loadDashboardForEdit)

            case .editButtonTapped:
                guard let profile = state.dashboard?.profile else { return .none }
                state.edit = EditState(profile: profile)
                return .none

            case .editDismissButtonTapped:
                state.edit = nil
                state.isPendingEditPresentation = false
                return .none

            case let .editGenderChanged(value):
                state.edit?.gender = value
                return .none

            case let .editCalendarChanged(value):
                state.edit?.calendar = value
                return .none

            case let .editBirthDateChanged(value):
                state.edit?.birthDate = value
                return .none

            case let .editBirthTimeChanged(value):
                state.edit?.birthTime = value
                if value != nil { state.edit?.isBirthTimeUnknown = false }
                return .none

            case let .editBirthTimeUnknownChanged(value):
                state.edit?.isBirthTimeUnknown = value
                if value { state.edit?.birthTime = nil }
                return .none

            case let .editStatusSheetPresented(isPresented):
                state.edit?.isStatusSheetPresented = isPresented
                return .none

            case let .editJobChanged(value):
                state.edit?.job = value
                return .none

            case let .editRelationshipStatusChanged(value):
                state.edit?.relationshipStatus = value
                return .none

            case .editSaveButtonTapped:
                guard let edit = state.edit,
                      edit.isValid,
                      !edit.isSaving,
                      let gender = edit.gender,
                      let calendar = edit.calendar,
                      let birthDate = edit.birthDate,
                      let job = edit.job,
                      let relationshipStatus = edit.relationshipStatus else { return .none }
                state.edit?.isSaving = true
                state.edit?.error = nil
                let update = MyPageProfileUpdate(
                    gender: gender.apiValue,
                    calendarType: calendar.apiValue,
                    birthDate: String(format: "%04d-%02d-%02d", birthDate.year, birthDate.month, birthDate.day),
                    birthTime: edit.isBirthTimeUnknown ? "UNKNOWN" : edit.birthTime?.apiValue ?? "UNKNOWN",
                    job: job.apiValue,
                    relationshipStatus: relationshipStatus.apiValue
                )
                return .run { send in
                    await send(
                        .editResponse(
                            Result { try await myPageClient.updateProfile(update) }
                                .mapError(MyPageClientError.init)
                        )
                    )
                }
                .cancellable(id: CancelID.updateProfile, cancelInFlight: true)

            case let .editResponse(.success(dashboard)):
                state.dashboard = dashboard
                state.phase = .loaded
                state.edit = nil
                return .send(.delegate(.profileUpdated))

            case let .editResponse(.failure(error)):
                state.edit?.isSaving = false
                state.edit?.error = error
                return .none

            case .calendarButtonTapped:
                guard state.dashboard != nil else { return .none }
                state.sajuDetail = SajuDetailState()
                return .none

            case .sajuDetailDismissButtonTapped:
                state.sajuDetail = nil
                return .none

            case let .sajuDetailHelpButtonTapped(helpSheet):
                state.sajuDetail?.helpSheet = helpSheet
                return .none

            case .sajuDetailHelpSheetDismissed:
                state.sajuDetail?.helpSheet = nil
                return .none

            case .sajuManagementButtonTapped, .menuItemTapped(.sajuManagement):
                state.sajuManagement = SajuManagementState()
                return .none

            case .sajuManagementTask:
                guard state.sajuManagement?.isLoading == true else { return .none }
                return .run { send in
                    await send(
                        .sajuManagementResponse(
                            Result { try await myPageClient.loadPartners() }
                                .mapError(MyPageClientError.init)
                        )
                    )
                }

            case let .sajuManagementResponse(.success(partners)):
                state.sajuManagement?.partners = partners
                state.sajuManagement?.isLoading = false
                return .none

            case let .sajuManagementResponse(.failure(error)):
                state.sajuManagement?.isLoading = false
                state.sajuManagement?.error = error
                return .none

            case .sajuManagementDismissButtonTapped:
                state.sajuManagement = nil
                return .none

            case .partnerAddButtonTapped:
                guard let management = state.sajuManagement else { return .none }
                if management.partners.count >= 10 {
                    state.sajuManagement?.toastMessage = "상대방 사주 정보는 최대 10개까지 저장할 수 있어요."
                } else {
                    state.sajuManagement?.form = PartnerFormState()
                }
                return .none

            case let .partnerMenuButtonTapped(linkID):
                let isExpanded = state.sajuManagement?.expandedMenuLinkID == linkID
                state.sajuManagement?.expandedMenuLinkID = isExpanded ? nil : linkID
                return .none

            case let .partnerEditButtonTapped(linkID):
                guard let partner = state.sajuManagement?.partners.first(
                    where: { $0.linkID == linkID }
                ) else {
                    return .none
                }
                state.sajuManagement?.expandedMenuLinkID = nil
                state.sajuManagement?.form = PartnerFormState(partner: partner)
                return .none

            case let .partnerDeleteButtonTapped(linkID):
                state.sajuManagement?.expandedMenuLinkID = nil
                return .run { send in
                    await send(
                        .partnerDeleteResponse(
                            Result { try await myPageClient.deletePartner(linkID) }
                                .map { true }
                                .mapError(MyPageClientError.init)
                        )
                    )
                }

            case .partnerFormDismissButtonTapped:
                state.sajuManagement?.form = nil
                return .none

            case let .partnerNameChanged(name):
                state.sajuManagement?.form?.name = name
                return .none

            case let .partnerGenderChanged(value):
                state.sajuManagement?.form?.gender = value
                return .none

            case let .partnerCalendarChanged(value):
                state.sajuManagement?.form?.calendar = value
                return .none

            case let .partnerBirthDateChanged(value):
                state.sajuManagement?.form?.birthDate = value
                return .none
            case let .partnerBirthTimeChanged(value):
                state.sajuManagement?.form?.birthTime = value
                if value != nil { state.sajuManagement?.form?.isBirthTimeUnknown = false }
                return .none
            case let .partnerBirthTimeUnknownChanged(value):
                state.sajuManagement?.form?.isBirthTimeUnknown = value
                if value { state.sajuManagement?.form?.birthTime = nil }
                return .none
            case let .partnerRelationshipChanged(relationship):
                state.sajuManagement?.form?.relationship = relationship
                return .none

            case .partnerSaveButtonTapped:
                guard let form = state.sajuManagement?.form,
                      form.isValid,
                      !form.isSaving,
                      let input = form.input() else {
                    return .none
                }
                state.sajuManagement?.form?.isSaving = true
                return .run { send in
                    await send(
                        .partnerSaveResponse(
                            Result {
                                if let linkID = form.editingLinkID {
                                    try await myPageClient.updatePartner(linkID, input)
                                } else {
                                    try await myPageClient.registerPartner(input)
                                }
                            }
                            .map { true }
                            .mapError(MyPageClientError.init)
                        )
                    )
                }

            case .partnerSaveResponse(.success), .partnerDeleteResponse(.success):
                state.sajuManagement?.form = nil
                state.sajuManagement?.isLoading = true
                return .send(.sajuManagementTask)

            case let .partnerSaveResponse(.failure(error)), let .partnerDeleteResponse(.failure(error)):
                state.sajuManagement?.form?.isSaving = false
                state.sajuManagement?.error = error
                return .none

            case .partnerToastDismissed:
                state.sajuManagement?.toastMessage = nil
                return .none

            case .menuItemTapped:
                return .none

            default:
                return .none
            }
        }
    }
}

extension MyPageFeature {
    @ObservableState
    public struct SajuDetailState: Equatable {
        public var helpSheet: HelpSheet?

        public init() {}
    }
}

private enum CancelID {
    case loadDashboard
    case loadDashboardForEdit
    case updateProfile
}

public enum MyPageJob: String, CaseIterable, Equatable, Sendable {
    case student = "STUDENT"
    case jobSeeking = "JOBSEEKER"
    case employed = "WORKER"
    case freelance = "FREELANCER"
    case homemaker = "HOMEMAKER"
    case leaveOrRetirement = "LEAVER"

    var title: String {
        switch self {
        case .student: "학생"
        case .jobSeeking: "취업 준비중"
        case .employed: "직장인"
        case .freelance: "자영업 · 프리랜서"
        case .homemaker: "주부"
        case .leaveOrRetirement: "휴직 · 은퇴"
        }
    }

    var apiValue: String { rawValue }

    init?(apiValue: String) { self.init(rawValue: apiValue) }
}

public enum MyPageRelationshipStatus: String, CaseIterable, Equatable, Sendable {
    case single = "SOLO"
    case dating = "DATING"
    case married = "MARRY"
    case divorced = "REMARRY"

    var title: String {
        switch self {
        case .single: "솔로"
        case .dating: "연애중"
        case .married: "기혼"
        case .divorced: "돌싱"
        }
    }

    var apiValue: String { rawValue }

    init?(apiValue: String) { self.init(rawValue: apiValue) }
}
