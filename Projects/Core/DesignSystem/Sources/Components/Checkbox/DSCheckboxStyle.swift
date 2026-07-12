import SwiftUI

// MARK: - Checkbox Toggle Style
public struct DSCheckboxStyle: ToggleStyle {
    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            ZStack {
                // Background & Border
                RoundedRectangle(cornerRadius: DSCheckbox.Layout.cornerRadius)
                    .fill(configuration.isOn ? DesignSystemAsset.Colors.primary600.swiftUIColor : DesignSystemAsset.Colors.white.swiftUIColor)
                    .frame(width: DSCheckbox.Layout.size, height: DSCheckbox.Layout.size)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSCheckbox.Layout.cornerRadius)
                            .strokeBorder(
                                configuration.isOn ? Color.clear : DesignSystemAsset.Colors.coolGray300.swiftUIColor,
                                lineWidth: DSCheckbox.Layout.borderWidth
                            )
                    )
                
                // Checkmark Icon
                if configuration.isOn {
                    Image.ds.checkLine
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(DesignSystemAsset.Colors.white.swiftUIColor)
                        .frame(width: DSCheckbox.Layout.iconSize, height: DSCheckbox.Layout.iconSize)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
