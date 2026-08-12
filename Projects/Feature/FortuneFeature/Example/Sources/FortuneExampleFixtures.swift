import Foundation
import FortuneFeature

extension FortuneHomeContent {
    static func example(score: Double) -> Self {
        Self(
            dailyFortuneID: UUID(uuidString: "A0B1C2D3-E4F5-4678-9012-3456789ABCDE")!,
            fortuneDate: Date(timeIntervalSince1970: 1_788_969_600),
            score: score,
            scoreDescription: "흐름 좋은 날",
            title: "흘렸던 땀방울이 달콤한 결실로 돌아오는 하루예요.",
            categoryScores: [
                FortuneCategoryScore(category: .relationship, score: 45),
                FortuneCategoryScore(category: .love, score: 74),
                FortuneCategoryScore(category: .achievement, score: 38),
                FortuneCategoryScore(category: .health, score: 62),
                FortuneCategoryScore(category: .money, score: 90)
            ]
        )
    }
}
