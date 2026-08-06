import SwiftUI

public enum DSComponentShape: Equatable, Sendable {
    case roundedRectangle(cornerRadius: CGFloat)
    case unevenRoundedRectangle(
        topLeadingRadius: CGFloat,
        topTrailingRadius: CGFloat,
        bottomLeadingRadius: CGFloat,
        bottomTrailingRadius: CGFloat
    )
    case capsule
}

extension DSComponentShape {
    var swiftUIShape: AnyShape {
        switch self {
        case let .roundedRectangle(cornerRadius):
            AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
        case let .unevenRoundedRectangle(
            topLeadingRadius,
            topTrailingRadius,
            bottomLeadingRadius,
            bottomTrailingRadius
        ):
            AnyShape(UnevenRoundedRectangle(
                topLeadingRadius: topLeadingRadius,
                bottomLeadingRadius: bottomLeadingRadius,
                bottomTrailingRadius: bottomTrailingRadius,
                topTrailingRadius: topTrailingRadius,
                style: .continuous
            ))
        case .capsule:
            AnyShape(Capsule())
        }
    }

    @ViewBuilder
    func strokeBorder(_ color: Color, lineWidth: CGFloat) -> some View {
        switch self {
        case let .roundedRectangle(cornerRadius):
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(color, lineWidth: lineWidth)
        case let .unevenRoundedRectangle(
            topLeadingRadius,
            topTrailingRadius,
            bottomLeadingRadius,
            bottomTrailingRadius
        ):
            UnevenRoundedRectangle(
                topLeadingRadius: topLeadingRadius,
                bottomLeadingRadius: bottomLeadingRadius,
                bottomTrailingRadius: bottomTrailingRadius,
                topTrailingRadius: topTrailingRadius,
                style: .continuous
            )
            .strokeBorder(color, lineWidth: lineWidth)
        case .capsule:
            Capsule()
                .strokeBorder(color, lineWidth: lineWidth)
        }
    }
}
