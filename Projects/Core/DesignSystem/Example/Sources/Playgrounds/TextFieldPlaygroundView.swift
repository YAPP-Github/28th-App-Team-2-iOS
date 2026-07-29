import SwiftUI
import DesignSystem

struct TextFieldPlaygroundView: View {
    @State private var text: String = ""
    @State private var validationState: DSTextFieldValidationState = .none
    @State private var isDarkBackground: Bool = false
    @State private var isFocusedSpec: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSTextField.self),
                isDarkBackground: $isDarkBackground
            ) {
                VStack(spacing: 16) {
                    DSTextField(
                        text: $text,
                        placeholder: "Placeholder",
                        validationState: validationState,
                        isFocused: $isTextFieldFocused,
                        onFocusChange: { isFocused in
                            isFocusedSpec = isFocused

                            guard !isFocused else { return }
                            validateText()
                        }
                    )
                    .onChange(of: text) { _, _ in
                        guard validationState != .none else { return }

                        validationState = .none
                    }

                    Button("완료") {
                        isTextFieldFocused = false
                    }
                }
            }

            Form {
                Section(
                    header: Text("Current State"),
                    footer: Text("Playground 검증: 빈 값은 Default, 1~10자는 Success, 11자 이상은 Error입니다.")
                ) {
                    DSSpecificationRow(title: "Rendered State", value: renderedStateName)
                    DSSpecificationRow(title: "Focused", value: isFocusedSpec ? "Yes" : "No")
                    DSSpecificationRow(title: "Has Text", value: text.isEmpty ? "No" : "Yes")
                    Button("Clear Text") {
                        isTextFieldFocused = false
                        text = ""
                    }
                }

                Section(header: Text("Figma Specification Check")) {
                    // specification needs to know focus state to resolve correctly.
                    let spec = DSTextField.specification(
                        isFocused: isFocusedSpec,
                        hasText: !text.isEmpty,
                        validationState: validationState
                    )

                    DSSpecificationRow(title: "Container Height", value: "\(Int(spec.containerHeight))pt")
                    DSSpecificationRow(title: "Container Shape", value: spec.containerShape.specName)
                    DSSpecificationRow(
                        title: "Content Horizontal Padding",
                        value: "\(Int(spec.contentHorizontalPadding))pt"
                    )
                    DSSpecificationRow(title: "Background", value: spec.backgroundAsset.specDescription)
                    if let stroke = spec.strokeAsset {
                        DSSpecificationRow(
                            title: "Stroke",
                            value: "\(stroke.specDescription) (\(Int(spec.strokeWidth))pt)"
                        )
                    } else {
                        DSSpecificationRow(title: "Stroke", value: "None")
                    }
                    DSSpecificationRow(title: "Placeholder Font", value: spec.placeholderFont.specName)
                    DSSpecificationRow(title: "Placeholder Color", value: spec.placeholderColor.specDescription)
                    DSSpecificationRow(title: "Text Font", value: spec.textFont.specName)
                    DSSpecificationRow(title: "Text Color", value: spec.textColor.specDescription)
                    DSSpecificationRow(title: "Cursor Color", value: spec.cursorColorHex)
                    if spec.showsClearButton {
                        if let clearIcon = spec.clearButtonIcon {
                            DSSpecificationRow(title: "Clear Icon", value: clearIcon.specDescription)
                        }
                        DSSpecificationRow(title: "Clear Icon Size", value: "\(Int(spec.clearButtonSize))pt")
                        DSSpecificationRow(title: "Clear Icon Color", value: spec.clearButtonColor.specDescription)
                        DSSpecificationRow(
                            title: "Clear Icon Leading Padding",
                            value: "\(Int(spec.clearButtonLeadingPadding))pt"
                        )
                        if let pressedOverlay = spec.clearIconPressedOverlay {
                            DSSpecificationRow(
                                title: "Clear Icon Pressed Overlay",
                                value: pressedOverlay.specDescription
                            )
                        }
                    }
                    if let error = spec.errorMessage {
                        DSSpecificationRow(title: "Error Msg", value: error)
                        if let errorFont = spec.errorMessageFont {
                            DSSpecificationRow(title: "Error Font", value: errorFont.specName)
                        }
                        if let errorColor = spec.errorMessageColor {
                            DSSpecificationRow(title: "Error Color", value: errorColor.specDescription)
                        }
                        DSSpecificationRow(title: "Error Top Spacing", value: "\(Int(spec.errorMessageTopSpacing))pt")
                        DSSpecificationRow(
                            title: "Error Horizontal Padding",
                            value: "\(Int(spec.errorMessageHorizontalPadding))pt"
                        )
                    }
                }
            }
        }
        .navigationTitle("DSTextField")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func validateText() {
        guard !text.isEmpty else {
            validationState = .none
            return
        }

        if text.count <= 10 {
            validationState = .success
        } else {
            validationState = .error(message: "최대 10글자까지 입력 가능해요.")
        }
    }

    private var renderedStateName: String {
        if isFocusedSpec {
            return text.isEmpty ? "Focus" : "Insert"
        }

        switch validationState {
        case .none:
            return "Default"
        case .success:
            return "Success"
        case .error:
            return "Error"
        }
    }
}

#Preview {
    NavigationStack {
        TextFieldPlaygroundView()
    }
}
