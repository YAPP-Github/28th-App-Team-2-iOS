import SwiftUI

public struct DSSelectField: View {
    public struct Specification: Sendable {
        public let containerHeight: CGFloat
        public let containerShape: DSComponentShape
        public let backgroundAsset: DesignSystemColors
        public let strokeAsset: DesignSystemColors?
        public let strokeWidth: CGFloat
        public let contentSpacing: CGFloat
        public let contentHorizontalPadding: CGFloat

        public let placeholderFont: FontStyle
        public let placeholderColor: DesignSystemColors
        public let textFont: FontStyle
        public let textColor: DesignSystemColors

        public let showsClearButton: Bool
        public let clearButtonSize: CGFloat?
        public let clearButtonIcon: DSIconAsset?
        public let clearButtonColor: DesignSystemColors?
        public let clearButtonLeadingPadding: CGFloat?
        public let clearIconPressedOverlay: DSPressedOverlay?

        public let chevronIcon: DSIconAsset
        public let chevronSize: CGFloat
        public let chevronColor: DesignSystemColors
        public let chevronLeadingPadding: CGFloat
        public let chevronRotationDegrees: CGFloat
    }

    public static func specification(
        isFocused: Bool,
        hasSelection: Bool
    ) -> Specification {
        let strokeAsset: DesignSystemColors? = isFocused
            ? DesignSystemAsset.Colors.gray975
            : nil

        return Specification(
            containerHeight: 48,
            containerShape: .roundedRectangle(cornerRadius: 12),
            backgroundAsset: DesignSystemAsset.Colors.gray25,
            strokeAsset: strokeAsset,
            strokeWidth: strokeAsset == nil ? 0.0 : 1.0,
            contentSpacing: 0,
            contentHorizontalPadding: 16,
            placeholderFont: .body2Regular,
            placeholderColor: DesignSystemAsset.Colors.gray600,
            textFont: .body2Medium,
            textColor: DesignSystemAsset.Colors.gray975,
            showsClearButton: hasSelection && !isFocused,
            clearButtonSize: hasSelection && !isFocused ? 20 : nil,
            clearButtonIcon: hasSelection && !isFocused ? .circleXFill : nil,
            clearButtonColor: hasSelection && !isFocused
                ? DesignSystemAsset.Colors.gray300
                : nil,
            clearButtonLeadingPadding: hasSelection && !isFocused ? 10 : nil,
            clearIconPressedOverlay: hasSelection && !isFocused ? .standard : nil,
            chevronIcon: .chevronSmallBottom,
            chevronSize: 20,
            chevronColor: isFocused
                ? DesignSystemAsset.Colors.gray975
                : DesignSystemAsset.Colors.gray600,
            chevronLeadingPadding: hasSelection && !isFocused ? 10 : 0,
            chevronRotationDegrees: isFocused ? 180 : 0
        )
    }

    @Binding private var selection: String?
    private let placeholder: String
    private let isFocused: Bool
    private let action: () -> Void

    public init(
        selection: Binding<String?>,
        placeholder: String = "",
        isFocused: Bool = false,
        action: @escaping () -> Void
    ) {
        self._selection = selection
        self.placeholder = placeholder
        self.isFocused = isFocused
        self.action = action
    }

    public var body: some View {
        let spec = Self.specification(
            isFocused: isFocused,
            hasSelection: selection != nil
        )

        HStack(spacing: spec.contentSpacing) {
            Button(action: action) {
                Text(selection ?? placeholder)
                    .dsFont(selection == nil ? spec.placeholderFont : spec.textFont)
                    .foregroundStyle(
                        selection == nil
                            ? spec.placeholderColor.swiftUIColor
                            : spec.textColor.swiftUIColor
                    )
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if spec.showsClearButton,
               let clearIcon = spec.clearButtonIcon,
               let clearButtonSize = spec.clearButtonSize,
               let clearButtonColor = spec.clearButtonColor,
               let clearButtonLeadingPadding = spec.clearButtonLeadingPadding {
                Button {
                    selection = nil
                } label: {
                    DSIcon(clearIcon, width: clearButtonSize, height: clearButtonSize)
                        .foregroundColor(clearButtonColor.swiftUIColor)
                        .dsDebugDetailGeometry("DSSelectField.ClearButton")
                }
                .buttonStyle(
                    DSIconButtonStyle(
                        iconAsset: clearIcon,
                        iconSize: CGSize(width: clearButtonSize, height: clearButtonSize),
                        pressedOverlay: spec.clearIconPressedOverlay
                    )
                )
                .padding(.leading, clearButtonLeadingPadding)
            }

            Button(action: action) {
                DSIcon(spec.chevronIcon, width: spec.chevronSize, height: spec.chevronSize)
                    .foregroundColor(spec.chevronColor.swiftUIColor)
                    .rotationEffect(.degrees(spec.chevronRotationDegrees))
                    .dsDebugDetailGeometry("DSSelectField.Chevron")
            }
            .buttonStyle(.plain)
            .padding(.leading, spec.chevronLeadingPadding)
        }
        .padding(.horizontal, spec.contentHorizontalPadding)
        .frame(maxWidth: .infinity)
        .frame(height: spec.containerHeight)
        .background(
            spec.containerShape.swiftUIShape
                .fill(spec.backgroundAsset.swiftUIColor)
        )
        .overlay {
            if let stroke = spec.strokeAsset, spec.strokeWidth > 0 {
                spec.containerShape.strokeBorder(stroke.swiftUIColor, lineWidth: spec.strokeWidth)
            }
        }
        .clipShape(spec.containerShape.swiftUIShape)
        .dsDebugDetailGeometry("DSSelectField.Container")
        .dsDebugGeometry("DSSelectField")
    }
}
