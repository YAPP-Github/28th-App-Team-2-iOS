import SwiftUI

public enum DSBottomNavigationItem: CaseIterable, Hashable, Sendable {
    case fortune
    case todak
    case luckyAction
    case myPage

    public var title: String {
        switch self {
        case .fortune: "운세"
        case .todak: "토닥이"
        case .luckyAction: "행운 액션"
        case .myPage: "마이"
        }
    }

    func iconAsset(isSelected: Bool) -> DSIconAsset {
        switch (self, isSelected) {
        case (.fortune, true): .naviLuckyOn
        case (.fortune, false): .naviLuckyOff
        case (.todak, true): .naviAiOn
        case (.todak, false): .naviAiOff
        case (.luckyAction, true): .naviActionOn
        case (.luckyAction, false): .naviActionOff
        case (.myPage, true): .naviMyOn
        case (.myPage, false): .naviMyOff
        }
    }
}

public struct DSBottomNavigation: View {
    public struct ItemSpecification: Sendable {
        public let iconAsset: DSIconAsset
        public let titleFont: FontStyle
        public let titleColor: DesignSystemColors
    }

    public struct Specification: Sendable {
        public let height: CGFloat
        public let contentHorizontalPadding: CGFloat
        public let contentVerticalPadding: CGFloat
        public let itemTopPadding: CGFloat
        public let itemSpacing: CGFloat
        public let iconSize: CGFloat
        public let topCornerRadius: CGFloat
        public let backgroundColor: DesignSystemColors
        public let shadowColor: DesignSystemColors
        public let shadowOpacity: CGFloat
        public let shadowRadius: CGFloat
        public let shadowYOffset: CGFloat
    }

    public static let specification = Specification(
        height: 56,
        contentHorizontalPadding: 12,
        contentVerticalPadding: 5.5,
        itemTopPadding: 4,
        itemSpacing: 4,
        iconSize: 24,
        topCornerRadius: 24,
        backgroundColor: DesignSystemAsset.Colors.white,
        shadowColor: DesignSystemAsset.Colors.black,
        shadowOpacity: 0.06,
        shadowRadius: 20,
        shadowYOffset: -4
    )

    public static func itemSpecification(
        for item: DSBottomNavigationItem,
        isSelected: Bool
    ) -> ItemSpecification {
        ItemSpecification(
            iconAsset: item.iconAsset(isSelected: isSelected),
            titleFont: isSelected ? .caption3SemiBold : .caption3Medium,
            titleColor: isSelected ? DesignSystemAsset.Colors.gray975 : DesignSystemAsset.Colors.gray500
        )
    }

    @Binding private var selectedItem: DSBottomNavigationItem

    public init(selectedItem: Binding<DSBottomNavigationItem>) {
        _selectedItem = selectedItem
    }

    public var body: some View {
        let specification = Self.specification

        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(DSBottomNavigationItem.allCases, id: \.self) { item in
                    itemButton(item, specification: specification)
                }
            }
            .padding(.top, specification.itemTopPadding)
        }
        .padding(.horizontal, specification.contentHorizontalPadding)
        .padding(.vertical, specification.contentVerticalPadding)
        .frame(height: specification.height, alignment: .top)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: specification.topCornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: specification.topCornerRadius,
                style: .continuous
            )
            .fill(specification.backgroundColor.swiftUIColor)
            .shadow(
                color: specification.shadowColor.swiftUIColor.opacity(specification.shadowOpacity),
                radius: specification.shadowRadius,
                y: specification.shadowYOffset
            )
        }
        .dsDebugGeometry("DSBottomNavigation")
    }

    private func itemButton(
        _ item: DSBottomNavigationItem,
        specification: Specification
    ) -> some View {
        let isSelected = item == selectedItem
        let itemSpecification = Self.itemSpecification(for: item, isSelected: isSelected)

        return Button {
            selectedItem = item
        } label: {
            VStack(spacing: specification.itemSpacing) {
                DSIcon(
                    itemSpecification.iconAsset,
                    width: specification.iconSize,
                    height: specification.iconSize,
                    renderingMode: .original
                )
                Text(item.title)
                    .dsFont(itemSpecification.titleFont)
                    .foregroundColor(itemSpecification.titleColor.swiftUIColor)
            }
            .frame(maxWidth: .infinity)
            .dsDebugDetailGeometry("DSBottomNavigation.Item.\(item.title)")
        }
        .buttonStyle(DSBottomNavigationButtonStyle())
        .contentShape(
            DSBottomNavigationVerticalOutsetShape(
                verticalOutset: Self.itemHitAreaVerticalOutset(for: specification)
            )
        )
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private static func itemHitAreaVerticalOutset(for specification: Specification) -> CGFloat {
        let itemLayoutHeight = specification.height
            - (specification.contentVerticalPadding * 2)
            - specification.itemTopPadding
        let minimumHitTargetHeight: CGFloat = 44

        return max(0, (minimumHitTargetHeight - itemLayoutHeight) / 2)
    }
}

private struct DSBottomNavigationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct DSBottomNavigationVerticalOutsetShape: Shape {
    let verticalOutset: CGFloat

    func path(in rect: CGRect) -> Path {
        Path(
            CGRect(
                x: rect.minX,
                y: rect.minY - verticalOutset,
                width: rect.width,
                height: rect.height + (verticalOutset * 2)
            )
        )
    }
}
