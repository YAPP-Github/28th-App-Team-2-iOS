import SwiftUI

struct DSButtonStyle: ButtonStyle {
    let specification: DSButton.Specification

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(specification.foregroundAsset.swiftUIColor)
            .padding(.horizontal, specification.horizontalPadding)
            .frame(maxWidth: .infinity)
            .frame(height: specification.height)
            .background(specification.backgroundAsset.swiftUIColor)
            .clipShape(specification.shape.swiftUIShape)
    }
}
