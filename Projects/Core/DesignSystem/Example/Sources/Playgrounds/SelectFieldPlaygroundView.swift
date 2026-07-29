import SwiftUI
import DesignSystem

struct SelectFieldPlaygroundView: View {
    @State private var selectedValue: String?
    @State private var placeholder: String = "Placeholder"
    @State private var isFocused: Bool = false
    @State private var isDarkBackground: Bool = false
    @State private var containerWidth: Double = 353
    @State private var selectionCount: Int = 0

    private var specification: DSSelectField.Specification {
        DSSelectField.specification(
            isFocused: isFocused,
            hasSelection: selectedValue != nil
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSSelectField.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSSelectField(
                    selection: $selectedValue,
                    placeholder: placeholder,
                    isFocused: isFocused
                ) {
                    selectionCount += 1
                    isFocused.toggle()
                }
                .frame(width: containerWidth)
            }

            Form {
                Section(header: Text("Content & State")) {
                    TextField("Placeholder", text: $placeholder)
                    Toggle("Has Selection", isOn: hasSelectionBinding)
                    Toggle("Is Focused", isOn: $isFocused)
                    DSSpecificationRow(title: "Selection Action Count", value: "\(selectionCount)")
                    VStack(alignment: .leading) {
                        Text("Parent Width: \(containerWidth, specifier: "%.1f")pt")
                        Slider(value: $containerWidth, in: 180...353, step: 0.5)
                    }
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Container Height", value: specification.containerHeight.ptDescription)
                    DSSpecificationRow(title: "Container Shape", value: specification.containerShape.specName)
                    DSSpecificationRow(
                        title: "Content Horizontal Padding",
                        value: specification.contentHorizontalPadding.ptDescription
                    )
                    DSSpecificationRow(title: "Background", value: specification.backgroundAsset.specDescription)
                    DSSpecificationRow(
                        title: "Stroke",
                        value: specification.strokeAsset.map {
                            "\($0.specDescription) (\(specification.strokeWidth.ptDescription))"
                        } ?? "None"
                    )
                    DSSpecificationRow(title: "Placeholder Font", value: specification.placeholderFont.specName)
                    DSSpecificationRow(
                        title: "Placeholder Color",
                        value: specification.placeholderColor.specDescription
                    )
                    DSSpecificationRow(title: "Text Font", value: specification.textFont.specName)
                    DSSpecificationRow(title: "Text Color", value: specification.textColor.specDescription)
                    if let clearButtonIcon = specification.clearButtonIcon,
                       let clearButtonSize = specification.clearButtonSize,
                       let clearButtonColor = specification.clearButtonColor {
                        DSSpecificationRow(title: "Clear Icon", value: clearButtonIcon.specDescription)
                        DSSpecificationRow(title: "Clear Icon Size", value: clearButtonSize.ptDescription)
                        DSSpecificationRow(title: "Clear Icon Color", value: clearButtonColor.specDescription)
                    }
                    DSSpecificationRow(title: "Chevron Icon", value: specification.chevronIcon.specDescription)
                    DSSpecificationRow(title: "Chevron Size", value: specification.chevronSize.ptDescription)
                    DSSpecificationRow(title: "Chevron Color", value: specification.chevronColor.specDescription)
                    DSSpecificationRow(
                        title: "Chevron Rotation",
                        value: "\(Int(specification.chevronRotationDegrees))deg"
                    )
                }
            }
        }
        .navigationTitle("DSSelectField")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hasSelectionBinding: Binding<Bool> {
        Binding(
            get: { selectedValue != nil },
            set: { hasSelection in
                selectedValue = hasSelection ? "선택 완료 텍스트" : nil
            }
        )
    }
}

#Preview {
    NavigationStack {
        SelectFieldPlaygroundView()
    }
}
