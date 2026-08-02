import SwiftUI
import DesignSystem

struct ChatTypeBoxPlaygroundView: View {
    @State private var text = ""
    @State private var lastSentMessage = "전송 전"
    @State private var isDarkBackground = false

    private var specification: DSChatTypeBox.Specification {
        DSChatTypeBox.specification(isFilled: !text.isEmpty)
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSChatTypeBox.self),
                height: 180,
                isDarkBackground: $isDarkBackground
            ) {
                DSChatTypeBox(
                    text: $text,
                    placeholder: "토닥이에게 운세 물어보기"
                ) {
                    lastSentMessage = text.isEmpty ? "빈 메시지" : text
                }
                .frame(maxWidth: 353)
            }

            Form {
                Section(header: Text("Content & Interaction")) {
                    TextField("Message", text: $text)
                    DSSpecificationRow(title: "Last Sent", value: lastSentMessage)
                    Button("Clear") { text = "" }
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(
                        title: "Height",
                        value: "\(Int(specification.minimumHeight))–\(Int(specification.maximumHeight))pt"
                    )
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(
                        title: "Text Leading Padding",
                        value: specification.textLeadingPadding.ptDescription
                    )
                    DSSpecificationRow(title: "Send Button", value: specification.sendButtonSize.ptDescription)
                    DSSpecificationRow(
                        title: "Shadow",
                        value: "Y \(specification.shadowOffsetY.ptDescription), "
                            + "Blur \(specification.shadowRadius.ptDescription), "
                            + "\(Int(specification.shadowOpacity * 100))%"
                    )
                }
            }
        }
        .navigationTitle("DSChatTypeBox")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { ChatTypeBoxPlaygroundView() }
}
