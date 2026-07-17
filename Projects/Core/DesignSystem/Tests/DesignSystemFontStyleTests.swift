import XCTest
@testable import DesignSystem

final class DesignSystemFontStyleTests: XCTestCase {
    private struct FontMetricsExpectation {
        let styles: [FontStyle]
        let size: CGFloat
        let lineHeight: CGFloat
    }

    func testFontMetrics() {
        let expectations: [FontMetricsExpectation] = [
            .init(styles: [.heading1ExtraBold, .heading1Bold, .heading1SemiBold], size: 32, lineHeight: 44),
            .init(styles: [.heading2ExtraBold, .heading2Bold, .heading2SemiBold], size: 28, lineHeight: 38),
            .init(styles: [.heading3Bold, .heading3Medium, .heading3Regular], size: 24, lineHeight: 32),
            .init(styles: [.heading4Bold, .heading4Medium, .heading4Regular], size: 22, lineHeight: 30),
            .init(styles: [.body1Bold, .body1Medium, .body1Regular], size: 18, lineHeight: 26),
            .init(styles: [.body2SemiBold, .body2Medium, .body2Regular], size: 16, lineHeight: 24),
            .init(styles: [.body3SemiBold, .body3Medium, .body3Regular], size: 14, lineHeight: 20),
            .init(styles: [.caption1SemiBold, .caption1Medium, .caption1Regular], size: 12, lineHeight: 16),
            .init(styles: [.caption2SemiBold, .caption2Medium, .caption2Regular], size: 11, lineHeight: 14),
            .init(styles: [.caption3SemiBold, .caption3Medium, .caption3Regular], size: 10, lineHeight: 13)
        ]

        for expectation in expectations {
            for style in expectation.styles {
                XCTAssertEqual(style.size, expectation.size)
                XCTAssertEqual(style.lineHeight, expectation.lineHeight)
            }
        }
    }
}
