import SwiftUI
import DesignSystem

struct TogglePlaygroundView: View {
    @State private var isOn: Bool = false
    @State private var isDarkBackground: Bool = false

    private var specification: DSToggle.Specification {
        DSToggle.specification(isOn: isOn)
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(title: String(describing: DSToggle.self), isDarkBackground: $isDarkBackground) {
                DSToggle(isOn: $isOn)
            }

            Form {
                Section(header: Text("Interactive State")) {
                    Toggle("Is On (선택 상태)", isOn: $isOn)
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Size (W × H)", value: specification.size.ptDescription)
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(title: "Background", value: specification.backgroundAsset.specDescription)
                    DSSpecificationRow(title: "Handle Size (W × H)", value: specification.handleSize.squarePtDescription)
                    DSSpecificationRow(title: "Handle Shape", value: specification.handleShape.specName)
                    DSSpecificationRow(title: "Padding", value: specification.padding.ptDescription)
                    DSSpecificationRow(title: "Handle Color", value: specification.handleAsset.specDescription)
                }
            }
        }
        .navigationTitle("DSToggle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TogglePlaygroundView()
    }
}
