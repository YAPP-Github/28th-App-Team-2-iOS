import SwiftUI

public struct DSDialog: View {
    public struct Action {
        fileprivate let title: String
        fileprivate let handler: () -> Void

        public init(_ title: String, handler: @escaping () -> Void) {
            self.title = title
            self.handler = handler
        }
    }

    public struct Specification: Sendable {
        public let width: CGFloat
        public let contentHorizontalPadding: CGFloat
        public let contentTopPadding: CGFloat
        public let titleFont: FontStyle
        public let titleColor: DesignSystemColors
        public let messageFont: FontStyle?
        public let messageColor: DesignSystemColors?
        public let titleMessageSpacing: CGFloat?
        public let actionTopPadding: CGFloat
        public let actionBottomPadding: CGFloat
        public let actionSpacing: CGFloat?
        public let actionButtonSize: DSButtonSize
        public let actionButtonFontStyle: FontStyle
        public let shape: DSComponentShape
        public let backgroundAsset: DesignSystemColors
    }

    public static func specification(
        hasMessage: Bool,
        hasSecondaryAction: Bool
    ) -> Specification {
        return Specification(
            width: 280,
            contentHorizontalPadding: 20,
            contentTopPadding: 20,
            titleFont: .body2SemiBold,
            titleColor: DesignSystemAsset.Colors.gray975,
            messageFont: hasMessage ? .body3Regular : nil,
            messageColor: hasMessage ? DesignSystemAsset.Colors.gray800 : nil,
            titleMessageSpacing: hasMessage ? 4 : nil,
            actionTopPadding: 20,
            actionBottomPadding: 20,
            actionSpacing: hasSecondaryAction ? 8 : nil,
            actionButtonSize: .medium,
            actionButtonFontStyle: .body3SemiBold,
            shape: .roundedRectangle(cornerRadius: 12),
            backgroundAsset: DesignSystemAsset.Colors.white
        )
    }

    private let title: String
    private let message: String?
    private let primaryAction: Action
    private let secondaryAction: Action?

    public init(
        title: String,
        message: String? = nil,
        primaryAction: Action,
        secondaryAction: Action? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    public var body: some View {
        let specification = Self.specification(
            hasMessage: message != nil,
            hasSecondaryAction: secondaryAction != nil
        )

        VStack(spacing: 0) {
            VStack(spacing: specification.titleMessageSpacing ?? 0) {
                Text(title)
                    .dsFont(specification.titleFont)
                    .foregroundStyle(specification.titleColor.swiftUIColor)

                if let message,
                   let messageFont = specification.messageFont,
                   let messageColor = specification.messageColor {
                    Text(message)
                        .dsFont(messageFont)
                        .foregroundStyle(messageColor.swiftUIColor)
                }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, specification.contentHorizontalPadding)
            .padding(.top, specification.contentTopPadding)
            .dsDebugDetailGeometry("DSDialog.Content")

            HStack(spacing: specification.actionSpacing ?? 0) {
                if let secondaryAction {
                    actionButton(
                        secondaryAction,
                        variant: .secondary,
                        specification: specification
                    )
                }

                actionButton(
                    primaryAction,
                    variant: .primary,
                    specification: specification
                )
            }
            .padding(.horizontal, specification.contentHorizontalPadding)
            .padding(.top, specification.actionTopPadding)
            .padding(.bottom, specification.actionBottomPadding)
            .dsDebugDetailGeometry("DSDialog.Actions")
        }
        .frame(width: specification.width)
        .background(specification.backgroundAsset.swiftUIColor)
        .clipShape(specification.shape.swiftUIShape)
        .dsDebugGeometry("DSDialog")
    }

    private func actionButton(
        _ action: Action,
        variant: DSButtonVariant,
        specification: Specification
    ) -> some View {
        DSButton(
            action.title,
            variant: variant,
            size: specification.actionButtonSize,
            fontStyleOverride: specification.actionButtonFontStyle,
            action: action.handler
        )
    }
}
