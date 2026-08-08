import SwiftUI

// MARK: - Core Checkbox Component
public struct DSCheckbox: View {
    public struct Specification: Sendable {
        public let size: CGFloat
        public let borderWidth: CGFloat?
        public let iconSize: CGFloat?
        public let shape: DSComponentShape
        public let backgroundAsset: DesignSystemColors
        public let borderAsset: DesignSystemColors?
        public let iconAsset: DesignSystemImages?
        public let iconTintAsset: DesignSystemColors?
        public let pressedOverlay: DSPressedOverlay
    }

    public static func specification(isOn: Bool) -> Specification {
        Specification(
            size: 20,
            borderWidth: isOn ? nil : 1,
            iconSize: isOn ? 16 : nil,
            shape: .roundedRectangle(cornerRadius: 6),
            backgroundAsset: isOn
                ? DesignSystemAsset.Colors.primary600
                : DesignSystemAsset.Colors.white,
            borderAsset: isOn ? nil : DesignSystemAsset.Colors.coolGray300,
            iconAsset: isOn ? DesignSystemAsset.Icons.checkLine : nil,
            iconTintAsset: isOn ? DesignSystemAsset.Colors.white : nil,
            pressedOverlay: .standard
        )
    }

    @Binding private var isOn: Bool
    private let label: AnyView
    private let labelSpacing: CGFloat
    private let contentInsets: EdgeInsets
    private let showsLabel: Bool

    public init(isOn: Binding<Bool>) {
        self._isOn = isOn
        self.label = AnyView(EmptyView())
        self.labelSpacing = 0
        self.contentInsets = EdgeInsets()
        self.showsLabel = false
    }

    public init<Label: View>(
        isOn: Binding<Bool>,
        labelSpacing: CGFloat,
        contentInsets: EdgeInsets = EdgeInsets(),
        @ViewBuilder label: () -> Label
    ) {
        self._isOn = isOn
        self.label = AnyView(label())
        self.labelSpacing = labelSpacing
        self.contentInsets = contentInsets
        self.showsLabel = true
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            label
        }
        .toggleStyle(
            DSCheckboxStyle(
                labelSpacing: labelSpacing,
                contentInsets: contentInsets,
                showsLabel: showsLabel
            )
        )
        .dsDebugGeometry("DSCheckbox")
    }
}

/// 부모가 제공하는 너비를 채우며 checkbox indicator를 행의 양 끝 중 하나에 배치하는 조합 컨트롤입니다.
///
/// 행의 배경, 여백, 레이블 내부 구성은 호출부가 소유합니다.
public struct DSCheckboxRow: View {
    public enum IndicatorPlacement: CaseIterable, Hashable, Sendable {
        case leading
        case trailing
    }

    public struct Specification: Sendable {
        public let indicatorPlacement: IndicatorPlacement
        public let minimumIndicatorSpacing: CGFloat
    }

    public static func specification(
        indicatorPlacement: IndicatorPlacement,
        minimumIndicatorSpacing: CGFloat
    ) -> Specification {
        Specification(
            indicatorPlacement: indicatorPlacement,
            minimumIndicatorSpacing: max(0, minimumIndicatorSpacing)
        )
    }

    @Binding private var isOn: Bool
    private let label: AnyView
    private let indicatorPlacement: IndicatorPlacement
    private let minimumIndicatorSpacing: CGFloat

    public init<Label: View>(
        isOn: Binding<Bool>,
        indicatorPlacement: IndicatorPlacement = .leading,
        minimumIndicatorSpacing: CGFloat,
        @ViewBuilder label: () -> Label
    ) {
        self._isOn = isOn
        self.label = AnyView(label())
        self.indicatorPlacement = indicatorPlacement
        self.minimumIndicatorSpacing = minimumIndicatorSpacing
    }

    public var body: some View {
        let specification = Self.specification(
            indicatorPlacement: indicatorPlacement,
            minimumIndicatorSpacing: minimumIndicatorSpacing
        )

        Toggle(isOn: $isOn) {
            label
        }
        .toggleStyle(
            DSCheckboxRowStyle(
                specification: specification
            )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsDebugGeometry("DSCheckboxRow")
    }
}
