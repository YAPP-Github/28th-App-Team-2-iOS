import SwiftUI
import DesignSystem

struct CheckboxPlaygroundView: View {
    @State private var isOn: Bool = false
    @State private var isDarkBackground: Bool = false

    private var specification: DSCheckbox.Specification {
        DSCheckbox.specification(isOn: isOn)
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(title: String(describing: DSCheckbox.self), isDarkBackground: $isDarkBackground) {
                DSCheckbox(isOn: $isOn)
            }

            Form {
                Section(header: Text("Interactive State")) {
                    Toggle("Is On (선택 상태)", isOn: $isOn)
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Size (W × H)", value: specification.size.squarePtDescription)
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(title: "Border Width", value: specification.borderWidth?.ptDescription ?? "None")
                    DSSpecificationRow(title: "Icon Size", value: specification.iconSize?.squarePtDescription ?? "None")
                    DSSpecificationRow(title: "Background", value: specification.backgroundAsset.specDescription)
                    DSSpecificationRow(
                        title: "Border Color",
                        value: specification.borderAsset?.specDescription ?? "None"
                    )
                    DSSpecificationRow(title: "Icon", value: specification.iconAsset?.displayName ?? "None")
                    DSSpecificationRow(
                        title: "Icon Color",
                        value: specification.iconTintAsset?.specDescription ?? "None"
                    )
                }
            }
        }
        .navigationTitle("DSCheckbox")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CheckboxPlaygroundView()
    }
}
