import SwiftUI
import DesignSystem

struct DividerPlaygroundView: View {
    @State private var selectedSize: DSDividerSize = .thin
    @State private var isDarkBackground: Bool = true

    private var specification: DSDivider.Specification {
        DSDivider.specification(size: selectedSize)
    }

    var body: some View {
        VStack(spacing: 0) {
            dividerPreview

            Form {
                Section(header: Text("Style Properties")) {
                    Picker("Size", selection: $selectedSize) {
                        Text("Thin (1pt)").tag(DSDividerSize.thin)
                        Text("Thick (10pt)").tag(DSDividerSize.thick)
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Thickness", value: specification.thickness.ptDescription)
                    DSSpecificationRow(title: "Color", value: specification.colorAsset.specDescription)
                }
            }
        }
        .navigationTitle("DSDivider")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var dividerPreview: some View {
        switch selectedSize {
        case .thin:
            DSPlaygroundPreviewCard(
                title: String(describing: DSThinDivider.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSThinDivider()
            }
        case .thick:
            DSPlaygroundPreviewCard(
                title: String(describing: DSThickDivider.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSThickDivider()
            }
        }
    }
}

#Preview {
    NavigationStack {
        DividerPlaygroundView()
    }
}
