import Foundation
import Testing
import UIKit
@testable import FortuneFeature

struct FortuneMoodLevelTests {
    @Test(
        "원본 소수 점수로 상한 포함·하한 초과 구간을 판정한다",
        arguments: [
            (0.0, FortuneMoodLevel.level01),
            (35.0, .level01),
            (35.1, .level02),
            (65.0, .level02),
            (65.1, .level03),
            (80.0, .level03),
            (80.1, .level04),
            (100.0, .level04)
        ]
    )
    func moodLevelBoundary(score: Double, expected: FortuneMoodLevel) {
        #expect(FortuneMoodLevel(score: score) == expected)
    }

    @Test("표시 점수는 반올림하지만 캐릭터는 원본 소수 점수로 결정한다")
    func displayScoreRoundsIndependentlyFromMoodLevel() {
        let content = FortuneHomeContent(
            dailyFortuneID: UUID(),
            fortuneDate: Date(timeIntervalSince1970: 0),
            score: 65.4,
            title: "오늘의 운세",
            categoryScores: []
        )

        #expect(content.displayScore == 65)
        #expect(content.moodLevel == .level03)
    }

    @Test("선택한 캐릭터 에셋 로드 실패 시 Level03 에셋을 사용한다")
    func missingAssetFallsBackToLevel03() {
        let fallbackImage = UIImage()
        let level03Name = FortuneMoodCharacterAssetResolver.asset(for: .level03).name

        let image = FortuneMoodCharacterAssetResolver.image(for: .level01) { asset in
            asset.name == level03Name ? fallbackImage : nil
        }

        #expect(image === fallbackImage)
    }

    @Test("모든 Mood Level 에셋이 동일한 Figma 캔버스 비율로 번들된다")
    func moodAssetsAreBundled() {
        let assets = FortuneMoodLevel.allCases.map {
            FortuneMoodCharacterAssetResolver.asset(for: $0)
        }

        for asset in assets {
            #expect(asset.image.size == CGSize(width: 102, height: 102))
        }
    }

    @Test("유효하지 않은 비정상 점수는 기본 Level03을 사용한다")
    func nonFiniteScoreFallsBackToLevel03() {
        #expect(FortuneMoodLevel(score: .nan) == .level03)
        #expect(FortuneMoodLevel(score: .infinity) == .level03)
    }
}
