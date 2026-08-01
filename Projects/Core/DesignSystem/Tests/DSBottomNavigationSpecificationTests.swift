import Testing
@testable import DesignSystem

struct DSBottomNavigationSpecificationTests {
    @Test("Bottom Navigation 컨테이너 스펙 매핑 검증")
    func testContainerSpecification() {
        let specification = DSBottomNavigation.specification

        #expect(specification.height == 56)
        #expect(specification.contentHorizontalPadding == 12)
        #expect(specification.contentVerticalPadding == 5.5)
        #expect(specification.itemTopPadding == 4)
        #expect(specification.itemSpacing == 4)
        #expect(specification.iconSize == 24)
        #expect(specification.topCornerRadius == 24)
        expectColorEqual(specification.backgroundColor, DesignSystemAsset.Colors.white)
        expectColorEqual(specification.shadowColor, DesignSystemAsset.Colors.black)
        #expect(specification.shadowOpacity == 0.06)
        #expect(specification.shadowRadius == 20)
        #expect(specification.shadowYOffset == -4)
    }

    @Test("Bottom Navigation 아이템 선택 상태 스펙 매핑 검증", arguments: DSBottomNavigationItem.allCases)
    func testSelectedItemSpecification(item: DSBottomNavigationItem) {
        let specification = DSBottomNavigation.itemSpecification(for: item, isSelected: true)

        #expect(specification.iconAsset == selectedIconAsset(for: item))
        #expect(specification.titleFont == .caption3SemiBold)
        expectColorEqual(specification.titleColor, DesignSystemAsset.Colors.gray975)
    }

    @Test("Bottom Navigation 아이템 기본 상태 스펙 매핑 검증", arguments: DSBottomNavigationItem.allCases)
    func testUnselectedItemSpecification(item: DSBottomNavigationItem) {
        let specification = DSBottomNavigation.itemSpecification(for: item, isSelected: false)

        #expect(specification.iconAsset == unselectedIconAsset(for: item))
        #expect(specification.titleFont == .caption3Medium)
        expectColorEqual(specification.titleColor, DesignSystemAsset.Colors.gray500)
    }

    private func selectedIconAsset(for item: DSBottomNavigationItem) -> DSIconAsset {
        switch item {
        case .fortune: .naviLuckyOn
        case .todak: .naviAiOn
        case .luckyAction: .naviActionOn
        case .myPage: .naviMyOn
        }
    }

    private func unselectedIconAsset(for item: DSBottomNavigationItem) -> DSIconAsset {
        switch item {
        case .fortune: .naviLuckyOff
        case .todak: .naviAiOff
        case .luckyAction: .naviActionOff
        case .myPage: .naviMyOff
        }
    }
}
