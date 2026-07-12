import SwiftUI
import DesignSystem

// MARK: - Badge Playground Sandbox
struct BadgePlaygroundView: View {
    @State private var badgeText: String = "관계"
    @State private var selectedVariant: DSBadgeVariant = .purple
    @State private var isDarkBackground: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 🔍 1. 상단 실시간 프리뷰 영역
            DSPlaygroundPreviewCard(
                title: String(describing: DSBadge.self),
                isDarkBackground: $isDarkBackground
            ) {
                HStack(spacing: DSBadge.Layout.defaultGap) {
                    DSBadge(badgeText, variant: selectedVariant)
                    DSBadge(badgeText, variant: selectedVariant)
                }
                .id("\(selectedVariant)-\(badgeText)")
            }
            
            // 🛠️ 2. 하단 컨트롤러 영역
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
                    DSSpecificationRow(title: "Corner Radius", value: "\(Int(DSBadge.Layout.cornerRadius))px")
                    DSSpecificationRow(title: "Padding (Vertical)", value: "\(Int(DSBadge.Layout.verticalPadding))px")
                    DSSpecificationRow(title: "Padding (Horizontal)", value: "\(Int(DSBadge.Layout.horizontalPadding))px")
                    DSSpecificationRow(title: "Gap / Spacing", value: "\(Int(DSBadge.Layout.defaultGap))px")
                    DSSpecificationRow(title: "Typography", value: DSBadge.Theme.fontStyle.specName)
                    DSSpecificationRow(title: "Bg Color", value: "\(selectedVariant.bgAsset.displayName) (\(selectedVariant.bgAsset.color.hexString))")
                    DSSpecificationRow(title: "Text Color", value: "\(selectedVariant.textAsset.displayName) (\(selectedVariant.textAsset.color.hexString))")
                }
            }
        }
        .navigationTitle("Badge Playground")
        .navigationBarTitleDisplayMode(.inline)
    }
}
