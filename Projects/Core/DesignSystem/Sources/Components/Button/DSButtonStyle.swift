import SwiftUI

struct DSButtonStyle: ButtonStyle {
    let specification: DSButton.Specification

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsFont(specification.fontStyle)
            .foregroundStyle(specification.foregroundAsset.swiftUIColor)
            .frame(height: specification.height)
            .padding(.horizontal, specification.horizontalPadding)
            .background(specification.backgroundAsset.swiftUIColor)
            .clipShape(specification.shape.swiftUIShape)
    }
}
