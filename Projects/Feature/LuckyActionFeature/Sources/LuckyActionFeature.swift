import ComposableArchitecture
import Foundation
import LuckyActionFeatureInterface

@Reducer
public struct LuckyActionFeature {
    public enum PresentationStyle: Equatable, Sendable {
        case tab
        case pushed
    }

    @ObservableState
    public struct State: Equatable {
        public enum ViewState: Equatable, Sendable {
            case loading
            case loaded([LuckyAction])
            case failed(message: String)
        }

        public var presentationStyle: PresentationStyle
        public var today: Date
        public var selectedDate: Date
        public var viewState: ViewState
        public var pendingActionIDs: Set<UUID>
        public var completion: LuckyActionCompletion?
        public var completionQueue: [LuckyActionCompletion]

        public init(
            presentationStyle: PresentationStyle = .tab,
            selectedDate: Date? = nil,
            today: Date = .now,
            viewState: ViewState = .loading,
            pendingActionIDs: Set<UUID> = [],
            completion: LuckyActionCompletion? = nil,
            completionQueue: [LuckyActionCompletion] = []
        ) {
            self.presentationStyle = presentationStyle
            let today = LuckyActionDate.startOfActionDay(for: today)
            self.today = today
            self.selectedDate = selectedDate.map(LuckyActionDate.startOfActionDay(for:)) ?? today
            self.viewState = viewState
            self.pendingActionIDs = pendingActionIDs
            self.completion = completion
            self.completionQueue = completionQueue
        }

        public var canMoveToNextDate: Bool {
            selectedDate < today
        }

        public var canToggleActions: Bool {
            selectedDate == today
        }
    }

    public enum Action: Equatable {
        case view(ViewAction)
        case actionsResponse(Date, Result<[LuckyAction], LuckyActionClientError>)
        case achievementResponse(UUID, Result<LuckyAction, LuckyActionClientError>)
        case delegate(Delegate)

        public enum ViewAction: Equatable, Sendable {
            case task
            case retryButtonTapped
            case previousDateTapped
            case nextDateTapped
            case actionToggled(UUID)
            case completionDismissButtonTapped
            case completionAutoDismissed
            case backButtonTapped
        }

        public enum Delegate: Equatable, Sendable {
            case dismissRequested
        }
    }

    private enum CancelID {
        case fetchActions
        case completion
    }

    @Dependency(\.continuousClock) private var clock
    @Dependency(\.date.now) private var now
    @Dependency(\.luckyActionClient) private var luckyActionClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.task):
                let today = currentActionDay
                state.today = today
                state.selectedDate = today
                state.viewState = .loading
                return fetchActionsEffect(for: today, today: today)

            case .view(.retryButtonTapped):
                state.today = currentActionDay
                state.viewState = .loading
                return fetchActionsEffect(for: state.selectedDate, today: state.today)

            case .view(.previousDateTapped):
                state.today = currentActionDay
                let previousDate = LuckyActionDate.addingDays(-1, to: state.selectedDate)
                state.selectedDate = previousDate
                state.viewState = .loading
                return fetchActionsEffect(for: previousDate, today: state.today)

            case .view(.nextDateTapped):
                state.today = currentActionDay
                guard state.canMoveToNextDate else { return .none }
                let nextDate = LuckyActionDate.addingDays(1, to: state.selectedDate)
                state.selectedDate = nextDate
                state.viewState = .loading
                return fetchActionsEffect(for: nextDate, today: state.today)

            case let .actionsResponse(date, .success(actions)):
                guard date == state.selectedDate else { return .none }
                state.viewState = .loaded(actions.sorted { $0.category.sortOrder < $1.category.sortOrder })
                return .none

            case let .actionsResponse(date, .failure(error)):
                guard date == state.selectedDate else { return .none }
                state.viewState = .failed(message: error.userMessage)
                return .none

            case let .view(.actionToggled(actionID)):
                state.today = currentActionDay
                guard case let .loaded(actions) = state.viewState,
                      state.canToggleActions,
                      actions.contains(where: { $0.id == actionID }),
                      !state.pendingActionIDs.contains(actionID)
                else {
                    return .none
                }
                state.pendingActionIDs.insert(actionID)
                return toggleAchievementEffect(actionID: actionID)

            case let .achievementResponse(actionID, .success(updatedAction)):
                state.pendingActionIDs.remove(actionID)
                guard case var .loaded(actions) = state.viewState,
                      let index = actions.firstIndex(where: { $0.id == updatedAction.id })
                else {
                    return .none
                }
                actions[index] = updatedAction
                state.viewState = .loaded(actions)

                guard updatedAction.isAchieved else { return .none }
                let completion = LuckyActionCompletion(category: updatedAction.category)
                if state.completion == nil {
                    state.completion = completion
                    return completionDismissEffect()
                }
                state.completionQueue.append(completion)
                return .none

            case let .achievementResponse(actionID, .failure(_)):
                state.pendingActionIDs.remove(actionID)
                return .none

            case .view(.completionDismissButtonTapped), .view(.completionAutoDismissed):
                state.completion = state.completionQueue.isEmpty ? nil : state.completionQueue.removeFirst()
                guard state.completion != nil else { return .cancel(id: CancelID.completion) }
                return completionDismissEffect()

            case .view(.backButtonTapped):
                return .send(.delegate(.dismissRequested))

            case .delegate:
                return .none
            }
        }
    }

    private func fetchActionsEffect(for date: Date, today: Date) -> Effect<Action> {
        .run { send in
            do {
                let actions = if date == today {
                    try await luckyActionClient.fetchToday()
                } else {
                    try await luckyActionClient.fetchByDate(date)
                }
                await send(.actionsResponse(date, .success(actions)))
            } catch is CancellationError {
                // 화면 이탈로 취소된 요청은 실패 UI로 전환하지 않는다.
            } catch let error as LuckyActionClientError {
                await send(.actionsResponse(date, .failure(error)))
            } catch {
                await send(.actionsResponse(date, .failure(.transport)))
            }
        }
        .cancellable(id: CancelID.fetchActions, cancelInFlight: true)
    }

    private func toggleAchievementEffect(actionID: UUID) -> Effect<Action> {
        .run { send in
            do {
                await send(
                    .achievementResponse(
                        actionID,
                        .success(try await luckyActionClient.toggleAchievement(actionID))
                    )
                )
            } catch let error as LuckyActionClientError {
                await send(.achievementResponse(actionID, .failure(error)))
            } catch {
                await send(.achievementResponse(actionID, .failure(.transport)))
            }
        }
    }

    private func completionDismissEffect() -> Effect<Action> {
        .run { send in
            try await clock.sleep(for: .seconds(2))
            await send(.view(.completionAutoDismissed))
        }
        .cancellable(id: CancelID.completion, cancelInFlight: true)
    }

    private var currentActionDay: Date {
        LuckyActionDate.startOfActionDay(for: now)
    }

}

private enum LuckyActionDate {
    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return calendar
    }

    static func startOfActionDay(for date: Date) -> Date {
        let calendar = Self.calendar
        let day = calendar.startOfDay(for: date)
        let hour = calendar.component(.hour, from: date)
        return hour < 6 ? addingDays(-1, to: day) : day
    }

    static func addingDays(_ value: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: value, to: date) ?? date
    }
}
