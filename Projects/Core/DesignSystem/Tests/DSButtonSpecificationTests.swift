import XCTest
@testable import DesignSystem

final class DSButtonSpecificationTests: XCTestCase {
    func testSpecifications() {
        for variant in DSButtonVariant.allCases {
            for size in DSButtonSize.allCases {
                for isEnabled in [true, false] {
                    let specification = DSButton.specification(
                        variant: variant,
                        size: size,
                        isEnabled: isEnabled
                    )

                    XCTAssertEqual(specification.horizontalPadding, 20)
                    XCTAssertEqual(specification.contentGap, 8)
                    XCTAssertEqual(specification.shape, .roundedRectangle(cornerRadius: 12))

                    switch size {
                    case .large:
                        XCTAssertEqual(specification.height, 52)
                        XCTAssertEqual(specification.iconSize, 20)
                        XCTAssertEqual(specification.fontStyle, isEnabled ? .body2SemiBold : .body2Medium)
                    case .medium:
                        XCTAssertEqual(specification.height, 44)
                        XCTAssertEqual(specification.iconSize, 16)
                        XCTAssertEqual(specification.fontStyle, .body3Medium)
                    case .small:
                        XCTAssertEqual(specification.height, 32)
                        XCTAssertEqual(specification.iconSize, 14)
                        XCTAssertEqual(specification.fontStyle, isEnabled ? .caption1SemiBold : .caption1Medium)
                    }

                    if isEnabled {
                        switch variant {
                        case .primary:
                            XCTAssertColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.primary600)
                            XCTAssertColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.white)
                        case .secondary:
                            XCTAssertColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.primary50)
                            XCTAssertColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.primary700)
                        }
                    } else {
                        XCTAssertColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray100)
                        XCTAssertColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.gray400)
                    }
                }
            }
        }
    }
}
