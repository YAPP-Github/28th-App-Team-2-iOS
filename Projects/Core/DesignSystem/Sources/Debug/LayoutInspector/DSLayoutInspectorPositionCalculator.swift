#if DEBUG
import UIKit

enum DSLayoutInspectorPositionCalculator {
    private static let edgeMargin: CGFloat = 12
    private static let menuButtonLength: CGFloat = 44
    private static let menuButtonSpacing: CGFloat = 8
    private static let menuButtonCount: CGFloat = 5

    private static var menuHalfHeight: CGFloat {
        let buttonHeights = menuButtonLength * menuButtonCount
        let spacingHeights = menuButtonSpacing * (menuButtonCount - 1)
        return (buttonHeights + spacingHeights) / 2
    }

    static func informationOffset(
        _ offset: CGFloat,
        availableHeight: CGFloat,
        panelHeight: CGFloat,
        safeAreaInsets: UIEdgeInsets
    ) -> CGFloat {
        let measuredPanelHeight = max(panelHeight, 72)
        let maximumUpwardOffset = max(
            availableHeight
                - safeAreaInsets.top
                - safeAreaInsets.bottom
                - measuredPanelHeight
                - edgeMargin * 2,
            0
        )

        return min(max(offset, -maximumUpwardOffset), 0)
    }

    static func menuOffset(
        _ offset: CGFloat,
        availableHeight: CGFloat,
        safeAreaInsets: UIEdgeInsets
    ) -> CGFloat {
        let centeredOrigin = availableHeight / 2
        let topLimit = safeAreaInsets.top + menuHalfHeight + edgeMargin - centeredOrigin
        let bottomLimit = availableHeight
            - safeAreaInsets.bottom
            - menuHalfHeight
            - edgeMargin
            - centeredOrigin
        let lowerBound = min(topLimit, bottomLimit)
        let upperBound = max(topLimit, bottomLimit)

        return min(max(offset, lowerBound), upperBound)
    }
}
#endif
