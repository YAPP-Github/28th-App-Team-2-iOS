import SwiftUI
import DesignSystem

struct DialogPlaygroundView: View {
    @State private var title: String = "타이틀을 입력해주세요"
    @State private var message: String = "본문 내용을 입력해주세요."
    @State private var primaryTitle: String = "Label"
    @State private var secondaryTitle: String = "Label"
    @State private var showsMessage: Bool = true
    @State private var showsSecondaryAction: Bool = false
    @State private var lastAction: String = "선택 전"
    @State private var isDarkBackground: Bool = false

    private var specification: DSDialog.Specification {
        DSDialog.specification(
            hasMessage: showsMessage,
            hasSecondaryAction: showsSecondaryAction
        )
    }

    private var actionButtonSpecification: DSButton.Specification {
        DSButton.specification(
            variant: .primary,
            size: specification.actionButtonSize,
            isEnabled: true
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSDialog.self),
                height: 260,
                isDarkBackground: $isDarkBackground
            ) {
                DSDialog(
                    title: title,
                    message: showsMessage ? message : nil,
                    primaryAction: .init(primaryTitle) {
                        lastAction = "Primary"
                    },
                    secondaryAction: showsSecondaryAction ? .init(secondaryTitle) {
                        lastAction = "Secondary"
                    } : nil
                )
            }

            Form {
                Section(header: Text("Content & Interaction")) {
                    TextField("Title", text: $title)
                    Toggle("Show Message", isOn: $showsMessage)
                    if showsMessage {
                        TextField("Message", text: $message)
                    }
                    TextField("Primary Button", text: $primaryTitle)
                    Toggle("Show Secondary Button", isOn: $showsSecondaryAction)
                    if showsSecondaryAction {
                        TextField("Secondary Button", text: $secondaryTitle)
                    }
                    DSSpecificationRow(title: "Last Action", value: lastAction)
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Width", value: specification.width.ptDescription)
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(title: "Title Typography", value: specification.titleFont.specName)
                    DSSpecificationRow(title: "Title Color", value: specification.titleColor.specDescription)
                    DSSpecificationRow(
                        title: "Message Typography",
                        value: specification.messageFont?.specName ?? "None"
                    )
                    DSSpecificationRow(
                        title: "Message Color",
                        value: specification.messageColor?.specDescription ?? "None"
                    )
                    DSSpecificationRow(
                        title: "Action Layout",
                        value: specification.actionSpacing == nil
                            ? "One button"
                            : "Two buttons / 8pt gap"
                    )
                    DSSpecificationRow(
                        title: "Action Button",
                        value: [
                            actionButtonSpecification.height.ptDescription,
                            actionButtonSpecification.fontStyle.specName
                        ]
                        .joined(separator: " / ")
                    )
                }
            }
        }
        .navigationTitle("DSDialog")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DialogPlaygroundView()
    }
}
