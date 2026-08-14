import SwiftUI
import DesignSystem

// MARK: - Saju Pillar Cell Playground Sandbox
struct SajuPillarCellPlaygroundView: View {
    @State private var hanjaText: String = "辛"
    @State private var readingText: String = "신"
    @State private var selectedElement: DSSajuElement = .metal
    @State private var showElementHanja: Bool = true
    @State private var isDarkBackground: Bool = false

    private var specification: DSSajuPillarCell.Specification {
        DSSajuPillarCell.specification(element: selectedElement)
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSSajuPillarCell.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSSajuPillarCell(
                    hanja: hanjaText,
                    reading: readingText,
                    element: selectedElement,
                    showElementHanja: showElementHanja
                )
            }

            Form {
                Section(header: Text("Content")) {
                    TextField("Hanja", text: $hanjaText)
                        .autocorrectionDisabled()
                    TextField("Reading", text: $readingText)
                        .autocorrectionDisabled()
                    Toggle("Show Element Hanja", isOn: $showElementHanja)
                }

                Section(header: Text("Five Element")) {
                    Picker("Element", selection: $selectedElement) {
                        ForEach([DSSajuElement.wood, .fire, .earth, .metal, .water, .unknown], id: \.self) { element in
                            Text("\(element.label) (\(element.hanja))").tag(element)
                        }
                    }
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(title: "Size", value: specification.size.ptDescription)
                    DSSpecificationRow(title: "Bg Color", value: specification.backgroundAsset.specDescription)
                    DSSpecificationRow(title: "Text Color", value: specification.foregroundAsset.specDescription)
                }
            }
        }
        .navigationTitle("Saju Pillar Cell Playground")
        .navigationBarTitleDisplayMode(.inline)
    }
}
