import Foundation

public struct FortuneHomeContent: Equatable, Sendable {
    public let dailyFortuneID: UUID
    public let fortuneDate: Date
    public let score: Int
    public let scoreDescription: String?
    public let title: String
    public let categoryScores: [FortuneCategoryScore]

    public init(
        dailyFortuneID: UUID,
        fortuneDate: Date,
        score: Int,
        scoreDescription: String? = nil,
        title: String,
        categoryScores: [FortuneCategoryScore]
    ) {
        self.dailyFortuneID = dailyFortuneID
        self.fortuneDate = fortuneDate
        self.score = score
        self.scoreDescription = scoreDescription
        self.title = title
        self.categoryScores = categoryScores
    }
}

public struct FortuneCategoryScore: Equatable, Sendable {
    public let category: FortuneCategory
    public let score: Int

    public init(category: FortuneCategory, score: Int) {
        self.category = category
        self.score = score
    }
}
