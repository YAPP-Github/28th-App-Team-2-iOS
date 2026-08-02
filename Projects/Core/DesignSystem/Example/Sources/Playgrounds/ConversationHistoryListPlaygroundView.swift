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
                    DSSpecificationRow(title: "Height", value: specification.height.ptDescription)
                    DSSpecificationRow(
                        title: "Horizontal Padding",
                        value: specification.horizontalPadding.ptDescription
                    )
                    DSSpecificationRow(title: "Unread Indicator", value: specification.indicatorSize.ptDescription)
                    DSSpecificationRow(title: "Delete Icon", value: specification.deleteIcon.specDescription)
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
