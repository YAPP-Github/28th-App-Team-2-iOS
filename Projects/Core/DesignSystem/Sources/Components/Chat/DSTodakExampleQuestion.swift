import SwiftUI

public struct DSTodakExampleQuestion: View {
    public struct Segment: Equatable, Sendable {
        public let text: String
        public let isBold: Bool

        public init(_ text: String, isBold: Bool = false) {
            self.text = text
            self.isBold = isBold
        }
    }

    public struct Specification: Sendable {
        public let height: CGFloat
        public let shape: DSComponentShape
        public let backgroundAsset: DesignSystemColors
        public let fontStyle: FontStyle
        public let foregroundAsset: DesignSystemColors
        public let emphasizedFontStyle: FontStyle
        public let emphasizedForegroundAsset: DesignSystemColors
        public let horizontalPadding: CGFloat
        public let verticalPadding: CGFloat
    }

    public static let specification = Specification(
        height: 48,
        shape: .roundedRectangle(cornerRadius: 12),
        backgroundAsset: DesignSystemAsset.Colors.primary50,
        fontStyle: .body2Regular,
        foregroundAsset: DesignSystemAsset.Colors.coolGray800,
        emphasizedFontStyle: .body2SemiBold,
        emphasizedForegroundAsset: DesignSystemAsset.Colors.coolGray900,
        horizontalPadding: 18,
        verticalPadding: 12
    )

    private let segments: [Segment]

    public init(_ question: String) {
        self.segments = [Segment(question)]
    }

    public init(segments: [Segment]) {
        self.segments = segments
    }

    public var body: some View {
        let specification = Self.specification

        questionText(specification: specification)
            .dsFont(specification.fontStyle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, specification.horizontalPadding)
            .padding(.vertical, specification.verticalPadding)
            .frame(minHeight: specification.height)
            .background(specification.backgroundAsset.swiftUIColor)
            .clipShape(specification.shape.swiftUIShape)
            .dsDebugGeometry("DSTodakExampleQuestion")
    }

    private func questionText(specification: Specification) -> Text {
        segments.reduce(Text("")) { text, segment in
            let fontStyle = segment.isBold
                ? specification.emphasizedFontStyle
                : specification.fontStyle
            let foregroundAsset = segment.isBold
                ? specification.emphasizedForegroundAsset
                : specification.foregroundAsset

            return text + Text(segment.text)
                .font(.ds.font(fontStyle))
                .foregroundStyle(foregroundAsset.swiftUIColor)
        }
    }
}
