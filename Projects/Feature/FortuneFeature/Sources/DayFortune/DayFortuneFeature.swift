import ComposableArchitecture
import Foundation

@Reducer
public struct DayFortuneFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var purpose: DayFortunePurpose = .travel
        public var selectedDates: [Date] = []
        public var isCalendarPresented = false
        public var isSubmitting = false
        public var errorMessage: String?
        public var showLimitToast = false
        public var results: [DayFortuneResult] = []
        public var selectedResultID: UUID?

        public init() {}

        public var selectedResult: DayFortuneResult? {
            results.first { $0.id == selectedResultID } ?? results.first
        }

        public var canSubmit: Bool {
            (1...5).contains(selectedDates.count) && !isSubmitting
        }
    }

    public enum Action: Equatable, Sendable {
        case purposeSelected(DayFortunePurpose)
        case calendarPresented(Bool)
        case dateTapped(Date)
        case resetDatesTapped
        case datesConfirmed
        case hideToast
        case createTapped
        case response(Result<[DayFortuneResult], FortuneClientError>)
        case resultSelected(UUID)
        case resultBackTapped
        case shareTapped
        case calendarExportTapped
        case todakTapped
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case todakRequested
        }
    }

    private enum ToastCancelID { case toast }

    @Dependency(\.fortuneClient) private var fortuneClient
    @Dependency(\.date.now) private var now
    @Dependency(\.continuousClock) private var clock

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .purposeSelected(purpose):
                state.purpose = purpose
                return .none

            case let .calendarPresented(isPresented):
                state.isCalendarPresented = isPresented
                state.errorMessage = nil
                state.showLimitToast = false
                return .cancel(id: ToastCancelID.toast)

            case let .dateTapped(date):
                let calendar = Calendar.current
                let day = calendar.startOfDay(for: date)
                guard day >= calendar.startOfDay(for: now) else {
                    return .none
                }

                if let index = state.selectedDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: day) }) {
                    state.selectedDates.remove(at: index)
                    state.errorMessage = nil
                    state.showLimitToast = false
                    return .cancel(id: ToastCancelID.toast)
                } else if state.selectedDates.count >= 5 {
                    state.showLimitToast = true
                    state.errorMessage = nil
                    return .run { send in
                        try await clock.sleep(for: .seconds(2))
                        await send(.hideToast)
                    }
                    .cancellable(id: ToastCancelID.toast, cancelInFlight: true)
                } else {
                    state.selectedDates.append(day)
                    state.selectedDates.sort()
                    state.errorMessage = nil
                    state.showLimitToast = false
                    return .cancel(id: ToastCancelID.toast)
                }

            case .resetDatesTapped:
                state.selectedDates.removeAll()
                state.errorMessage = nil
                state.showLimitToast = false
                return .cancel(id: ToastCancelID.toast)

            case .hideToast:
                state.showLimitToast = false
                return .none

            case .datesConfirmed:
                guard !state.selectedDates.isEmpty else {
                    state.errorMessage = "후보 날짜를 1개 이상 선택해주세요."
                    return .none
                }
                state.isCalendarPresented = false
                return .none

            case .createTapped:
                guard state.canSubmit else { return .none }
                state.isSubmitting = true
                state.errorMessage = nil
                let purpose = state.purpose
                let dates = state.selectedDates
                return .run { send in
                    do {
                        await send(.response(.success(try await fortuneClient.createDayFortunes(purpose, dates))))
                    } catch let error as FortuneClientError {
                        await send(.response(.failure(error)))
                    } catch {
                        await send(.response(.failure(.transport)))
                    }
                }

            case let .response(.success(results)):
                state.isSubmitting = false
                state.results = Array(results.sorted { $0.score > $1.score }.prefix(3))
                state.selectedResultID = state.results.first?.id
                return .none

            case let .response(.failure(error)):
                state.isSubmitting = false
                state.errorMessage = error.userMessage
                return .none

            case let .resultSelected(resultID):
                state.selectedResultID = resultID
                return .none

            case .resultBackTapped:
                state.results = []
                state.selectedResultID = nil
                return .none

            case .todakTapped:
                return .send(.delegate(.todakRequested))

            case .shareTapped, .calendarExportTapped, .delegate:
                return .none
            }
        }
    }
}
