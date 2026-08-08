import SwiftUI

public struct DSEnterName: View {
    public struct Specification: Sendable {
        public let contentSpacing: CGFloat
        public let labelFontStyle: FontStyle
        public let labelForegroundAsset: DesignSystemColors
    }

    public static func specification() -> Specification {
        Specification(
            contentSpacing: 16,
            labelFontStyle: .body1Bold,
            labelForegroundAsset: DesignSystemAsset.Colors.black
        )
    }

    @Binding private var text: String
    private let validationState: DSTextFieldValidationState
    private let focusBinding: FocusState<Bool>.Binding?
    private let onFocusChange: ((Bool) -> Void)?

    public init(
        text: Binding<String>,
        validationState: DSTextFieldValidationState = .none,
        isFocused: FocusState<Bool>.Binding? = nil,
        onFocusChange: ((Bool) -> Void)? = nil
    ) {
        self._text = text
        self.validationState = validationState
        self.focusBinding = isFocused
        self.onFocusChange = onFocusChange
    }

    public var body: some View {
        let specification = Self.specification()

        VStack(alignment: .leading, spacing: specification.contentSpacing) {
            Text("이름")
                .dsFont(specification.labelFontStyle)
                .foregroundStyle(specification.labelForegroundAsset.swiftUIColor)

            DSTextField(
                text: $text,
                placeholder: "예) 홍길동",
                validationState: validationState,
                isFocused: focusBinding,
                onFocusChange: onFocusChange
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsDebugGeometry("DSEnterName")
    }
}
