import ComposableArchitecture
import Foundation

@Reducer
public struct FortuneFeature {
    @Reducer
    public enum Path {
        case report(FortuneReportFeature)
        case compatibility(CompatibilityFeature)
        case dayFortune(DayFortuneFeature)
        case yearFortune(YearFortuneFeature)
    }

    public init() {}

    @ObservableState
    public struct State: Equatable {
        public enum ViewState: Equatable, Sendable {
            case loading
            case loaded(FortuneHomeContent)
            case failed(message: String)
        }

        public var viewState: ViewState
        public var unreadNotificationCount: Int
        public var path = StackState<Path.State>()
        @Presents public var categoryDetail: FortuneCategoryDetailFeature.State?

        public init(
            viewState: ViewState = .loading,
            unreadNotificationCount: Int = 0
        ) {
            self.viewState = viewState
            self.unreadNotificationCount = unreadNotificationCount
        }

        public var isShowingDetail: Bool {
            !path.isEmpty
        }
    }

    public enum Action: Equatable {
        case view(ViewAction)
        case unreadNotificationCountUpdated(Int)
        case todayFortuneResponse(Result<FortuneHomeContent, FortuneClientError>)
        case path(StackActionOf<Path>)
        case delegate(Delegate)
        case categoryDetail(PresentationAction<FortuneCategoryDetailFeature.Action>)

        public enum ViewAction: Equatable, Sendable {
            case task
            case retryButtonTapped
            case requestCancelled
            case notificationButtonTapped
            case fortuneReportButtonTapped
            case fortuneCategoryTapped(FortuneCategory)
            case fortuneReadingTapped(FortuneReading)
            case luckyActionBannerTapped
        }

        public enum Delegate: Equatable, Sendable {
            case todakRequested
            case luckyActionTabRequested
            case luckyActionPushRequested
            case notificationsRequested
            case myPageRequested
            case myInfoEditRequested
        }
    }

    private enum CancelID {
        case fetchTodayFortune
    }

    @Dependency(\.fortuneClient) var fortuneClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.task):
                guard case .loading = state.viewState else {
                    return .none
                }
                return fetchTodayFortuneEffect()

            case .view(.retryButtonTapped):
                state.viewState = .loading
                return fetchTodayFortuneEffect()

            case .view(.requestCancelled):
                return .cancel(id: CancelID.fetchTodayFortune)

            case let .todayFortuneResponse(result):
                switch result {
                case let .success(content):
                    state.viewState = .loaded(content)
                    return .none

                case let .failure(error):
                    if case .loading = state.viewState {
                        state.viewState = .failed(message: message(for: error))
                    }
                    return .none
                }

            case .view(.notificationButtonTapped):
                return .send(.delegate(.notificationsRequested))

            case let .unreadNotificationCountUpdated(count):
                state.unreadNotificationCount = count
                return .none

            case .view(.fortuneReportButtonTapped):
                routeToFortuneReport(state: &state, selectedCategory: nil)
                return .none

            case let .view(.fortuneCategoryTapped(category)):
                if case let .loaded(content) = state.viewState,
                   let item = content.categoryScores.first(where: { $0.category == category }) {
                    state.categoryDetail = .init(
                        luckActionID: item.luckActionID,
                        category: item.category,
                        categoryScores: content.categoryScores
                    )
                }
                return .none

            case let .view(.fortuneReadingTapped(reading)):
                switch reading {
                case .compatibility:
                    state.path.append(.compatibility(.init()))
                case .dateSelection:
                    state.path.append(.dayFortune(.init()))
                case .yearly:
                    state.path.append(.yearFortune(.init()))
                }
                return .none

            case .view(.luckyActionBannerTapped):
                return .send(.delegate(.luckyActionTabRequested))

            case .path(.element(id: _, action: .report(.delegate(.todakRequested)))),
                 .path(.element(id: _, action: .compatibility(.delegate(.todakRequested)))),
                 .path(.element(id: _, action: .dayFortune(.delegate(.todakRequested)))),
                 .path(.element(id: _, action: .yearFortune(.delegate(.todakRequested)))),
                 .categoryDetail(.presented(.delegate(.todakRequested))):
                return .send(.delegate(.todakRequested))

            case .path(.element(id: _, action: .report(.delegate(.luckyActionRequested)))),
                 .categoryDetail(.presented(.delegate(.luckyActionRequested))):
                return .send(.delegate(.luckyActionPushRequested))

            case .path(.element(id: _, action: .compatibility(.delegate(.myInfoEditRequested)))):
                return .send(.delegate(.myInfoEditRequested))

            case .path, .delegate, .categoryDetail:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$categoryDetail, action: \.categoryDetail) {
            FortuneCategoryDetailFeature()
        }
    }

    private func fetchTodayFortuneEffect() -> Effect<Action> {
        .run { send in
            do {
                let content = try await fortuneClient.fetchToday()
                await send(.todayFortuneResponse(.success(content)))
            } catch is CancellationError {
                // 취소된 작업은 실패 UI로 전환하지 않는다.
            } catch let error as FortuneClientError {
                await send(.todayFortuneResponse(.failure(error)))
            } catch {
                await send(.todayFortuneResponse(.failure(.transport)))
            }
        }
        .cancellable(id: CancelID.fetchTodayFortune, cancelInFlight: true)
    }

    private func routeToFortuneReport(
        state: inout State,
        selectedCategory: FortuneCategory?
    ) {
        guard case let .loaded(content) = state.viewState else {
            return
        }

        state.path.append(
            .report(
                .init(
                    dailyFortuneID: content.dailyFortuneID,
                    selectedCategory: selectedCategory
                )
            )
        )
    }

    private func message(for error: FortuneClientError) -> String {
        switch error {
        case .notConfigured:
            return "운세 서비스를 사용할 수 없어요."
        case .server, .httpStatus:
            return "운세 정보를 불러오지 못했어요."
        case .invalidResponse, .unsupportedCategory:
            return "운세 정보를 읽는 중 오류가 발생했어요."
        case .transport:
            return "네트워크 연결 상태를 확인해주세요."
        }
    }
}

extension FortuneFeature.Path.State: Equatable {}
extension FortuneFeature.Path.Action: Equatable {}
