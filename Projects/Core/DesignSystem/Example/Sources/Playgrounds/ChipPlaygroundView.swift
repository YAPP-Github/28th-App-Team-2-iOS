import SwiftUI
import DesignSystem

// MARK: - Chip Playground Sandbox
struct ChipPlaygroundView: View {
    enum ChipType: String, CaseIterable {
        case chip1 = "DSChip"
        case chip2 = "DSChip2"
    }

    @State private var chipType: ChipType = .chip1
    @State private var chipText: String = "학생"
    @State private var isSelected: Bool = false
    @State private var isDarkBackground: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: chipType.rawValue,
                height: 260,
                isDarkBackground: $isDarkBackground
            ) {
                makeChip(title: chipText)
            }

            Form {
                Section(header: Text("Chip Type")) {
                    Picker("Type", selection: $chipType) {
                        Text("DSChip (Interactive)").tag(ChipType.chip1)
                        Text("DSChip2 (Static)").tag(ChipType.chip2)
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Chip Text")) {
                    TextField("Enter chip text...", text: $chipText)
                        .autocorrectionDisabled()
                }

                if chipType == .chip1 {
                    Section(header: Text("Interactive State")) {
                        Toggle("Is Selected (선택 상태)", isOn: $isSelected)
                    }
                }

                Section(header: Text("Figma Specification Check")) {
                    specificationRows
                }
            }
        }
        .navigationTitle("Chip Playground")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var specificationRows: some View {
        switch chipType {
        case .chip1:
            let specification = DSChip.specification(isSelected: isSelected)
            DSSpecificationRow(title: "Shape", value: specification.shape.specName)
            DSSpecificationRow(title: "Padding (Vertical)", value: specification.verticalPadding.ptDescription)
            DSSpecificationRow(title: "Padding (Horizontal)", value: specification.horizontalPadding.ptDescription)
            DSSpecificationRow(title: "Typography", value: specification.fontStyle.specName)
            DSSpecificationRow(title: "Bg Color", value: specification.backgroundAsset.specDescription)
            DSSpecificationRow(title: "Text Color", value: specification.foregroundAsset.specDescription)

        case .chip2:
            let specification = DSChip2.specification
            DSSpecificationRow(title: "Shape", value: specification.shape.specName)
            DSSpecificationRow(title: "Padding (Vertical)", value: specification.verticalPadding.ptDescription)
            DSSpecificationRow(title: "Padding (Horizontal)", value: specification.horizontalPadding.ptDescription)
            DSSpecificationRow(title: "Typography", value: specification.fontStyle.specName)
            DSSpecificationRow(title: "Bg Color", value: specification.backgroundAsset.specDescription)
            DSSpecificationRow(title: "Text Color", value: specification.foregroundAsset.specDescription)
        }
    }

    @ViewBuilder
    private func makeChip(title: String) -> some View {
        switch chipType {
        case .chip1:
            DSChip(title, isSelected: isSelected) {
                isSelected.toggle()
            }
        case .chip2:
            DSChip2(title)
        }
    }
}
