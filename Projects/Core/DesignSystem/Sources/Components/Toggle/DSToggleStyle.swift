import SwiftUI

struct DSToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        let specification = DSToggle.specification(isOn: configuration.isOn)

        Button {
            configuration.isOn.toggle()
        } label: {
            specification.shape.swiftUIShape
                .fill(specification.backgroundAsset.swiftUIColor)
                .frame(width: specification.size.width, height: specification.size.height)
                .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                    specification.handleShape.swiftUIShape
                        .fill(specification.handleAsset.swiftUIColor)
                        .frame(width: specification.handleSize, height: specification.handleSize)
                        .dsDebugDetailGeometry("DSToggle.Handle")
                        .padding(specification.padding)
                }
        }
        .buttonStyle(.plain)
    }
}
