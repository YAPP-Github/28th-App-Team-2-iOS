import SwiftUI
import DesignSystem

struct ProgressBarPlaygroundView: View {
    @State private var progress: Double = 0.5
    @State private var isDarkBackground: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSProgressBar.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSProgressBar(progress: progress) {
                    print("Back button tapped")
                }
            }

            Form {
                Section(header: Text("Interactive State")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Progress: \(Int(progress * 100))%")
                        Slider(value: $progress, in: 0...1)
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("Figma Specification Check")) {
                    let spec = DSProgressBar.specification()

                    DSSpecificationRow(title: "Height", value: "\(Int(spec.height))pt")
                    DSSpecificationRow(title: "Leading Padding", value: "\(Int(spec.leadingPadding))pt")
                    DSSpecificationRow(title: "Trailing Padding", value: "\(Int(spec.trailingPadding))pt")
                    DSSpecificationRow(title: "Content Gap", value: "\(Int(spec.contentGap))pt")
                    DSSpecificationRow(title: "Back Icon", value: spec.backIconAsset.specDescription)
                    DSSpecificationRow(title: "Back Icon Size", value: spec.backIconSize.ptDescription)
                    DSSpecificationRow(title: "Back Icon Tint", value: spec.backIconTintAsset.specDescription)
                    DSSpecificationRow(
                        title: "Back Icon Pressed Overlay",
                        value: spec.backIconPressedOverlay.specDescription
                    )
                    DSSpecificationRow(title: "Track Height", value: "\(Int(spec.trackHeight))pt")
                    DSSpecificationRow(title: "Track Shape", value: spec.trackShape.specName)
                    DSSpecificationRow(
                        title: "Track Background",
                        value: spec.trackBackgroundGradient
                            .map(\.specDescription)
                            .joined(separator: " → ")
                    )
                    DSSpecificationRow(
                        title: "Track Background Opacity",
                        value: "\(Int(spec.trackBackgroundOpacity * 100))%"
                    )
                    DSSpecificationRow(title: "Current Progress", value: "\(Int(progress * 100))%")
                    DSSpecificationRow(title: "Fill Gradient Coordinate", value: "Track width")
                    ForEach(
                        Array(zip(spec.trackFillGradientLocations, spec.trackFillGradient).enumerated()),
                        id: \.offset
                    ) { _, pair in
                        let (location, asset) = pair
                        DSSpecificationRow(
                            title: "Fill @ \(Int(location * 100))%",
                            value: asset.specDescription
                        )
                    }
                }
            }
        }
        .navigationTitle("DSProgressBar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProgressBarPlaygroundView()
    }
}
