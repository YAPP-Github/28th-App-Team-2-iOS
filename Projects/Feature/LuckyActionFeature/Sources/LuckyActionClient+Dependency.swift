import ComposableArchitecture
import LuckyActionFeatureInterface

extension LuckyActionClient: @retroactive DependencyKey {
    public static let liveValue = LuckyActionClient.unavailable
    public static let testValue = LuckyActionClient.unavailable
}

public extension DependencyValues {
    var luckyActionClient: LuckyActionClient {
        get { self[LuckyActionClient.self] }
        set { self[LuckyActionClient.self] = newValue }
    }
}
