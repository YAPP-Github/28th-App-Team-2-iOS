import SwiftUI

public struct DSDivider: View {
    public struct Specification: Sendable {
        public let thickness: CGFloat
        public let colorAsset: DesignSystemColors
    }

    public static func specification(size: DSDividerSize) -> Specification {
        switch size {
        case .thin:
            Specification(
                thickness: 1,
                colorAsset: DesignSystemAsset.Colors.gray100
            )
        case .thick:
            Specification(
                thickness: 10,
                colorAsset: DesignSystemAsset.Colors.gray25
            )
        }
    }

    private let size: DSDividerSize

    public init(size: DSDividerSize = .thin) {
        self.size = size
    }

    public var body: some View {
        let specification = Self.specification(size: size)

        Rectangle()
            .fill(specification.colorAsset.swiftUIColor)
            .frame(maxWidth: .infinity)
            .frame(height: specification.thickness)
            .accessibilityHidden(true)
            .dsDebugGeometry("DSDivider(\(size.rawValue))")
    }
}

public struct DSThinDivider: View {
    public init() {}

    public var body: some View {
        DSDivider(size: .thin)
    }
}

public struct DSThickDivider: View {
    public init() {}

    public var body: some View {
        DSDivider(size: .thick)
    }
}
