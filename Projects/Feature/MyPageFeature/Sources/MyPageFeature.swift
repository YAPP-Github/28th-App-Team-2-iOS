import ComposableArchitecture
import Foundation
import Model

@Reducer
public struct MyPageFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var dashboard: MyPageDashboard?
        public var phase: Phase = .idle
        public var edit: EditState?

        public init() {}
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
                && (birthTime != nil || isBirthTimeUnknown)
                && job != nil && relationshipStatus != nil
        }

        private static func birthDate(_ value: String) -> BirthDate? {
            let components = value.split(separator: "-").compactMap { Int($0) }
            guard components.count == 3 else { return nil }
            return BirthDate(year: components[0], month: components[1], day: components[2])
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
        case menuItemTapped(MenuItem)
    }

    public enum MenuItem: Equatable, CaseIterable {
        case sajuManagement
        case notificationSettings
        case appSettings
        case inquiry
        case logout
    }

    @Dependency(\.myPageClient) private var myPageClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                guard state.dashboard == nil, state.phase != .loading else { return .none }
                state.phase = .loading
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
                return .none

            case let .dashboardResponse(.failure(error)):
                state.phase = .failed(error)
                return .none

            case .editButtonTapped:
                guard let profile = state.dashboard?.profile else { return .none }
                state.edit = EditState(profile: profile)
                return .none

            case .editDismissButtonTapped:
                state.edit = nil
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
                return .none

            case let .editResponse(.failure(error)):
                state.edit?.isSaving = false
                state.edit?.error = error
                return .none

            case .calendarButtonTapped, .menuItemTapped:
                return .none
            }
        }
    }
}

private enum CancelID {
    case loadDashboard
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

private extension Gender {
    var apiValue: String { self == .female ? "FEMALE" : "MALE" }
}

private extension BirthDateCalendar {
    var apiValue: String { self == .lunar ? "LUNAR" : "SOLAR" }
}
