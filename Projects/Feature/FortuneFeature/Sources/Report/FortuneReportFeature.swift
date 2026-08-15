import ComposableArchitecture
import Foundation

@Reducer
public struct FortuneReportFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        public enum ViewState: Equatable, Sendable {
            case loading
            case loaded(FortuneDetailContent)
            case failed(String)
        }

        public let dailyFortuneID: UUID
        public var pendingCategory: FortuneCategory?
        public var viewState: ViewState = .loading
        @Presents public var categoryDetail: FortuneCategoryDetailFeature.State?

        public init(
            dailyFortuneID: UUID,
            selectedCategory: FortuneCategory? = nil
        ) {
            self.dailyFortuneID = dailyFortuneID
            self.pendingCategory = selectedCategory
        }
    }

    public enum Action: Equatable, Sendable {
        case task
        case response(Result<FortuneDetailContent, FortuneClientError>)
        case retryTapped
        case categoryTapped(FortuneCategoryScore)
        case todakTapped
        case luckyActionTapped
        case categoryDetail(PresentationAction<FortuneCategoryDetailFeature.Action>)
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case todakRequested
            case luckyActionRequested
        }
    }

    @Dependency(\.fortuneClient) private var fortuneClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task, .retryTapped:
                state.viewState = .loading
                let dailyFortuneID = state.dailyFortuneID
                return .run { send in
                    do {
                        await send(.response(.success(try await fortuneClient.fetchDetail(dailyFortuneID))))
                    } catch is CancellationError {
                        return
                    } catch let error as FortuneClientError {
                        await send(.response(.failure(error)))
                    } catch {
                        await send(.response(.failure(.transport)))
                    }
                }

            case let .response(.success(content)):
                state.viewState = .loaded(content)
                if let category = state.pendingCategory,
                   let item = content.categoryScores.first(where: { $0.category == category }) {
                    state.categoryDetail = .init(
                        luckActionID: item.luckActionID,
                        category: item.category,
                        categoryScores: content.categoryScores
                    )
                }
                state.pendingCategory = nil
                return .none

            case let .response(.failure(error)):
                state.viewState = .failed(error.userMessage)
                return .none

            case let .categoryTapped(item):
                state.categoryDetail = .init(
                    luckActionID: item.luckActionID,
                    category: item.category,
                    categoryScores: loadedContent(from: state)?.categoryScores ?? []
                )
                return .none

            case .todakTapped,
                 .categoryDetail(.presented(.delegate(.todakRequested))):
                return .send(.delegate(.todakRequested))

            case .luckyActionTapped,
                 .categoryDetail(.presented(.delegate(.luckyActionRequested))):
                return .send(.delegate(.luckyActionRequested))

            case .categoryDetail, .delegate:
                return .none
            }
        }
        .ifLet(\.$categoryDetail, action: \.categoryDetail) {
            FortuneCategoryDetailFeature()
        }
    }

    private func loadedContent(from state: State) -> FortuneDetailContent? {
        guard case let .loaded(content) = state.viewState else { return nil }
        return content
    }
}
