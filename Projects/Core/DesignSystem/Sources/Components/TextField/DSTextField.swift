import SwiftUI

public enum DSTextFieldValidationState: Sendable, Equatable {
    case none
    case success
    case error(message: String)
}

public struct DSTextField: View {
    public struct Specification: Sendable {
        public let containerHeight: CGFloat
        public let containerShape: DSComponentShape
        public let backgroundAsset: DesignSystemColors
        public let strokeAsset: DesignSystemColors?
        public let strokeWidth: CGFloat
        public let contentSpacing: CGFloat
        public let contentHorizontalPadding: CGFloat

        public let textFont: FontStyle
        public let textColor: DesignSystemColors

        public let placeholderFont: FontStyle
        public let placeholderColor: DesignSystemColors

        public let showsClearButton: Bool
        public let clearButtonSize: CGFloat
        public let clearButtonIcon: DSIconAsset?
        public let clearButtonColor: DesignSystemColors
        public let clearButtonLeadingPadding: CGFloat
        public let clearIconPressedOverlay: DSPressedOverlay?

        public let errorMessage: String?
        public let errorMessageFont: FontStyle?
        public let errorMessageColor: DesignSystemColors?
        public let errorMessageTopSpacing: CGFloat
        public let errorMessageHorizontalPadding: CGFloat
    }

    public static func specification(
        isFocused: Bool,
        hasText: Bool,
        validationState: DSTextFieldValidationState
    ) -> Specification {
        // Validation feedback is shown after editing finishes. While the field
        // is active, its own focus/insert affordance has precedence.
        let displayedValidationState: DSTextFieldValidationState = isFocused ? .none : validationState
        let isError: Bool
        let errorMsg: String?
        if case let .error(msg) = displayedValidationState {
            isError = true
            errorMsg = msg
        } else {
            isError = false
            errorMsg = nil
        }

        let isSuccess = displayedValidationState == .success
        let isInsert = isFocused && hasText
        let isFocus = isFocused && !hasText
        let bgAsset: DesignSystemColors
        var strokeAsset: DesignSystemColors?
        let textFont: FontStyle = .body2Medium
        let textColor: DesignSystemColors = DesignSystemAsset.Colors.gray975
        var showsClearButton = false
        var clearBtnIcon: DSIconAsset?

        if isError {
            bgAsset = DesignSystemAsset.Colors.red50
        } else if isSuccess {
            bgAsset = DesignSystemAsset.Colors.gray25
        } else if isInsert {
            bgAsset = DesignSystemAsset.Colors.gray25
            strokeAsset = DesignSystemAsset.Colors.gray975
            showsClearButton = true
            clearBtnIcon = .circleXFill
        } else if isFocus {
            bgAsset = DesignSystemAsset.Colors.gray25
            strokeAsset = DesignSystemAsset.Colors.gray975
        } else {
            // Default or DefaultWithText
            bgAsset = DesignSystemAsset.Colors.gray25
        }

        return Specification(
            containerHeight: 48,
            containerShape: .roundedRectangle(cornerRadius: 12),
            backgroundAsset: bgAsset,
            strokeAsset: strokeAsset,
            strokeWidth: strokeAsset != nil ? 1.0 : 0.0,
            contentSpacing: 0,
            contentHorizontalPadding: 16,
            textFont: textFont,
            textColor: textColor,
            placeholderFont: .body2Regular,
            placeholderColor: DesignSystemAsset.Colors.gray600,
            showsClearButton: showsClearButton,
            clearButtonSize: 20,
            clearButtonIcon: clearBtnIcon,
            clearButtonColor: DesignSystemAsset.Colors.gray300,
            clearButtonLeadingPadding: 10,
            clearIconPressedOverlay: showsClearButton ? .standard : nil,
            errorMessage: errorMsg,
            errorMessageFont: isError ? .caption1Regular : nil,
            errorMessageColor: isError ? DesignSystemAsset.Colors.red500 : nil,
            errorMessageTopSpacing: 8,
            errorMessageHorizontalPadding: 4
        )
    }

    @Binding private var text: String
    private let placeholder: String
    private let validationState: DSTextFieldValidationState
    private let focusBinding: FocusState<Bool>.Binding?
    private let onFocusChange: ((Bool) -> Void)?

    @FocusState private var internalFocus: Bool

    private var isFocused: Bool {
        focusBinding?.wrappedValue ?? internalFocus
    }

    public init(
        text: Binding<String>,
        placeholder: String = "",
        validationState: DSTextFieldValidationState = .none,
        isFocused: FocusState<Bool>.Binding? = nil,
        onFocusChange: ((Bool) -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.validationState = validationState
        self.focusBinding = isFocused
        self.onFocusChange = onFocusChange
    }

    public var body: some View {
        let spec = Self.specification(
            isFocused: isFocused,
            hasText: !text.isEmpty,
            validationState: validationState
        )

        VStack(alignment: .leading, spacing: spec.errorMessageTopSpacing) {
            HStack(spacing: spec.contentSpacing) {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .dsFont(spec.placeholderFont)
                            .foregroundColor(spec.placeholderColor.swiftUIColor)
                    }

                    TextField("", text: $text)
                        .focused(focusBinding ?? $internalFocus)
                        .font(.ds.font(spec.textFont))
                        .foregroundColor(spec.textColor.swiftUIColor)
                        .frame(height: spec.textFont.lineHeight)
                        .dsDebugTypographyGeometry("Typography.\(String(describing: spec.textFont))")
                }

                if spec.showsClearButton, let clearIcon = spec.clearButtonIcon {
                    Button(
                        action: {
                            text = ""
                        },
                        label: {
                            DSIcon(clearIcon, width: spec.clearButtonSize, height: spec.clearButtonSize)
                                .foregroundColor(spec.clearButtonColor.swiftUIColor)
                                .dsDebugDetailGeometry("DSTextField.ClearButton")
                        }
                    )
                    .buttonStyle(
                        DSIconButtonStyle(
                            iconAsset: clearIcon,
                            iconSize: CGSize(width: spec.clearButtonSize, height: spec.clearButtonSize),
                            pressedOverlay: spec.clearIconPressedOverlay
                        )
                    )
                    .padding(.leading, spec.clearButtonLeadingPadding)
                }
            }
            .padding(.horizontal, spec.contentHorizontalPadding)
            .frame(maxWidth: .infinity)
            .frame(height: spec.containerHeight)
            .background(
                spec.containerShape.swiftUIShape
                    .fill(spec.backgroundAsset.swiftUIColor)
            )
            .overlay(
                Group {
                    if let stroke = spec.strokeAsset, spec.strokeWidth > 0 {
                        spec.containerShape.strokeBorder(stroke.swiftUIColor, lineWidth: spec.strokeWidth)
                    }
                }
            )
            .clipShape(spec.containerShape.swiftUIShape)
            .onTapGesture {
                if let focusBinding {
                    focusBinding.wrappedValue = true
                } else {
                    internalFocus = true
                }
            }
            .dsDebugDetailGeometry("DSTextField.Container")

            if let errorMsg = spec.errorMessage,
               let errorFont = spec.errorMessageFont,
               let errorColor = spec.errorMessageColor {
                Text(errorMsg)
                    .dsFont(errorFont)
                    .foregroundColor(errorColor.swiftUIColor)
                    .padding(.horizontal, spec.errorMessageHorizontalPadding)
            }
        }
        .onChange(of: focusBinding?.wrappedValue) { _, newValue in
            guard focusBinding != nil, let newValue else { return }
            onFocusChange?(newValue)
        }
        .onChange(of: internalFocus) { _, newValue in
            guard focusBinding == nil else { return }
            onFocusChange?(newValue)
        }
        .dsDebugGeometry("DSTextField")
    }
}
