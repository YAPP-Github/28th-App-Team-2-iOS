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

    private var specification: DSButton.Specification {
        DSButton.specification(
            variant: selectedVariant,
            size: selectedSize,
            isEnabled: isEnabled
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            buttonPreview

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
                    DSSpecificationRow(title: "Height", value: specification.height.ptDescription)
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(
                        title: "Padding (Horizontal)",
                        value: specification.horizontalPadding.ptDescription
                    )
                    DSSpecificationRow(title: "Gap (Icon-Text)", value: specification.contentGap.ptDescription)
                    DSSpecificationRow(title: "Typography", value: specification.fontStyle.specName)
                    DSSpecificationRow(
                        title: "Icon Size (When Present)",
                        value: specification.iconSize.squarePtDescription
                    )
                    DSSpecificationRow(title: "Bg Color", value: specification.backgroundAsset.specDescription)
                    DSSpecificationRow(title: "Text Color", value: specification.foregroundAsset.specDescription)
                }
            }
        }
        .navigationTitle("Button Playground")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var buttonPreview: some View {
        let left = showLeftIcon ? Image.ds.edit : nil
        let right = showRightIcon ? Image.ds.edit : nil

        switch (selectedVariant, selectedSize) {
        case (.primary, .large):
            preview(DSPrimaryLargeButton(buttonText, leftIcon: left, rightIcon: right) {})
        case (.primary, .medium):
            preview(DSPrimaryMediumButton(buttonText, leftIcon: left, rightIcon: right) {})
        case (.primary, .small):
            preview(DSPrimarySmallButton(buttonText, leftIcon: left, rightIcon: right) {})
        case (.secondary, .large):
            preview(DSSecondaryLargeButton(buttonText, leftIcon: left, rightIcon: right) {})
        case (.secondary, .medium):
            preview(DSSecondaryMediumButton(buttonText, leftIcon: left, rightIcon: right) {})
        case (.secondary, .small):
            preview(DSSecondarySmallButton(buttonText, leftIcon: left, rightIcon: right) {})
        }
    }

    private func preview<Component: View>(_ component: Component) -> some View {
        DSPlaygroundPreviewCard(
            title: String(describing: Component.self),
            isDarkBackground: $isDarkBackground
        ) {
            component
                .disabled(!isEnabled)
        }
    }
}
