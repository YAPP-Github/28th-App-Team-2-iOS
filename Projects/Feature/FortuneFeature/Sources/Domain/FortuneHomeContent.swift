import Foundation

public struct FortuneHomeContent: Equatable, Sendable {
    public let dailyFortuneID: UUID
    public let fortuneDate: Date
    public let score: Double
    public let displayScore: Int
    public let moodLevel: FortuneMoodLevel
    public let scoreDescription: String?
    public let title: String
    public let categoryScores: [FortuneCategoryScore]

    public init(
        dailyFortuneID: UUID,
        fortuneDate: Date,
        score: Double,
        scoreDescription: String? = nil,
        title: String,
        categoryScores: [FortuneCategoryScore]
    ) {
        self.dailyFortuneID = dailyFortuneID
        self.fortuneDate = fortuneDate
        self.score = score
        self.displayScore = score.isFinite
            ? Int(min(max(score.rounded(), 0), 100))
            : 0
        self.moodLevel = FortuneMoodLevel(score: score)
        self.scoreDescription = scoreDescription
        self.title = title
        self.categoryScores = categoryScores
    }
}

public struct FortuneCategoryScore: Equatable, Sendable {
    public let luckActionID: UUID
    public let category: FortuneCategory
    public let score: Int

    public init(
        luckActionID: UUID,
        category: FortuneCategory,
        score: Int
    ) {
        self.luckActionID = luckActionID
        self.category = category
        self.score = score
    }
}
