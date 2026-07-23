import SwiftUI

struct DSSelectBoxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        let specification = DSSelectBox.specification(isSelected: configuration.isOn)

        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
                .dsFont(specification.fontStyle)
                .foregroundStyle(specification.foregroundAsset.swiftUIColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, specification.horizontalPadding)
                .frame(
                    maxWidth: .infinity,
                    minHeight: specification.height,
                    maxHeight: specification.height
                )
                .background(specification.backgroundAsset.swiftUIColor)
                .clipShape(specification.shape.swiftUIShape)
                .overlay {
                    specification.shape.strokeBorder(
                        specification.borderAsset.swiftUIColor,
                        lineWidth: specification.borderWidth
                    )
                }
        }
        .buttonStyle(.plain)
    }
}
