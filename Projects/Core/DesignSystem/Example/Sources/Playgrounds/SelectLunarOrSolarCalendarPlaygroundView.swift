import SwiftUI
import DesignSystem
import Model

struct SelectLunarOrSolarCalendarPlaygroundView: View {
    @State private var selection: BirthDateCalendar?
    @State private var isDarkBackground = false

    private var specification: DSSelectLunarOrSolarCalendar.Specification {
        DSSelectLunarOrSolarCalendar.specification()
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSSelectLunarOrSolarCalendar.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSSelectLunarOrSolarCalendar(selection: $selection)
            }

            Form {
                Section(header: Text("Selection")) {
                    selectionButton("None", selection: nil)
                    selectionButton("Solar", selection: .solar)
                    selectionButton("Lunar", selection: .lunar)
                }

                specificationSection
            }
        }
        .navigationTitle("DSSelectLunarOrSolarCalendar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func selectionButton(
        _ title: String,
        selection: BirthDateCalendar?
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
        SelectLunarOrSolarCalendarPlaygroundView()
    }
}
