import Foundation

public extension UnicodeScalar {
    var isKoreanNameScalar: Bool {
        switch value {
        case 0xAC00 ... 0xD7A3,
             0x1100 ... 0x11FF,
             0x3130 ... 0x318F,
             0xA960 ... 0xA97F,
             0xD7B0 ... 0xD7FF:
            true
        default:
            false
        }
    }
}
