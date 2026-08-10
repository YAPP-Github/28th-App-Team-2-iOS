import Foundation

enum OnboardingCancelID {
    case socialLogin
    case signup
}

extension UnicodeScalar {
    var isKoreanNameScalar: Bool {
        switch value {
        case 0xAC00 ... 0xD7A3, // Hangul syllables
             0x1100 ... 0x11FF, // Hangul jamo
             0x3130 ... 0x318F, // Hangul compatibility jamo
             0xA960 ... 0xA97F, // Hangul jamo extended-A
             0xD7B0 ... 0xD7FF: // Hangul jamo extended-B
            true
        default:
            false
        }
    }
}
