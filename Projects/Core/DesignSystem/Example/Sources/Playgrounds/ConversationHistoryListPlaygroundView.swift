import SwiftUI
import DesignSystem

struct ConversationHistoryListPlaygroundView: View {
    @State private var title = "오늘 나의 행운의 숫자는?"
    @State private var time = "30분 전"
    @State private var showsUnreadIndicator = true
    @State private var lastAction = "삭제 전"
    @State private var isDarkBackground = false

    var body: some View {
        let specification = DSConversationHistoryList.specification

        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSConversationHistoryList.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSConversationHistoryList(
                    title: title,
                    time: time,
                    showsUnreadIndicator: showsUnreadIndicator
                ) {
                    lastAction = "Delete"
                }
                .frame(maxWidth: 393)
            }

            Form {
                Section(header: Text("Content & Interaction")) {
                    TextField("Title", text: $title)
                    TextField("Time", text: $time)
                    Toggle("Unread Indicator", isOn: $showsUnreadIndicator)
                    DSSpecificationRow(title: "Last Action", value: lastAction)
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Content Width", value: specification.contentWidth.ptDescription)
                    DSSpecificationRow(
                        title: "Horizontal Padding",
                        value: specification.horizontalPadding.ptDescription
                    )
                    DSSpecificationRow(title: "Top Padding", value: specification.topPadding.ptDescription)
                    DSSpecificationRow(title: "Bottom Padding", value: specification.bottomPadding.ptDescription)
                    DSSpecificationRow(title: "Title Font", value: specification.titleFont.specName)
                    DSSpecificationRow(title: "Title Color", value: specification.titleColorAsset.specDescription)
                    DSSpecificationRow(title: "Title Line Limit", value: "\(specification.titleLineLimit)")
                    DSSpecificationRow(
                        title: "Title Truncation Mode",
                        value: String(describing: specification.titleTruncationMode)
                    )
                    DSSpecificationRow(
                        title: "Title Indicator Width",
                        value: specification.titleIndicatorWidth.ptDescription
                    )
                    DSSpecificationRow(title: "Unread Indicator Size", value: specification.indicatorSize.ptDescription)
                    DSSpecificationRow(
                        title: "Unread Indicator Color",
                        value: specification.indicatorColorAsset.specDescription
                    )
                    DSSpecificationRow(
                        title: "Title Indicator Spacing",
                        value: specification.titleIndicatorSpacing.ptDescription
                    )
                    DSSpecificationRow(title: "Delete Icon", value: specification.deleteIcon.specDescription)
                    DSSpecificationRow(title: "Delete Icon Size", value: specification.deleteIconSize.ptDescription)
                    DSSpecificationRow(
                        title: "Delete Icon Color",
                        value: specification.deleteIconColorAsset.specDescription
                    )
                    DSSpecificationRow(
                        title: "Title Delete Spacing",
                        value: specification.titleDeleteSpacing.ptDescription
                    )
                    DSSpecificationRow(title: "Time Font", value: specification.timeFont.specName)
                    DSSpecificationRow(title: "Time Color", value: specification.timeColorAsset.specDescription)
                    DSSpecificationRow(
                        title: "Title Time Spacing",
                        value: specification.titleTimeSpacing.ptDescription
                    )
                }
            }
        }
        .navigationTitle("DSConversationHistoryList")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { ConversationHistoryListPlaygroundView() }
}
