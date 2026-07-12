import SwiftUI
import DesignSystem

public struct CheckboxPlaygroundView: View {
    @State private var isOn: Bool = false
    @State private var isDarkBackground: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // 1. Preview Area
            DSPlaygroundPreviewCard(title: String(describing: DSCheckbox.self), isDarkBackground: $isDarkBackground) {
                DSCheckbox(isOn: $isOn)
                
                Text(isOn ? "상태: Checked" : "상태: Unchecked")
                    .font(.caption)
                    .foregroundColor(DesignSystemAsset.Colors.coolGray500.swiftUIColor)
                    .padding(.top, 10)
            }
            
            // 2. Specification Area
            Form {
                Section(header: Text("Interactive State")) {
                    Toggle("Is On (선택 상태)", isOn: $isOn)
                }
                
                Section(header: Text("Figma Specification Check")) {
                            DSSpecificationRow(title: "Size (W x H)", value: "\(Int(DSCheckbox.Layout.size))px")
                            DSSpecificationRow(title: "Corner Radius", value: "\(Int(DSCheckbox.Layout.cornerRadius))px")
                            DSSpecificationRow(title: "Border Width", value: "\(Int(DSCheckbox.Layout.borderWidth))px")
                            
                            DSSpecificationRow(title: "Background", value: isOn ? "primary600" : "white")
                            if !isOn {
                                DSSpecificationRow(title: "Border Width", value: "1px")
                                DSSpecificationRow(title: "Border Color", value: "coolGray300")
                            }
                            if isOn {
                                DSSpecificationRow(title: "Icon Color", value: "white")
                            }
                }
            }
        }
        .navigationTitle("DSCheckbox")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        CheckboxPlaygroundView()
    }
}
