import SwiftUI

// MARK: - Core Button Component
public struct DSButton: View {
    public struct Specification: Sendable {
        public let height: CGFloat
        public let horizontalPadding: CGFloat
        public let contentGap: CGFloat
        public let iconSize: CGFloat
        public let shape: DSComponentShape
        public let fontStyle: FontStyle
        public let backgroundAsset: DesignSystemColors
        public let foregroundAsset: DesignSystemColors
    }

    public static func specification(
        variant: DSButtonVariant,
        size: DSButtonSize,
        isEnabled: Bool
    ) -> Specification {
        let height: CGFloat
        let iconSize: CGFloat
        let fontStyle: FontStyle

        switch size {
        case .large:
            height = 52
            iconSize = 20
            fontStyle = isEnabled ? .body2SemiBold : .body2Medium
        case .medium:
            height = 44
            iconSize = 16
            fontStyle = .body3Medium
        case .small:
            height = 32
            iconSize = 14
            fontStyle = isEnabled ? .caption1SemiBold : .caption1Medium
        }

        let assets: (background: DesignSystemColors, foreground: DesignSystemColors)

        if isEnabled {
            switch variant {
            case .primary:
                assets = (DesignSystemAsset.Colors.primary600, DesignSystemAsset.Colors.white)
            case .secondary:
                assets = (DesignSystemAsset.Colors.primary50, DesignSystemAsset.Colors.primary700)
            }
        } else {
            assets = (DesignSystemAsset.Colors.gray100, DesignSystemAsset.Colors.gray400)
        }

        return Specification(
            height: height,
            horizontalPadding: 20,
            contentGap: 8,
            iconSize: iconSize,
            shape: .roundedRectangle(cornerRadius: 12),
            fontStyle: fontStyle,
            backgroundAsset: assets.background,
            foregroundAsset: assets.foreground
        )
    }

    private let title: String
    private let leftIcon: Image?
    private let rightIcon: Image?
    private let variant: DSButtonVariant
    private let size: DSButtonSize
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    
    public init(
        _ title: String,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        variant: DSButtonVariant = .primary,
        size: DSButtonSize = .large,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.variant = variant
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        let specification = Self.specification(
            variant: variant,
            size: size,
            isEnabled: isEnabled
        )

        Button(action: action) {
            HStack(alignment: .center, spacing: specification.contentGap) {
                if let leftIcon {
                    leftIcon
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: specification.iconSize, height: specification.iconSize)
                }
                
                Text(title)
                
                if let rightIcon {
                    rightIcon
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: specification.iconSize, height: specification.iconSize)
                }
            }
        }
        .buttonStyle(DSButtonStyle(variant: variant, size: size))
    }
}

// MARK: - Convenience Wrapper Components

// 1. Primary Buttons
public struct DSPrimaryLargeButton: View {
    private let title: String
    private let leftIcon: Image?
    private let rightIcon: Image?
    private let action: () -> Void
    
    public init(
        _ title: String,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.action = action
    }
    
    public var body: some View {
        DSButton(title, leftIcon: leftIcon, rightIcon: rightIcon, variant: .primary, size: .large, action: action)
    }
}

public struct DSPrimaryMediumButton: View {
    private let title: String
    private let leftIcon: Image?
    private let rightIcon: Image?
    private let action: () -> Void
    
    public init(
        _ title: String,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.action = action
    }
    
    public var body: some View {
        DSButton(title, leftIcon: leftIcon, rightIcon: rightIcon, variant: .primary, size: .medium, action: action)
    }
}

public struct DSPrimarySmallButton: View {
    private let title: String
    private let leftIcon: Image?
    private let rightIcon: Image?
    private let action: () -> Void
    
    public init(
        _ title: String,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.action = action
    }
    
    public var body: some View {
        DSButton(title, leftIcon: leftIcon, rightIcon: rightIcon, variant: .primary, size: .small, action: action)
    }
}

// 2. Secondary Buttons
public struct DSSecondaryLargeButton: View {
    private let title: String
    private let leftIcon: Image?
    private let rightIcon: Image?
    private let action: () -> Void
    
    public init(
        _ title: String,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.action = action
    }
    
    public var body: some View {
        DSButton(title, leftIcon: leftIcon, rightIcon: rightIcon, variant: .secondary, size: .large, action: action)
    }
}

public struct DSSecondaryMediumButton: View {
    private let title: String
    private let leftIcon: Image?
    private let rightIcon: Image?
    private let action: () -> Void
    
    public init(
        _ title: String,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.action = action
    }
    
    public var body: some View {
        DSButton(title, leftIcon: leftIcon, rightIcon: rightIcon, variant: .secondary, size: .medium, action: action)
    }
}

public struct DSSecondarySmallButton: View {
    private let title: String
    private let leftIcon: Image?
    private let rightIcon: Image?
    private let action: () -> Void
    
    public init(
        _ title: String,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.action = action
    }
    
    public var body: some View {
        DSButton(title, leftIcon: leftIcon, rightIcon: rightIcon, variant: .secondary, size: .small, action: action)
    }
}
