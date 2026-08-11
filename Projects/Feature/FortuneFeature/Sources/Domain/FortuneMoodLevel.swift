import Foundation

public enum FortuneMoodLevel: Int, CaseIterable, Equatable, Sendable {
    case level01 = 1
    case level02 = 2
    case level03 = 3
    case level04 = 4

    public init(score: Double) {
        guard score.isFinite else {
            self = .level03
            return
        }

        switch score {
        case ...35:
            self = .level01
        case ...65:
            self = .level02
        case ...80:
            self = .level03
        default:
            self = .level04
        }
    }
}
