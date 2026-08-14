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
                FortuneCategoryScore(
                    luckActionID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    category: .relationship,
                    score: 45
                ),
                FortuneCategoryScore(
                    luckActionID: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                    category: .love,
                    score: 74
                ),
                FortuneCategoryScore(
                    luckActionID: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                    category: .achievement,
                    score: 38
                ),
                FortuneCategoryScore(
                    luckActionID: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                    category: .health,
                    score: 62
                ),
                FortuneCategoryScore(
                    luckActionID: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
                    category: .money,
                    score: 90
                )
            ]
        )
    }
}

extension FortuneDetailContent {
    static func example(score: Int = 65) -> Self {
        Self(
            dailyFortuneID: UUID(uuidString: "A0B1C2D3-E4F5-4678-9012-3456789ABCDE")!,
            fortuneDate: Date(timeIntervalSince1970: 1_788_969_600),
            score: score,
            title: "오늘은 무난하고 평범한 하루예요",
            content: """
                주변 사람들과의 관계가 한층 부드러워지는 시기예요. \
                평소에는 무심코 지나쳤던 인연 속에서 뜻밖의 도움이나 따뜻한 위로를 얻게 될 수 있어요. \
                작은 오해가 있었다면 먼저 손을 내밀어 보세요. \
                진심 어린 한마디가 관계의 흐름을 좋은 방향으로 이끌어 줄 거예요.
                """,
            luckyItems: ["따뜻한 차", "노란색 아이템", "산책"],
            cautionaryItems: ["충동구매", "과식"],
            categoryScores: [
                FortuneCategoryScore(luckActionID: UUID(), category: .relationship, score: 45),
                FortuneCategoryScore(luckActionID: UUID(), category: .love, score: 74),
                FortuneCategoryScore(luckActionID: UUID(), category: .achievement, score: 38),
                FortuneCategoryScore(luckActionID: UUID(), category: .health, score: 62),
                FortuneCategoryScore(luckActionID: UUID(), category: .money, score: 90)
            ]
        )
    }
}
