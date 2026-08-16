import ComposableArchitecture
import Foundation

@Reducer
public struct YearFortuneFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var selectedYear: Int
        public var isSubmitting = false
        public var errorMessage: String?
        public var result: YearFortuneResult?

        public init(selectedYear: Int = Calendar.current.component(.year, from: Date())) {
            self.selectedYear = selectedYear
        }
    }

    public enum Action: Equatable, Sendable {
        case yearSelected(Int)
        case createTapped
        case response(Result<YearFortuneResult, FortuneClientError>)
        case resultBackTapped
        case shareTapped
        case todakTapped
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case todakRequested
        }
    }

    @Dependency(\.fortuneClient) private var fortuneClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .yearSelected(year):
                state.selectedYear = year
                return .none

            case .createTapped:
                guard !state.isSubmitting else { return .none }
                state.isSubmitting = true
                state.errorMessage = nil
                let year = state.selectedYear
                return .run { send in
                    do {
                        await send(.response(.success(try await fortuneClient.createYearFortune(year))))
                    } catch let error as FortuneClientError {
                        await send(.response(.failure(error)))
                    } catch {
                        await send(.response(.failure(.transport)))
                    }
                }

            case let .response(.success(result)):
                state.isSubmitting = false
                state.result = result
                return .none

            case let .response(.failure(error)):
                state.isSubmitting = false
                state.errorMessage = error.userMessage
                return .none

            case .resultBackTapped:
                state.result = nil
                return .none

            case .todakTapped:
                return .send(.delegate(.todakRequested))

            case .shareTapped, .delegate:
                return .none
            }
        }
    }
}
