import SwiftUI
import DesignSystem

struct UserChatPlaygroundView: View {
    @State private var message = "Text Text Text"
    @State private var isDarkBackground = false

    var body: some View {
        let specification = DSUserChat.specification

        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSUserChat.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSUserChat(message)
                    .frame(width: 302)
            }

            Form {
                Section(header: Text("Content")) {
                    TextField("Message", text: $message)
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Height", value: specification.height.ptDescription)
                    DSSpecificationRow(
                        title: "Background",
                        value: specification.backgroundAsset.specDescription
                    )
                    DSSpecificationRow(
                        title: "Text Color",
                        value: specification.foregroundAsset.specDescription
                    )
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(
                        title: "Padding",
                        value: "H \(specification.horizontalPadding.ptDescription), "
                            + "V \(specification.verticalPadding.ptDescription)"
                    )
                    DSSpecificationRow(title: "Typography", value: specification.fontStyle.specName)
                }
            }
        }
        .navigationTitle("DSUserChat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { UserChatPlaygroundView() }
}
