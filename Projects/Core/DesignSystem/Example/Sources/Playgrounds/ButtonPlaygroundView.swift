import SwiftUI
import DesignSystem

// MARK: - Button Playground Sandbox
struct ButtonPlaygroundView: View {
    @State private var buttonText: String = "다음 단계"
    @State private var selectedVariant: DSButtonVariant = .primary
    @State private var selectedSize: DSButtonSize = .large
    @State private var isEnabled: Bool = true
    @State private var showLeftIcon: Bool = false
    @State private var showRightIcon: Bool = false
    @State private var isDarkBackground: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 🔍 1. 상단 실시간 프리뷰 영역
            let currentButton = makeButton(title: buttonText)
            
            DSPlaygroundPreviewCard(
                title: String(describing: type(of: currentButton)),
                isDarkBackground: $isDarkBackground
            ) {
                if let buttonView = currentButton as? any View {
                    AnyView(buttonView)
                        .disabled(!isEnabled)
                        .id("\(selectedVariant)-\(selectedSize)-\(isEnabled)-\(showLeftIcon)-\(showRightIcon)-\(buttonText)")
                }
            }
            
            // 🛠️ 2. 하단 컨트롤러 영역
            Form {
                Section(header: Text("Button Text")) {
                    TextField("Enter button text...", text: $buttonText)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("Style Properties")) {
                    Picker("Variant", selection: $selectedVariant) {
                        Text("Primary").tag(DSButtonVariant.primary)
                        Text("Secondary").tag(DSButtonVariant.secondary)
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Size", selection: $selectedSize) {
                        Text("Large").tag(DSButtonSize.large)
                        Text("Medium").tag(DSButtonSize.medium)
                        Text("Small").tag(DSButtonSize.small)
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Interactive State")) {
                    Toggle("Is Enabled (활성 상태)", isOn: $isEnabled)
                    Toggle("Show Left Icon (왼쪽 아이콘)", isOn: $showLeftIcon)
                    Toggle("Show Right Icon (오른쪽 아이콘)", isOn: $showRightIcon)
                }
                
                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Height", value: "\(Int(selectedSize.height))pt")
                    DSSpecificationRow(title: "Corner Radius", value: "\(Int(DSButton.Layout.cornerRadius))pt")
                    DSSpecificationRow(title: "Padding (Horizontal)", value: "\(Int(DSButton.Layout.horizontalPadding))pt")
                    DSSpecificationRow(title: "Gap (Icon-Text)", value: "\(Int(DSButton.Layout.contentGap))pt")
                    DSSpecificationRow(title: "Typography", value: fontDescription)
                    DSSpecificationRow(title: "Icon Size", value: iconSizeDescription)
                    DSSpecificationRow(title: "Bg Color", value: bgColorDescription)
                    DSSpecificationRow(title: "Text Color", value: textColorDescription)
                }
            }
        }
        .navigationTitle("Button Playground")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func makeButton(title: String) -> Any {
        let left = showLeftIcon ? Image.ds.edit : nil
        let right = showRightIcon ? Image.ds.edit : nil
        
        switch (selectedVariant, selectedSize) {
        case (.primary, .large):
            return DSPrimaryLargeButton(title, leftIcon: left, rightIcon: right) {}
        case (.primary, .medium):
            return DSPrimaryMediumButton(title, leftIcon: left, rightIcon: right) {}
        case (.primary, .small):
            return DSPrimarySmallButton(title, leftIcon: left, rightIcon: right) {}
        case (.secondary, .large):
            return DSSecondaryLargeButton(title, leftIcon: left, rightIcon: right) {}
        case (.secondary, .medium):
            return DSSecondaryMediumButton(title, leftIcon: left, rightIcon: right) {}
        case (.secondary, .small):
            return DSSecondarySmallButton(title, leftIcon: left, rightIcon: right) {}
        }
    }
    
    private var iconSizeDescription: String {
        guard showLeftIcon || showRightIcon else { return "None" }
        let sizeInt = Int(selectedSize.iconSize)
        return "\(sizeInt)x\(sizeInt)pt"
    }
    
    private var fontDescription: String {
        selectedSize.specFontName(isEnabled: isEnabled)
    }
    
    private var bgColorDescription: String {
        selectedVariant.specBgColorName(isEnabled: isEnabled)
    }
    
    private var textColorDescription: String {
        selectedVariant.specTextColorName(isEnabled: isEnabled)
    }
}
