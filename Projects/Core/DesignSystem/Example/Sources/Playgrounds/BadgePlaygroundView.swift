import SwiftUI
import DesignSystem

// MARK: - Badge Playground Sandbox
struct BadgePlaygroundView: View {
    @State private var badgeText: String = "관계"
    @State private var selectedVariant: DSBadgeVariant = .purple
    @State private var isDarkBackground: Bool = false

    private var specification: DSBadge.Specification {
        DSBadge.specification(variant: selectedVariant)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSBadge.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSBadge(badgeText, variant: selectedVariant)
            }

            Form {
                Section(header: Text("Badge Text")) {
                    TextField("Enter badge text...", text: $badgeText)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("Variant")) {
                    Picker("Variant", selection: $selectedVariant) {
                        ForEach(DSBadgeVariant.allCases, id: \.self) { variant in
                            Text(variant.rawValue.capitalized).tag(variant)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(title: "Padding (Vertical)", value: specification.verticalPadding.ptDescription)
                    DSSpecificationRow(title: "Padding (Horizontal)", value: specification.horizontalPadding.ptDescription)
                    DSSpecificationRow(title: "Typography", value: specification.fontStyle.specName)
                    DSSpecificationRow(title: "Bg Color", value: specification.backgroundAsset.specDescription)
                    DSSpecificationRow(title: "Text Color", value: specification.foregroundAsset.specDescription)
                }
            }
        }
        .navigationTitle("Badge Playground")
        .navigationBarTitleDisplayMode(.inline)
    }
}
