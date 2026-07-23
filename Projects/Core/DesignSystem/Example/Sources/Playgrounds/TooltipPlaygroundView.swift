import SwiftUI
import DesignSystem

struct TooltipPlaygroundView: View {
    @State private var message: String = "오늘 이 사람과 어디를 갈까?"
    @State private var isDarkBackground: Bool = false

    private let specification = DSTooltip.specification()

    private var backgroundDescription: String {
        let opacity = Int(specification.backgroundOpacity * 100)
        return "\(specification.backgroundAsset.specDescription) / \(opacity)%"
    }

    private var arrowFrameDescription: String {
        "\(specification.arrowFrameWidth.ptDescription) × \(specification.arrowHeight.ptDescription)"
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSTooltip.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSTooltip(message)
            }

            Form {
                Section(header: Text("Content")) {
                    TextField("Tooltip message", text: $message)
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Bubble Height", value: specification.bubbleHeight.ptDescription)
                    DSSpecificationRow(
                        title: "Vertical Padding",
                        value: specification.verticalPadding.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Horizontal Padding",
                        value: specification.horizontalPadding.ptDescription
                    )
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(title: "Typography", value: specification.fontStyle.specName)
                    DSSpecificationRow(
                        title: "Background",
                        value: backgroundDescription
                    )
                    DSSpecificationRow(
                        title: "Foreground",
                        value: specification.foregroundAsset.specDescription
                    )
                    DSSpecificationRow(
                        title: "Arrow Frame",
                        value: arrowFrameDescription
                    )
                    DSSpecificationRow(title: "Arrow Asset", value: specification.arrowAsset.name)
                }
            }
        }
        .navigationTitle("DSTooltip")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TooltipPlaygroundView()
    }
}
