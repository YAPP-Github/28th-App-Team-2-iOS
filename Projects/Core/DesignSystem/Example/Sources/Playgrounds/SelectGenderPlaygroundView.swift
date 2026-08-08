import SwiftUI
import DesignSystem
import Model

struct SelectGenderPlaygroundView: View {
    @State private var selection: Gender?
    @State private var isDarkBackground = false

    private var specification: DSSelectGender.Specification {
        DSSelectGender.specification()
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSSelectGender.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSSelectGender(selection: $selection)
            }

            Form {
                Section(header: Text("Selection")) {
                    selectionButton("None", selection: nil)
                    selectionButton("Male", selection: .male)
                    selectionButton("Female", selection: .female)
                }

                specificationSection
            }
        }
        .navigationTitle("DSSelectGender")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func selectionButton(
        _ title: String,
        selection: Gender?
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
        SelectGenderPlaygroundView()
    }
}
