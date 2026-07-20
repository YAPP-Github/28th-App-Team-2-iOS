import Testing
@testable import DesignSystem

struct DSButtonSpecificationTests {
    struct TestInput: Sendable, CustomStringConvertible {
        let variant: DSButtonVariant
        let size: DSButtonSize
        let isEnabled: Bool

        var description: String {
            "\(variant)-\(size)-\(isEnabled ? "enabled" : "disabled")"
        }
    }

    private static let inputs: [TestInput] = {
        var result: [TestInput] = []
        for variant in DSButtonVariant.allCases {
            for size in DSButtonSize.allCases {
                for isEnabled in [true, false] {
                    result.append(TestInput(variant: variant, size: size, isEnabled: isEnabled))
                }
            }
        }
        return result
    }()

    @Test("Button 스펙 매핑 검증", arguments: inputs)
    func testSpecifications(input: TestInput) {
        let specification = DSButton.specification(
            variant: input.variant,
            size: input.size,
            isEnabled: input.isEnabled
        )

        #expect(specification.horizontalPadding == 20)
        #expect(specification.contentGap == 8)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 12))

        switch input.size {
        case .large:
            #expect(specification.height == 52)
            #expect(specification.iconSize == 20)
            #expect(specification.fontStyle == (input.isEnabled ? .body2SemiBold : .body2Medium))
        case .medium:
            #expect(specification.height == 44)
            #expect(specification.iconSize == 16)
            #expect(specification.fontStyle == .body3Medium)
        case .small:
            #expect(specification.height == 32)
            #expect(specification.iconSize == 14)
            #expect(specification.fontStyle == (input.isEnabled ? .caption1SemiBold : .caption1Medium))
        }

        if input.isEnabled {
            switch input.variant {
            case .primary:
                expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.primary600)
                expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.white)
            case .secondary:
                expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.primary50)
                expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.primary700)
            }
        } else {
            expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray100)
            expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.gray400)
        }
    }
}
