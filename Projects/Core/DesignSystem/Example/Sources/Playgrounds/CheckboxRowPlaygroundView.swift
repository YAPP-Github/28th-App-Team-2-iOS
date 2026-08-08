import SwiftUI
import DesignSystem

struct CheckboxRowPlaygroundView: View {
    @State private var isOn: Bool = false
    @State private var isDarkBackground: Bool = false
    @State private var title: String = "오랜만에 생각난 사람에게 메시지 보내기"
    @State private var indicatorPlacement: DSCheckboxRow.IndicatorPlacement = .trailing
    @State private var minimumIndicatorSpacing: Double = 12
    @State private var containerWidth: Double = 353

    private var specification: DSCheckboxRow.Specification {
        DSCheckboxRow.specification(
            indicatorPlacement: indicatorPlacement,
            minimumIndicatorSpacing: minimumIndicatorSpacing
        )
    }

    private var checkboxSpecification: DSCheckbox.Specification {
        DSCheckbox.specification(isOn: isOn)
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSCheckboxRow.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSCheckboxRow(
                    isOn: $isOn,
                    indicatorPlacement: indicatorPlacement,
                    minimumIndicatorSpacing: minimumIndicatorSpacing
                ) {
                    Text(title)
                        .dsBody1Bold
                        .lineLimit(2)
                }
                .frame(width: containerWidth)
            }

            Form {
                Section(header: Text("Content & State")) {
                    TextField("Checkbox Row title", text: $title)
                    Toggle("Is On (선택 상태)", isOn: $isOn)
                }

                Section(header: Text("Layout")) {
                    Picker("Indicator Placement", selection: $indicatorPlacement) {
                        ForEach(DSCheckboxRow.IndicatorPlacement.allCases, id: \.self) { placement in
                            Text(placement.description).tag(placement)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading) {
                        Text("Parent Width: \(containerWidth, specifier: "%.0f")pt")
                        Slider(value: $containerWidth, in: 180...353, step: 1)
                    }

                    VStack(alignment: .leading) {
                        Text(
                            "Minimum Indicator Spacing: \(minimumIndicatorSpacing, specifier: "%.0f")pt"
                        )
                        Slider(value: $minimumIndicatorSpacing, in: 0...24, step: 1)
                    }
                }

                Section(header: Text("Specification Check")) {
                    DSSpecificationRow(
                        title: "Indicator Placement",
                        value: specification.indicatorPlacement.description
                    )
                    DSSpecificationRow(
                        title: "Minimum Indicator Spacing",
                        value: specification.minimumIndicatorSpacing.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Indicator Size",
                        value: checkboxSpecification.size.squarePtDescription
                    )
                    DSSpecificationRow(
                        title: "Indicator Pressed Overlay",
                        value: checkboxSpecification.pressedOverlay.specDescription
                    )
                }
            }
        }
        .navigationTitle("DSCheckboxRow")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension DSCheckboxRow.IndicatorPlacement {
    var description: String {
        switch self {
        case .leading: "Leading"
        case .trailing: "Trailing"
        }
    }
}

#Preview {
    NavigationStack {
        CheckboxRowPlaygroundView()
    }
}
