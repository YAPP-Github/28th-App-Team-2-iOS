import SwiftUI
import DesignSystem

struct TodakExampleQuestionPlaygroundView: View {
    @State private var leadingText = "📅 중요한 "
    @State private var boldText = "일정"
    @State private var trailingText = " 잡기 좋은 날인지 궁금해"
    @State private var isDarkBackground = false

    var body: some View {
        let specification = DSTodakExampleQuestion.specification

        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSTodakExampleQuestion.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSTodakExampleQuestion(
                    segments: [
                        .init(leadingText),
                        .init(boldText, isBold: true),
                        .init(trailingText)
                    ]
                )
                    .frame(maxWidth: 329)
            }

            Form {
                Section(header: Text("Content")) {
                    TextField("Leading Text", text: $leadingText)
                    TextField("Bold Text", text: $boldText)
                    TextField("Trailing Text", text: $trailingText)
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Height", value: specification.height.ptDescription)
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(title: "Padding", value: "H \(specification.horizontalPadding.ptDescription), V \(specification.verticalPadding.ptDescription)")
                    DSSpecificationRow(title: "Typography", value: specification.fontStyle.specName)
                }
            }
        }
        .navigationTitle("DSTodakExampleQuestion")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { TodakExampleQuestionPlaygroundView() }
}
