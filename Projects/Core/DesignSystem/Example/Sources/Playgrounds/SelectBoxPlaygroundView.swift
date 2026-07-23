import SwiftUI
import DesignSystem

struct SelectBoxPlaygroundView: View {
    @State private var title: String = "남성"
    @State private var isSelected: Bool = false
    @State private var isDarkBackground: Bool = false
    @State private var containerWidth: Double = 168.5

    private var specification: DSSelectBox.Specification {
        DSSelectBox.specification(isSelected: isSelected)
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSSelectBox.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSSelectBox(title, isSelected: $isSelected)
                    .frame(width: containerWidth)
            }

            Form {
                Section(header: Text("Content & State")) {
                    TextField("SelectBox title", text: $title)
                    Toggle("Is Selected", isOn: $isSelected)
                    VStack(alignment: .leading) {
                        Text("Parent Width: \(containerWidth, specifier: "%.1f")pt")
                        Slider(value: $containerWidth, in: 120...340, step: 0.5)
                    }
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Height", value: specification.height.ptDescription)
                    DSSpecificationRow(
                        title: "Horizontal Padding",
                        value: specification.horizontalPadding.ptDescription
                    )
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(title: "Border Width", value: specification.borderWidth.ptDescription)
                    DSSpecificationRow(title: "Typography", value: specification.fontStyle.specName)
                    DSSpecificationRow(
                        title: "Background",
                        value: specification.backgroundAsset.specDescription
                    )
                    DSSpecificationRow(title: "Border", value: specification.borderAsset.specDescription)
                    DSSpecificationRow(
                        title: "Foreground",
                        value: specification.foregroundAsset.specDescription
                    )
                }
            }
        }
        .navigationTitle("DSSelectBox")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SelectBoxPlaygroundView()
    }
}
