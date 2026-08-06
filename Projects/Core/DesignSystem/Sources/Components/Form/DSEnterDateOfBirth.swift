import SwiftUI
import Model

public struct DSEnterDateOfBirth: View {
    public struct Specification: Sendable {
        public let contentSpacing: CGFloat
        public let labelFontStyle: FontStyle
        public let labelForegroundAsset: DesignSystemColors
    }

    public static func specification() -> Specification {
        Specification(
            contentSpacing: 16,
            labelFontStyle: .body1Bold,
            labelForegroundAsset: DesignSystemAsset.Colors.black
        )
    }

    @Binding private var selection: BirthDate?
    private let isFocused: Bool
    private let action: () -> Void

    public init(
        selection: Binding<BirthDate?>,
        isFocused: Bool = false,
        action: @escaping () -> Void
    ) {
        self._selection = selection
        self.isFocused = isFocused
        self.action = action
    }

    public var body: some View {
        let specification = Self.specification()

        VStack(alignment: .leading, spacing: specification.contentSpacing) {
            Text("생년월일")
                .dsFont(specification.labelFontStyle)
                .foregroundStyle(specification.labelForegroundAsset.swiftUIColor)

            DSSelectField(
                selection: displaySelection,
                placeholder: "생년월일 선택",
                isFocused: isFocused,
                action: action
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsDebugGeometry("DSEnterDateOfBirth")
    }

    public static func displayTitle(for selection: BirthDate?) -> String? {
        selection.map { "\($0.year)년 \($0.month)월 \($0.day)일" }
    }

    static func resolvedSelection(
        current: BirthDate?,
        displayValue: String?
    ) -> BirthDate? {
        displayValue == nil ? nil : current
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
}
