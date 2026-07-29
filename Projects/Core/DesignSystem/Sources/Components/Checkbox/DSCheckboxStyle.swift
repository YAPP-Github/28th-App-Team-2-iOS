import SwiftUI

struct DSCheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        let specification = DSCheckbox.specification(isOn: configuration.isOn)

        Button {
            configuration.isOn.toggle()
        } label: {
            ZStack {
                specification.shape.swiftUIShape
                    .fill(specification.backgroundAsset.swiftUIColor)
                    .frame(width: specification.size, height: specification.size)
                    .overlay {
                        if let borderAsset = specification.borderAsset,
                           let borderWidth = specification.borderWidth {
                            specification.shape.strokeBorder(
                                borderAsset.swiftUIColor,
                                lineWidth: borderWidth
                            )
                        }
                    }

                if let iconAsset = specification.iconAsset,
                   let iconTintAsset = specification.iconTintAsset,
                   let iconSize = specification.iconSize {
                    iconAsset.swiftUIImage
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(iconTintAsset.swiftUIColor)
                        .frame(
                            width: iconSize,
                            height: iconSize
                        )
                        .dsDebugDetailGeometry("DSCheckbox.Icon")
                }
            }
        }
        .buttonStyle(DSCheckboxButtonStyle(specification: specification))
    }
}

private struct DSCheckboxButtonStyle: ButtonStyle {
    let specification: DSCheckbox.Specification

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsPressedOverlay(
                isPressed: configuration.isPressed,
                shape: specification.shape,
                specification: specification.pressedOverlay
            )
            .clipShape(specification.shape.swiftUIShape)
    }
}
