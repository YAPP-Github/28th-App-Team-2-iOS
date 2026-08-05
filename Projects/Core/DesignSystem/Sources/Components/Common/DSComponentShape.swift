import SwiftUI

public enum DSComponentShape: Equatable, Sendable {
    case roundedRectangle(cornerRadius: CGFloat)
    case unevenRoundedRectangle(topCornerRadius: CGFloat)
    case capsule
}

extension DSComponentShape {
    var swiftUIShape: AnyShape {
        switch self {
        case let .roundedRectangle(cornerRadius):
            AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
        case let .unevenRoundedRectangle(topCornerRadius):
            AnyShape(UnevenRoundedRectangle(
                topLeadingRadius: topCornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: topCornerRadius,
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
        case let .unevenRoundedRectangle(topCornerRadius):
            UnevenRoundedRectangle(
                topLeadingRadius: topCornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: topCornerRadius,
                style: .continuous
            )
            .strokeBorder(color, lineWidth: lineWidth)
        case .capsule:
            Capsule()
                .strokeBorder(color, lineWidth: lineWidth)
        }
    }
}
