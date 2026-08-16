import LuckyActionFeatureInterface

public struct LuckyActionCompletion: Equatable, Sendable {
    public let category: LuckyActionCategory

    public init(category: LuckyActionCategory) {
        self.category = category
    }
}
