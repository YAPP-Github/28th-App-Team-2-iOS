import SwiftUI
import DesignSystem

struct TabPlaygroundView: View {
    @State private var selectedTabIndex: Int = 0
    @State private var isDarkBackground: Bool = false

    private let tabs = ["전체", "진행중", "완료"]

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(title: String(describing: DSTab.self), isDarkBackground: $isDarkBackground) {
                HStack(spacing: 8) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        DSTab(tabs[index], isOn: selectedTabIndex == index) {
                            selectedTabIndex = index
                        }
                    }
                }
            }

            Form {
                Section(header: Text("Interactive State")) {
                    Picker("Selected Tab", selection: $selectedTabIndex) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            Text(tabs[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Figma Specification Check (Selected)")) {
                    let spec = DSTab.specification(isOn: true)

                    DSSpecificationRow(title: "Shape", value: spec.shape.specName)
                    DSSpecificationRow(title: "Padding", value: spec.padding.ptDescription)
                    DSSpecificationRow(title: "Background", value: spec.backgroundAsset.specDescription)
                    DSSpecificationRow(title: "Text Font", value: spec.textFont.specName)
                    DSSpecificationRow(title: "Text Color", value: spec.textColor.specDescription)
                    DSSpecificationRow(
                        title: "Pressed Overlay",
                        value: spec.pressedOverlay.specDescription
                    )
                }

                Section(header: Text("Figma Specification Check (Unselected)")) {
                    let spec = DSTab.specification(isOn: false)

                    DSSpecificationRow(title: "Background", value: spec.backgroundAsset.specDescription)
                    DSSpecificationRow(title: "Text Font", value: spec.textFont.specName)
                    DSSpecificationRow(title: "Text Color", value: spec.textColor.specDescription)
                    DSSpecificationRow(
                        title: "Pressed Overlay",
                        value: spec.pressedOverlay.specDescription
                    )
                }
            }
        }
        .navigationTitle("DSTab")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TabPlaygroundView()
    }
}
