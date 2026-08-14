import ComposableArchitecture
import Foundation

@Reducer
public struct FortuneCategoryDetailFeature {
    @ObservableState
    public struct State: Equatable, Sendable, Identifiable {
        public enum ViewState: Equatable, Sendable {
            case loading
            case loaded(LuckActionDetail)
            case failed(String)
        }

        // Identifiable 프로토콜이 요구하는 이름이 린트 정책보다 짧으므로 예외 처리한다.
        // swiftlint:disable:next identifier_name
        public var id: UUID { luckActionID }
        public let luckActionID: UUID
        public let category: FortuneCategory
        public let categoryScores: [FortuneCategoryScore]
        public var viewState: ViewState = .loading

        public init(
            luckActionID: UUID,
            category: FortuneCategory,
            categoryScores: [FortuneCategoryScore] = []
        ) {
            self.luckActionID = luckActionID
            self.category = category
            self.categoryScores = categoryScores
        }
    }

    public enum Action: Equatable, Sendable {
        case task
        case response(Result<LuckActionDetail, FortuneClientError>)
        case retryTapped
        case luckyActionTapped
        case todakTapped
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case luckyActionRequested
            case todakRequested
        }
    }

    @Dependency(\.fortuneClient) private var fortuneClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task, .retryTapped:
                state.viewState = .loading
                let luckActionID = state.luckActionID
                return .run { send in
                    do {
                        await send(.response(.success(try await fortuneClient.fetchLuckAction(luckActionID))))
                    } catch is CancellationError {
                        return
                    } catch let error as FortuneClientError {
                        await send(.response(.failure(error)))
                    } catch {
                        await send(.response(.failure(.transport)))
                    }
                }

            case let .response(.success(detail)):
                state.viewState = .loaded(detail)
                return .none

            case let .response(.failure(error)):
                state.viewState = .failed(error.userMessage)
                return .none

            case .luckyActionTapped:
                return .send(.delegate(.luckyActionRequested))
                
            case .todakTapped:
                return .send(.delegate(.todakRequested))

            case .delegate:
                return .none
            }
        }
    }
}

extension FortuneClientError {
    var userMessage: String {
        switch self {
        case .notConfigured:
            "서비스를 사용할 수 없어요."
        case .server, .httpStatus, .invalidResponse, .unsupportedCategory:
            "정보를 불러오지 못했어요."
        case .transport:
            "네트워크 연결 상태를 확인해주세요."
        }
    }
}
