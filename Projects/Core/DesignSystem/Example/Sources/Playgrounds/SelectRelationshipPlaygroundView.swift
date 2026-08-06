import SwiftUI
import DesignSystem
import Model

struct SelectRelationshipPlaygroundView: View {
    @State private var selection: Relationship?
    @State private var isDarkBackground = false

    private var specification: DSSelectRelationship.Specification {
        DSSelectRelationship.specification()
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSSelectRelationship.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSSelectRelationship(selection: $selection)
            }

            Form {
                Section(header: Text("Selection")) {
                    selectionButton("None", selection: nil)
                    selectionButton("Partner", selection: .partner)
                    selectionButton("Friend", selection: .friend)
                    selectionButton("Colleague", selection: .colleague)
                }

                specificationSection
            }
        }
        .navigationTitle("DSSelectRelationship")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func selectionButton(
        _ title: String,
        selection: Relationship?
    ) -> some View {
        Button(title) {
            self.selection = selection
        }
    }

    private var specificationSection: some View {
        Section(header: Text("Figma Specification Check")) {
            DSSpecificationRow(
                title: "Content Spacing",
                value: specification.contentSpacing.ptDescription
            )
            DSSpecificationRow(
                title: "Option Spacing",
                value: specification.optionSpacing.ptDescription
            )
            DSSpecificationRow(
                title: "Label Typography",
                value: specification.labelFontStyle.specName
            )
            DSSpecificationRow(
                title: "Label Color",
                value: specification.labelForegroundAsset.specDescription
            )
        }
    }
}

#Preview {
    NavigationStack {
        SelectRelationshipPlaygroundView()
    }
}
