import SwiftUI
import DesignSystem

struct ToastPlaygroundView: View {
    @State private var message: String = "메시지에 마침표를 찍어주세요."
    @State private var luckyActionMessage: String = "행운 액션 완료! 오늘의 관계운이 올랐어요 🍀"
    @State private var selectedVariant: DSToastVariant = .standard
    @State private var lastAction: String = "선택 전"
    @State private var isDarkBackground: Bool = false

    private var specification: DSToast.Specification {
        DSToast.specification(variant: selectedVariant)
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSToast.self),
                height: 300,
                isDarkBackground: $isDarkBackground
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    DSToast(message) {
                        lastAction = "Standard Close"
                    }

                    DSToast(compact: message)

                    DSToast(luckyAction: luckyActionMessage) {
                        lastAction = "Lucky Action Close"
                    }
                }
                .frame(maxWidth: 353, alignment: .leading)
            }

            Form {
                Section(header: Text("Content & Interaction")) {
                    TextField("Toast message", text: $message)
                    TextField("Lucky Action message", text: $luckyActionMessage)
                    DSSpecificationRow(title: "Last Action", value: lastAction)
                }

                Section(header: Text("Specification Variant")) {
                    Picker("Variant", selection: $selectedVariant) {
                        ForEach(DSToastVariant.allCases, id: \.self) { variant in
                            Text(variant.displayName)
                                .tag(variant)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(
                        title: "Minimum Height",
                        value: specification.minimumHeight.ptDescription
                    )
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(title: "Typography", value: specification.fontStyle.specName)
                    DSSpecificationRow(
                        title: "Fills Available Width",
                        value: specification.fillsAvailableWidth ? "Yes" : "No"
                    )
                    DSSpecificationRow(
                        title: "Content Padding",
                        value: [
                            "L: \(specification.leadingPadding.ptDescription)",
                            "R: \(specification.trailingPadding.ptDescription)",
                            "V: \(specification.verticalPadding.ptDescription)"
                        ]
                        .joined(separator: ", ")
                    )
                    DSSpecificationRow(
                        title: "Foreground",
                        value: specification.foregroundAsset.specDescription
                    )

                    switch specification.background {
                    case let .color(asset):
                        DSSpecificationRow(
                            title: "Background",
                            value: asset.specDescription
                        )
                    case let .horizontalGradient(assets, _):
                        DSSpecificationRow(
                            title: "Background Gradient",
                            value: assets
                                .map(\.specDescription)
                                .joined(separator: " → ")
                        )
                    }

                    DSSpecificationRow(
                        title: "Close Button",
                        value: specification.closeButton == nil ? "None" : "Shown"
                    )

                    if let closeButton = specification.closeButton {
                        DSSpecificationRow(title: "Close Icon", value: closeButton.iconAsset.name)
                        DSSpecificationRow(
                            title: "Close Icon Tint",
                            value: closeButton.iconColorAsset.specDescription
                        )
                    }

                    if let intrinsicShadow = specification.intrinsicShadow {
                        DSSpecificationRow(
                            title: "Intrinsic Shadow",
                            value: [
                                intrinsicShadow.colorHex.hexColorDescription,
                                intrinsicShadow.radius.ptDescription,
                                "\(Int(intrinsicShadow.opacity * 100))%"
                            ]
                            .joined(separator: ", ")
                        )
                    } else {
                        DSSpecificationRow(title: "Intrinsic Shadow", value: "None")
                    }
                }
            }
        }
        .navigationTitle("DSToast")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension DSToastVariant {
    var displayName: String {
        switch self {
        case .standard:
            "Standard"
        case .compact:
            "Compact"
        case .luckyAction:
            "Lucky Action"
        }
    }
}

#Preview {
    NavigationStack {
        ToastPlaygroundView()
    }
}
