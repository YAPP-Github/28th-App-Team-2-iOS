import SwiftUI
import Model

public struct DSSelectGender: View {
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
        current: Gender?,
        option: Gender,
        isSelected: Bool
    ) -> Gender? {
        isSelected ? option : current
    }

    @Binding private var selection: Gender?

    public init(selection: Binding<Gender?>) {
        self._selection = selection
    }

    public var body: some View {
        let specification = Self.specification()

        VStack(alignment: .leading, spacing: specification.contentSpacing) {
            Text("성별")
                .dsFont(specification.labelFontStyle)
                .foregroundStyle(specification.labelForegroundAsset.swiftUIColor)

            HStack(spacing: specification.optionSpacing) {
                ForEach(Gender.allCases, id: \.self) { option in
                    DSSelectBox(
                        option.dsGenderTitle,
                        isSelected: selectionBinding(for: option)
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .dsDebugDetailGeometry("DSSelectGender.Options")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsDebugGeometry("DSSelectGender")
    }

    private func selectionBinding(for option: Gender) -> Binding<Bool> {
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

extension Gender {
    var dsGenderTitle: String {
        switch self {
        case .male: "남성"
        case .female: "여성"
        }
    }
}
