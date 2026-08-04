import CoreGraphics
import Testing
@testable import DesignSystem

struct DSBottomNavigationSpecificationTests {
    @Test("Bottom Navigation 컨테이너 스펙 매핑 검증")
    func testContainerSpecification() throws {
        let specification = DSBottomNavigation.specification

        #expect(specification.height == 56)
        #expect(specification.contentHorizontalPadding == 12)
        #expect(specification.contentVerticalPadding == 5.5)
        #expect(specification.itemTopPadding == 4)
        #expect(specification.itemSpacing == 4)
        #expect(specification.iconSize == 24)
        #expect(specification.shape == .unevenRoundedRectangle(topCornerRadius: 24))
        let pressedOverlay = try #require(specification.pressedOverlay)
        expectColorEqual(pressedOverlay.asset, DesignSystemAsset.Colors.gray975)
        #expect(pressedOverlay.opacity == 0.16)
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

    @Test("Bottom Navigation 아이템 hit area는 세로로만 확장")
    func testItemHitAreaExpandsVerticallyOnly() {
        let specification = DSBottomNavigation.specification
        let verticalOutset = DSBottomNavigation.itemHitAreaVerticalOutset(for: specification)

        #expect(verticalOutset == 1.5)

        let originalRect = CGRect(
            x: 12,
            y: 10,
            width: 82,
            height: specification.height
                - (specification.contentVerticalPadding * 2)
                - specification.itemTopPadding
        )
        let shape = DSBottomNavigationVerticalOutsetShape(verticalOutset: verticalOutset)

        #expect(
            shape.path(in: originalRect).boundingRect == CGRect(
                x: 12,
                y: 8.5,
                width: 82,
                height: 44
            )
        )
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
