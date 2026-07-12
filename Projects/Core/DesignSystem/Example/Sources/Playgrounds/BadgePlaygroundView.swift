import SwiftUI
import DesignSystem

// MARK: - Badge Playground Sandbox
struct BadgePlaygroundView: View {
    @State private var badgeText: String = "관계"
    @State private var selectedVariant: DSBadgeVariant = .purple
    
    var body: some View {
        VStack(spacing: 0) {
            // 🔍 1. 상단 실시간 프리뷰 영역
            VStack {
                Spacer()
                
                Text(String(describing: DSBadge.self))
                    .font(.system(.caption2, design: .monospaced))
                    .bold()
                    .foregroundColor(Color.ds.primary700)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.ds.primary50)
                    .cornerRadius(6)
                    .padding(.bottom, 12)
                
                HStack(spacing: DSBadge.Layout.defaultGap) {
                    DSBadge(badgeText, variant: selectedVariant)
                    DSBadge(badgeText, variant: selectedVariant)
                }
                .id("\(selectedVariant)-\(badgeText)")
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(Color.ds.white)
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            
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
                    specificationRow(title: "Corner Radius", value: "\(Int(DSBadge.Layout.cornerRadius))px")
                    specificationRow(title: "Padding (Vertical)", value: "\(Int(DSBadge.Layout.verticalPadding))px")
                    specificationRow(title: "Padding (Horizontal)", value: "\(Int(DSBadge.Layout.horizontalPadding))px")
                    specificationRow(title: "Gap / Spacing", value: "\(Int(DSBadge.Layout.defaultGap))px")
                    specificationRow(title: "Typography", value: DSBadge.Theme.fontStyle.specName)
                    specificationRow(title: "Bg Color", value: "\(selectedVariant.bgAsset.displayName) (\(selectedVariant.bgAsset.color.hexString))")
                    specificationRow(title: "Text Color", value: "\(selectedVariant.textAsset.displayName) (\(selectedVariant.textAsset.color.hexString))")
                }
            }
        }
        .navigationTitle("Badge Playground")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func specificationRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
        }
        .font(.footnote)
    }
}
