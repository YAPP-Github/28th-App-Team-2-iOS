import SwiftUI
import Model

public struct DSSelectLunarOrSolarCalendar: View {
    public struct Specification: Sendable {
        public let contentSpacing: CGFloat
        public let optionSpacing: CGFloat
        public let labelFontStyle: FontStyle
        public let labelForegroundAsset: DesignSystemColors
    }

    public static func specification() -> Specification {
        Specification(
            contentSpacing: 16,
            optionSpacing: 12,
            labelFontStyle: .body1Bold,
            labelForegroundAsset: DesignSystemAsset.Colors.black
        )
    }

    static func resolvedSelection(
        current: BirthDateCalendar?,
        option: BirthDateCalendar,
        isSelected: Bool
    ) -> BirthDateCalendar? {
        isSelected ? option : current
    }

    @Binding private var selection: BirthDateCalendar?

    public init(selection: Binding<BirthDateCalendar?>) {
        self._selection = selection
    }

    public var body: some View {
        let specification = Self.specification()

        VStack(alignment: .leading, spacing: specification.contentSpacing) {
            Text("음/양력")
                .dsFont(specification.labelFontStyle)
                .foregroundStyle(specification.labelForegroundAsset.swiftUIColor)

            HStack(spacing: specification.optionSpacing) {
                ForEach(BirthDateCalendar.allCases, id: \.self) { option in
                    DSSelectBox(
                        option.dsCalendarTitle,
                        isSelected: selectionBinding(for: option)
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .dsDebugDetailGeometry("DSSelectLunarOrSolarCalendar.Options")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsDebugGeometry("DSSelectLunarOrSolarCalendar")
    }

    private func selectionBinding(for option: BirthDateCalendar) -> Binding<Bool> {
        Binding(
            get: { selection == option },
            set: { isSelected in
                selection = Self.resolvedSelection(
                    current: selection,
                    option: option,
                    isSelected: isSelected
                )
            }
        )
    }
}

extension BirthDateCalendar {
    var dsCalendarTitle: String {
        switch self {
        case .solar: "양력"
        case .lunar: "음력"
        }
    }
}
