import Foundation

public struct FortuneDetailContent: Equatable, Sendable {
    public let dailyFortuneID: UUID
    public let fortuneDate: Date
    public let score: Int
    public let title: String
    public let content: String
    public let luckyItems: [String]
    public let cautionaryItems: [String]
    public let categoryScores: [FortuneCategoryScore]

    public init(
        dailyFortuneID: UUID,
        fortuneDate: Date,
        score: Int,
        title: String,
        content: String,
        luckyItems: [String],
        cautionaryItems: [String],
        categoryScores: [FortuneCategoryScore]
    ) {
        self.dailyFortuneID = dailyFortuneID
        self.fortuneDate = fortuneDate
        self.score = score
        self.title = title
        self.content = content
        self.luckyItems = luckyItems
        self.cautionaryItems = cautionaryItems
        self.categoryScores = categoryScores
    }
}
