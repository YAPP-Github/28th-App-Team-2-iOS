import SwiftUI
import DesignSystem

struct TodakHeaderPlaygroundView: View {
    @State private var remainingFreeChatCount: Int = 2
    @State private var lastTappedButton: String = "아직 눌린 버튼이 없습니다."
    @State private var isDarkBackground: Bool = false
    private let freeChatLimit = 3

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSTodakHeader.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSTodakHeader(
                    remainingFreeChatCount: remainingFreeChatCount,
                    freeChatLimit: freeChatLimit,
                    rightItems: [
                        DSHeaderActionItem(identifier: "newChat", icon: .chatAdd) {
                            lastTappedButton = "우측 새 채팅 버튼"
                        },
                        DSHeaderActionItem(identifier: "notes", icon: .notes) {
                            lastTappedButton = "우측 기록/노트 버튼"
                        }
                    ],
                    onClose: {
                        lastTappedButton = "좌측 닫기 버튼"
                    }
                )
            }

            Form {
                Section(header: Text("Interactive State")) {
                    Stepper(
                        "오늘 무료 채팅: \(remainingFreeChatCount)/\(freeChatLimit)",
                        value: $remainingFreeChatCount,
                        in: 0...freeChatLimit
                    )

                    Text(lastTappedButton)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Figma Specification Check")) {
                    let spec = DSTodakHeader.specification()

                    DSSpecificationRow(title: "Background", value: spec.backgroundAsset.specDescription)
                    DSSpecificationRow(title: "Content Height", value: spec.contentHeight.ptDescription)
                    DSSpecificationRow(title: "Horizontal Padding", value: spec.horizontalPadding.ptDescription)
                    DSSpecificationRow(title: "Icon Size", value: spec.iconSize.ptDescription)
                    DSSpecificationRow(title: "Left Icon", value: spec.leftIconAsset.specDescription)
                    DSSpecificationRow(title: "Left Icon Tint", value: spec.leftIconTintAsset.specDescription)
                    DSSpecificationRow(title: "Right Icon Gap", value: spec.rightIconGap.ptDescription)
                    DSSpecificationRow(title: "Right Icon Tint", value: spec.rightIconTintAsset.specDescription)
                    DSSpecificationRow(title: "Title Font", value: spec.titleFontStyle.specName)
                    DSSpecificationRow(title: "Title Text", value: spec.titleTextAsset.specDescription)
                    DSSpecificationRow(title: "Subtitle Font", value: spec.subtitleFontStyle.specName)
                    DSSpecificationRow(title: "Subtitle Text", value: spec.subtitleTextAsset.specDescription)
                    DSSpecificationRow(title: "Remaining Count Font", value: spec.remainingCountFontStyle.specName)
                    DSSpecificationRow(
                        title: "Remaining Count Text",
                        value: spec.remainingCountTextAsset.specDescription
                    )
                }
            }
        }
        .navigationTitle("DSTodakHeader")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TodakHeaderPlaygroundView()
    }
}
