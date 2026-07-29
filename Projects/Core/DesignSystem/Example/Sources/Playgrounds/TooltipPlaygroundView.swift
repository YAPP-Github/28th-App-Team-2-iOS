import SwiftUI
import DesignSystem

struct TooltipPlaygroundView: View {
    @State private var message: String = "오늘 이 사람과 어디를 갈까?"
    @State private var isDarkBackground: Bool = false

    private let specification = DSTooltip.specification()

    private var arrowFrameDescription: String {
        "\(specification.arrowFrameWidth.ptDescription) × \(specification.arrowHeight.ptDescription)"
    }

    private var lineLimitDescription: String {
        specification.lineLimit.map(String.init) ?? "Unlimited"
    }

    private var textAlignmentDescription: String {
        String(describing: specification.textAlignment).capitalized
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSTooltip.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSTooltip(message)
                    .padding(.horizontal, 20)
            }

            Form {
                Section(header: Text("Content")) {
                    TextField("Tooltip message", text: $message)
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(
                        title: "Minimum Bubble Height",
                        value: specification.minimumBubbleHeight.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Horizontal Padding",
                        value: specification.horizontalPadding.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Vertical Padding",
                        value: specification.verticalPadding.ptDescription
                    )
                    DSSpecificationRow(title: "Line Limit", value: lineLimitDescription)
                    DSSpecificationRow(title: "Text Alignment", value: textAlignmentDescription)
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(title: "Typography", value: specification.fontStyle.specName)
                    DSSpecificationRow(
                        title: "Background",
                        value: specification.backgroundAsset.specDescription
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
                    DSSpecificationRow(
                        title: "Arrow Tint",
                        value: specification.arrowTintAsset.specDescription
                    )
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
