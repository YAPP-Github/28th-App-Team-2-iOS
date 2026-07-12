import SwiftUI
import DesignSystem

// MARK: - Chip Playground Sandbox
struct ChipPlaygroundView: View {
    enum ChipType: String, CaseIterable {
        case chip1 = "DSChip"
        case chip2 = "DSChip2"
    }
    
    @State private var chipType: ChipType = .chip1
    @State private var chipText: String = "학생"
    @State private var isSelected: Bool = false
    @State private var isDarkBackground: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 🔍 1. 상단 실시간 프리뷰 영역
            let currentChip = makeChip(title: chipText, isSelected: isSelected)
            
            DSPlaygroundPreviewCard(
                title: String(describing: type(of: currentChip)),
                height: 260,
                isDarkBackground: $isDarkBackground
            ) {
                // 피그마 gap: 10px 칩간 레이아웃 나열 실증 검증 (실시간 반영 2개 연속 배치)
                HStack(spacing: 10) { // 칩 간 Spacing 10pt 반영
                    if chipType == .chip1 {
                        DSChip(chipText, isSelected: isSelected) {}
                        DSChip(chipText, isSelected: isSelected) {}
                    } else {
                        DSChip2(chipText) {}
                        DSChip2(chipText) {}
                    }
                }
                .id("\(chipType)-\(isSelected)-\(chipText)") // 강제 리프레시 ID 체인
            }
            
            // 🛠️ 2. 하단 컨트롤러 영역
            Form {
                Section(header: Text("Chip Type")) {
                    Picker("Type", selection: $chipType) {
                        Text("DSChip (Interactive)").tag(ChipType.chip1)
                        Text("DSChip2 (Badge)").tag(ChipType.chip2)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Chip Text")) {
                    TextField("Enter chip text...", text: $chipText)
                        .autocorrectionDisabled()
                }
                
                if chipType == .chip1 {
                    Section(header: Text("Interactive State")) {
                        Toggle("Is Selected (선택 상태)", isOn: $isSelected)
                    }
                }
                
                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Corner Radius", value: "Capsule (Radius \(Int(cornerRadiusSpec))px)")
                    DSSpecificationRow(title: "Padding (Vertical)", value: "\(Int(verticalPaddingSpec))px")
                    DSSpecificationRow(title: "Padding (Horizontal)", value: "\(Int(horizontalPaddingSpec))px")
                    DSSpecificationRow(title: "Gap / Spacing (칩 간격)", value: "\(Int(gapSpec))px")
                    DSSpecificationRow(title: "Typography", value: fontDescription)
                    DSSpecificationRow(title: "Bg Color", value: bgColorDescription)
                    DSSpecificationRow(title: "Text Color", value: textColorDescription)
                }
            }
        }
        .navigationTitle("Chip Playground")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var cornerRadiusSpec: CGFloat { chipType == .chip1 ? DSChip.Layout.cornerRadius : DSChip2.Layout.cornerRadius }
    private var verticalPaddingSpec: CGFloat { chipType == .chip1 ? DSChip.Layout.verticalPadding : DSChip2.Layout.verticalPadding }
    private var horizontalPaddingSpec: CGFloat { chipType == .chip1 ? DSChip.Layout.horizontalPadding : DSChip2.Layout.horizontalPadding }
    private var gapSpec: CGFloat { chipType == .chip1 ? DSChip.Layout.defaultGap : DSChip2.Layout.defaultGap }
    
    private var bgColorDescription: String {
        let asset = chipType == .chip1 ? DSChip.Theme.bgAsset(isSelected: isSelected) : DSChip2.Theme.bgAsset
        return "\(asset.displayName) (\(asset.color.hexString))"
    }
    
    private var textColorDescription: String {
        let asset = chipType == .chip1 ? DSChip.Theme.textAsset(isSelected: isSelected) : DSChip2.Theme.textAsset
        return "\(asset.displayName) (\(asset.color.hexString))"
    }
    
    private var fontDescription: String {
        let style = chipType == .chip1 ? DSChip.Theme.fontStyle(isSelected: isSelected) : DSChip2.Theme.fontStyle
        return style.specName
    }
    
    private func makeChip(title: String, isSelected: Bool) -> Any {
        if chipType == .chip1 {
            return DSChip(title, isSelected: isSelected) {}
        } else {
            return DSChip2(title) {}
        }
    }
}
