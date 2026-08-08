import SwiftUI
import DesignSystem

struct EnterNamePlaygroundView: View {
    private enum ValidationPreview: String, CaseIterable, Identifiable {
        case none = "None"
        case success = "Success"
        case error = "Error"

        // swiftlint:disable:next identifier_name
        var id: Self { self }

        var validationState: DSTextFieldValidationState {
            switch self {
            case .none: .none
            case .success: .success
            case .error: .error(message: "이름을 다시 확인해 주세요.")
            }
        }
    }

    @State private var text = ""
    @State private var validationPreview = ValidationPreview.none
    @State private var isDarkBackground = false
    @FocusState private var isFocused: Bool

    private var specification: DSEnterName.Specification {
        DSEnterName.specification()
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSEnterName.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSEnterName(
                    text: $text,
                    validationState: validationPreview.validationState,
                    isFocused: $isFocused
                )
            }

            Form {
                Section(header: Text("Content & State")) {
                    TextField("Name", text: $text)
                    Picker("Validation", selection: $validationPreview) {
                        ForEach(ValidationPreview.allCases) { preview in
                            Text(preview.rawValue)
                                .tag(preview)
                        }
                    }
                    Toggle(
                        "Focused",
                        isOn: Binding(
                            get: { isFocused },
                            set: { isFocused = $0 }
                        )
                    )
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(
                        title: "Content Spacing",
                        value: specification.contentSpacing.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Label Typography",
                        value: specification.labelFontStyle.specName
                    )
                    DSSpecificationRow(
                        title: "Label Color",
                        value: specification.labelForegroundAsset.specDescription
                    )
                }
            }
        }
        .navigationTitle("DSEnterName")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EnterNamePlaygroundView()
    }
}
