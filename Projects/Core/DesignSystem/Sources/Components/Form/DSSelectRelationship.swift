import SwiftUI
import Model

public struct DSSelectRelationship: View {
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
        current: Relationship?,
        option: Relationship,
        isSelected: Bool
    ) -> Relationship? {
        isSelected ? option : current
    }

    @Binding private var selection: Relationship?

    public init(selection: Binding<Relationship?>) {
        self._selection = selection
    }

    public var body: some View {
        let specification = Self.specification()

        VStack(alignment: .leading, spacing: specification.contentSpacing) {
            Text("관계")
                .dsFont(specification.labelFontStyle)
                .foregroundStyle(specification.labelForegroundAsset.swiftUIColor)

            HStack(spacing: specification.optionSpacing) {
                ForEach(Relationship.allCases, id: \.self) { option in
                    DSSelectBox(
                        option.dsRelationshipTitle,
                        isSelected: selectionBinding(for: option)
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .dsDebugDetailGeometry("DSSelectRelationship.Options")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsDebugGeometry("DSSelectRelationship")
    }

    private func selectionBinding(for option: Relationship) -> Binding<Bool> {
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

extension Relationship {
    var dsRelationshipTitle: String {
        switch self {
        case .partner: "연인"
        case .friend: "친구"
        case .colleague: "동료"
        }
    }
}
