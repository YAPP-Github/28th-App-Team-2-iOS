import ComposableArchitecture
import Foundation
import NotificationFeatureInterface

@Reducer
public struct NotificationFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public enum ViewState: Equatable, Sendable {
            case idle
            case loading
            case loaded([InAppNotification])
            case failed(message: String)
        }

        public var viewState: ViewState
        public var unreadCount: Int
        public var pendingReadIDs: Set<UUID>
        /// 가장 최근 목록 요청만 상태에 반영해, 취소가 늦게 전파된 응답을 무시한다.
        public var latestFetchGeneration: Int
        public var isFetchInFlight: Bool

        public init(
            viewState: ViewState = .idle,
            unreadCount: Int = 0,
            pendingReadIDs: Set<UUID> = [],
            latestFetchGeneration: Int = 0,
            isFetchInFlight: Bool = false
        ) {
            self.viewState = viewState
            self.unreadCount = unreadCount
            self.pendingReadIDs = pendingReadIDs
            self.latestFetchGeneration = latestFetchGeneration
            self.isFetchInFlight = isFetchInFlight
        }
    }

    public enum Action: Equatable {
        case view(ViewAction)
        case notificationsResponse(Int, Result<NotificationList, NotificationClientError>)
        case markAsReadResponse(UUID, NotificationClientError?)
        case delegate(Delegate)

        public enum ViewAction: Equatable, Sendable {
            case task
            case refresh
            case retryButtonTapped
            case backButtonTapped
            case notificationTapped(UUID)
        }

        public enum Delegate: Equatable, Sendable {
            case dismissRequested
            case unreadCountUpdated(Int)
        }
    }

    private enum CancelID: Hashable {
        case fetchNotifications
        case markAsRead(UUID)
    }

    @Dependency(\.notificationClient) private var notificationClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.task):
                guard case .idle = state.viewState else { return .none }
                state.viewState = .loading
                return fetchNotificationsEffect(for: &state)

            case .view(.refresh):
                guard !state.isFetchInFlight else { return .none }
                if case .idle = state.viewState {
                    state.viewState = .loading
                } else if case .failed = state.viewState {
                    state.viewState = .loading
                }
                return fetchNotificationsEffect(for: &state)

            case .view(.retryButtonTapped):
                guard !state.isFetchInFlight else { return .none }
                state.viewState = .loading
                return fetchNotificationsEffect(for: &state)

            case .view(.backButtonTapped):
                return .send(.delegate(.dismissRequested))

            case let .notificationsResponse(generation, result):
                guard generation == state.latestFetchGeneration else { return .none }
                state.isFetchInFlight = false
                switch result {
                case let .success(list):
                    state.viewState = .loaded(list.notifications)
                    state.unreadCount = list.unreadCount
                    return .send(.delegate(.unreadCountUpdated(list.unreadCount)))

                case let .failure(error):
                    state.viewState = .failed(message: error.userMessage)
                    return .none
                }

            case let .view(.notificationTapped(notificationID)):
                guard case let .loaded(notifications) = state.viewState,
                      let notification = notifications.first(where: { $0.id == notificationID }),
                      !notification.isRead,
                      !state.pendingReadIDs.contains(notificationID)
                else {
                    return .none
                }
                state.pendingReadIDs.insert(notificationID)
                return markAsReadEffect(notificationID)

            case let .markAsReadResponse(notificationID, error):
                let wasPending = state.pendingReadIDs.remove(notificationID) != nil
                guard error == nil, wasPending else {
                    return .none
                }

                let hasAlreadyReflectedRead: Bool
                if case let .loaded(notifications) = state.viewState,
                   let notification = notifications.first(where: { $0.id == notificationID }) {
                    hasAlreadyReflectedRead = notification.isRead
                    if !notification.isRead {
                        state.viewState = .loaded(
                            notifications.map { $0.id == notificationID ? $0.markedAsRead() : $0 }
                        )
                    }
                } else {
                    // 목록 재조회가 실패했더라도, 시작 시점에 unread였던 PATCH의 성공은 반영한다.
                    hasAlreadyReflectedRead = false
                }

                if !hasAlreadyReflectedRead {
                    state.unreadCount = max(0, state.unreadCount - 1)
                }
                let fetchEffect = fetchNotificationsEffect(for: &state)
                return .concatenate(
                    .cancel(id: CancelID.fetchNotifications),
                    .send(.delegate(.unreadCountUpdated(state.unreadCount))),
                    fetchEffect
                )

            case .delegate:
                return .none
            }
        }
    }

    private func fetchNotificationsEffect(for state: inout State) -> Effect<Action> {
        state.latestFetchGeneration += 1
        state.isFetchInFlight = true
        let generation = state.latestFetchGeneration

        return .run { send in
            do {
                await send(
                    .notificationsResponse(
                        generation,
                        .success(try await notificationClient.fetchNotifications())
                    )
                )
            } catch is CancellationError {
                // 최신 조회가 앞선 요청을 취소할 때 실패 화면으로 전환하지 않는다.
            } catch let error as NotificationClientError {
                await send(.notificationsResponse(generation, .failure(error)))
            } catch {
                await send(.notificationsResponse(generation, .failure(.transport)))
            }
        }
        .cancellable(id: CancelID.fetchNotifications, cancelInFlight: true)
    }

    private func markAsReadEffect(_ notificationID: UUID) -> Effect<Action> {
        .run { send in
            do {
                try await notificationClient.markAsRead(notificationID)
                await send(.markAsReadResponse(notificationID, nil))
            } catch is CancellationError {
                // 행을 떠난 경우에도 기존 읽음 상태를 유지한다.
            } catch let error as NotificationClientError {
                await send(.markAsReadResponse(notificationID, error))
            } catch {
                await send(.markAsReadResponse(notificationID, .transport))
            }
        }
        .cancellable(id: CancelID.markAsRead(notificationID), cancelInFlight: true)
    }
}
