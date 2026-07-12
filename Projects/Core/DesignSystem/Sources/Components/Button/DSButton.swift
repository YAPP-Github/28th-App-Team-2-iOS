import SwiftUI

// MARK: - Core Button Component
public struct DSButton: View {
    public enum Layout {
        public static let horizontalPadding: CGFloat = 20
        public static let cornerRadius: CGFloat = 12
        public static let contentGap: CGFloat = 8
    }

    private let title: String
    private let leftIcon: Image?
    private let rightIcon: Image?
    private let variant: DSButtonVariant
    private let size: DSButtonSize
    private let action: () -> Void
    
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
        Button(action: action) {
            HStack(alignment: .center, spacing: DSButton.Layout.contentGap) { // 피그마 규격 align-items: center 및 gap: 8px 수호
                if let leftIcon {
                    leftIcon
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.iconSize, height: size.iconSize)
                }
                
                Text(title)
                
                if let rightIcon {
                    rightIcon
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.iconSize, height: size.iconSize)
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
