import SwiftUI
import Model

public struct DSEnterTimeOfBirth: View {
    struct InputState: Equatable {
        let selection: BirthTimePeriod?
        let isTimeUnknown: Bool
    }

    public struct UnknownTimeOptionSpecification: Sendable {
        public let shape: DSComponentShape
        public let backgroundAsset: DesignSystemColors
        public let horizontalPadding: CGFloat
        public let verticalPadding: CGFloat
        public let labelSpacing: CGFloat
        public let labelFontStyle: FontStyle
        public let labelForegroundAsset: DesignSystemColors
    }

    public struct Specification: Sendable {
        public let contentSpacing: CGFloat
        public let fieldSpacing: CGFloat
        public let labelFontStyle: FontStyle
        public let labelForegroundAsset: DesignSystemColors
        public let unknownTimeOption: UnknownTimeOptionSpecification
    }

    public static func specification() -> Specification {
        Specification(
            contentSpacing: 16,
            fieldSpacing: 12,
            labelFontStyle: .body1Bold,
            labelForegroundAsset: DesignSystemAsset.Colors.black,
            unknownTimeOption: UnknownTimeOptionSpecification(
                shape: .roundedRectangle(cornerRadius: 12),
                backgroundAsset: DesignSystemAsset.Colors.gray25,
                horizontalPadding: 16,
                verticalPadding: 14,
                labelSpacing: 6,
                labelFontStyle: .body3Medium,
                labelForegroundAsset: DesignSystemAsset.Colors.gray975
            )
        )
    }

    @Binding private var selection: BirthTimePeriod?
    @Binding private var isTimeUnknown: Bool
    private let isFocused: Bool
    private let action: () -> Void

    public init(
        selection: Binding<BirthTimePeriod?>,
        isFocused: Bool = false,
        isTimeUnknown: Binding<Bool>,
        action: @escaping () -> Void
    ) {
        self._selection = selection
        self.isFocused = isFocused
        self._isTimeUnknown = isTimeUnknown
        self.action = action
    }

    public var body: some View {
        let specification = Self.specification()

        VStack(alignment: .leading, spacing: specification.contentSpacing) {
            Text("태어난 시간")
                .dsFont(specification.labelFontStyle)
                .foregroundStyle(specification.labelForegroundAsset.swiftUIColor)

            HStack(spacing: specification.fieldSpacing) {
                DSSelectField(
                    selection: displaySelection,
                    placeholder: "태어난 시간 선택",
                    isFocused: isFocused,
                    action: action
                )

                unknownTimeOption(specification.unknownTimeOption)
            }
            .dsDebugDetailGeometry("DSEnterTimeOfBirth.Fields")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsDebugGeometry("DSEnterTimeOfBirth")
        .onChange(of: inputState, initial: true) { previous, current in
            apply(
                Self.resolvedInputState(
                    previous: previous,
                    current: current
                )
            )
        }
    }

    public static func pickerTitle(for period: BirthTimePeriod) -> String {
        let name = periodName(for: period)

        return "\(name.hangul) (\(name.hanja)): "
            + "\(twoDigit(period.startHour)):\(twoDigit(period.startMinute)) ~ "
            + "\(twoDigit(period.endHour)):\(twoDigit(period.endMinute))"
    }

    public static func displayTitle(for selection: BirthTimePeriod?) -> String? {
        selection.map(pickerTitle(for:))
    }

    static func resolvedSelection(
        current: BirthTimePeriod?,
        displayValue: String?
    ) -> BirthTimePeriod? {
        displayValue == nil ? nil : current
    }

    static func resolvedInputState(
        previous: InputState,
        current: InputState
    ) -> InputState {
        if current.isTimeUnknown,
           !previous.isTimeUnknown || current == previous {
            return InputState(
                selection: nil,
                isTimeUnknown: true
            )
        }

        if current.selection != previous.selection,
           current.selection != nil {
            return InputState(
                selection: current.selection,
                isTimeUnknown: false
            )
        }

        return current
    }

    private var inputState: InputState {
        InputState(
            selection: selection,
            isTimeUnknown: isTimeUnknown
        )
    }

    private var timeUnknownBinding: Binding<Bool> {
        Binding(
            get: { isTimeUnknown },
            set: { newValue in
                apply(
                    Self.resolvedInputState(
                        previous: inputState,
                        current: InputState(
                            selection: selection,
                            isTimeUnknown: newValue
                        )
                    )
                )
            }
        )
    }

    private var displaySelection: Binding<String?> {
        Binding(
            get: { Self.displayTitle(for: selection) },
            set: { displayValue in
                selection = Self.resolvedSelection(
                    current: selection,
                    displayValue: displayValue
                )
            }
        )
    }

    // swiftlint:disable:next cyclomatic_complexity
    private static func periodName(
        for period: BirthTimePeriod
    ) -> (hangul: String, hanja: String) {
        switch period {
        case .jaTime: ("자시", "子時")
        case .chukTime: ("축시", "丑時")
        case .inTime: ("인시", "寅時")
        case .myoTime: ("묘시", "卯時")
        case .jinTime: ("진시", "辰時")
        case .saTime: ("사시", "巳時")
        case .oTime: ("오시", "午時")
        case .miTime: ("미시", "未時")
        case .sinTime: ("신시", "申時")
        case .yuTime: ("유시", "酉時")
        case .sulTime: ("술시", "戌時")
        case .haeTime: ("해시", "亥時")
        }
    }

    private static func twoDigit(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }

    private func unknownTimeOption(
        _ specification: UnknownTimeOptionSpecification
    ) -> some View {
        DSCheckbox(
            isOn: timeUnknownBinding,
            labelSpacing: specification.labelSpacing,
            contentInsets: EdgeInsets(
                top: specification.verticalPadding,
                leading: specification.horizontalPadding,
                bottom: specification.verticalPadding,
                trailing: specification.horizontalPadding
            )
        ) {
            Text("시간 모름")
                .dsFont(specification.labelFontStyle)
                .foregroundStyle(specification.labelForegroundAsset.swiftUIColor)
        }
        .background(
            specification.shape.swiftUIShape
                .fill(specification.backgroundAsset.swiftUIColor)
        )
        .contentShape(specification.shape.swiftUIShape)
        .clipShape(specification.shape.swiftUIShape)
        .accessibilityLabel("시간 모름")
    }

    private func apply(_ state: InputState) {
        if selection != state.selection {
            selection = state.selection
        }

        if isTimeUnknown != state.isTimeUnknown {
            isTimeUnknown = state.isTimeUnknown
        }
    }
}
