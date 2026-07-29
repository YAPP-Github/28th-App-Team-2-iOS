import SwiftUI
import DesignSystem

struct PopoverPlaygroundView: View {
    @State private var selectedItem: String = "선택 전"
    @State private var isDarkBackground: Bool = false

    private let specification = DSPopover.specification()

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSPopover.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSPopover(
                    items: [
                        DSPopoverItem(
                            title: "수정하기",
                            action: { selectedItem = "수정" }
                        ),
                        DSPopoverItem(
                            title: "삭제하기",
                            action: { selectedItem = "삭제" }
                        )
                    ]
                )
            }

            Form {
                Section(header: Text("Content & Interaction")) {
                    DSSpecificationRow(title: "Selected Item", value: selectedItem)
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(
                        title: "Minimum Item Width",
                        value: specification.minimumItemWidth.ptDescription
                    )
                    DSSpecificationRow(title: "Item Height", value: specification.itemHeight.ptDescription)
                    DSSpecificationRow(
                        title: "Container Padding",
                        value: specification.containerPadding.ptDescription
                    )
                    DSSpecificationRow(title: "Item Spacing", value: specification.itemSpacing.ptDescription)
                    DSSpecificationRow(
                        title: "Content Horizontal Padding",
                        value: specification.contentHorizontalPadding.ptDescription
                    )
                    DSSpecificationRow(title: "Container Shape", value: specification.containerShape.specName)
                    DSSpecificationRow(title: "Item Shape", value: specification.itemShape.specName)
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
                        title: "Pressed Overlay",
                        value: specification.pressedOverlay.specDescription
                    )
                    DSSpecificationRow(
                        title: "Intrinsic Shadow",
                        value: "\(specification.shadowRadius.ptDescription), \(Int(specification.shadowOpacity * 100))%"
                    )
                }
            }
        }
        .navigationTitle("DSPopover")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PopoverPlaygroundView()
    }
}
