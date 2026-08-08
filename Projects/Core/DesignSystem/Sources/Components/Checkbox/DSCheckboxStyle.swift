import SwiftUI

struct DSCheckboxStyle: ToggleStyle {
    let labelSpacing: CGFloat
    let contentInsets: EdgeInsets
    let showsLabel: Bool

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
        }
        .buttonStyle(
            DSCheckboxButtonStyle(
                isOn: configuration.isOn,
                labelSpacing: labelSpacing,
                contentInsets: contentInsets,
                showsLabel: showsLabel
            )
        )
        .accessibilityValue(configuration.isOn ? "선택됨" : "선택 안 됨")
    }
}

extension DSCheckbox {
    static func indicator(isOn: Bool, isPressed: Bool) -> some View {
        DSCheckboxIndicator(
            specification: specification(isOn: isOn),
            isPressed: isPressed
        )
    }
}

private struct DSCheckboxIndicator: View {
    let specification: DSCheckbox.Specification
    let isPressed: Bool

    var body: some View {
        ZStack {
            specification.shape.swiftUIShape
                .fill(specification.backgroundAsset.swiftUIColor)
                .frame(width: specification.size, height: specification.size)
                .overlay {
                    if let borderAsset = specification.borderAsset,
                       let borderWidth = specification.borderWidth {
                        specification.shape.strokeBorder(
                            borderAsset.swiftUIColor,
                            lineWidth: borderWidth
                        )
                    }
                }

            if let iconAsset = specification.iconAsset,
               let iconTintAsset = specification.iconTintAsset,
               let iconSize = specification.iconSize {
                iconAsset.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(iconTintAsset.swiftUIColor)
                    .frame(
                        width: iconSize,
                        height: iconSize
                    )
                    .dsDebugDetailGeometry("DSCheckbox.Icon")
            }
        }
        .dsPressedOverlay(
            isPressed: isPressed,
            shape: specification.shape,
            specification: specification.pressedOverlay
        )
        .clipShape(specification.shape.swiftUIShape)
        .dsDebugDetailGeometry("DSCheckbox.Indicator")
    }
}

private struct DSCheckboxButtonStyle: ButtonStyle {
    let isOn: Bool
    let labelSpacing: CGFloat
    let contentInsets: EdgeInsets
    let showsLabel: Bool

    func makeBody(configuration: Configuration) -> some View {
        DSCheckboxControlContent(
            isOn: isOn,
            isPressed: configuration.isPressed,
            indicatorPlacement: .leading,
            indicatorSpacing: showsLabel ? labelSpacing : 0,
            contentInsets: contentInsets,
            expandsLabel: false,
            showsLabel: showsLabel,
            label: showsLabel
                ? AnyView(configuration.label)
                : AnyView(EmptyView())
        )
    }
}

struct DSCheckboxRowStyle: ToggleStyle {
    let specification: DSCheckboxRow.Specification

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
        }
        .buttonStyle(
            DSCheckboxRowButtonStyle(
                isOn: configuration.isOn,
                specification: specification
            )
        )
        .accessibilityValue(configuration.isOn ? "선택됨" : "선택 안 됨")
    }
}

private struct DSCheckboxRowButtonStyle: ButtonStyle {
    let isOn: Bool
    let specification: DSCheckboxRow.Specification

    func makeBody(configuration: Configuration) -> some View {
        DSCheckboxControlContent(
            isOn: isOn,
            isPressed: configuration.isPressed,
            indicatorPlacement: specification.indicatorPlacement,
            indicatorSpacing: specification.minimumIndicatorSpacing,
            contentInsets: EdgeInsets(),
            expandsLabel: true,
            showsLabel: true,
            label: AnyView(configuration.label)
        )
    }
}

private struct DSCheckboxControlContent: View {
    let isOn: Bool
    let isPressed: Bool
    let indicatorPlacement: DSCheckboxRow.IndicatorPlacement
    let indicatorSpacing: CGFloat
    let contentInsets: EdgeInsets
    let expandsLabel: Bool
    let showsLabel: Bool
    let label: AnyView

    var body: some View {
        HStack(spacing: indicatorSpacing) {
            if indicatorPlacement == .leading {
                indicator
            }

            if showsLabel {
                label
                    .frame(
                        maxWidth: expandsLabel ? .infinity : nil,
                        alignment: .leading
                    )
                    .dsDebugDetailGeometry(
                        expandsLabel ? "DSCheckboxRow.Label" : "DSCheckbox.Label"
                    )
            }

            if indicatorPlacement == .trailing {
                indicator
            }
        }
        .padding(contentInsets)
        .frame(
            maxWidth: expandsLabel ? .infinity : nil,
            alignment: .leading
        )
        .contentShape(Rectangle())
    }

    private var indicator: some View {
        DSCheckbox.indicator(
            isOn: isOn,
            isPressed: isPressed
        )
    }
}
