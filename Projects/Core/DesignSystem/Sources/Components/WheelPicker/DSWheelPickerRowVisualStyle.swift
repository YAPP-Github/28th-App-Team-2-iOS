import SwiftUI

struct DSWheelPickerRowVisualStyle {
    enum Emphasis: Equatable {
        case selected
        case adjacent
        case outer
    }

    static let transition = Animation.easeOut(duration: 0.14)

    let fontStyle: FontStyle
    let foregroundAsset: DesignSystemColors
    let emphasis: Emphasis

    static func selected(
        fontStyle: FontStyle,
        foregroundAsset: DesignSystemColors
    ) -> Self {
        Self(fontStyle: fontStyle, foregroundAsset: foregroundAsset, emphasis: .selected)
    }

    static func adjacent(
        fontStyle: FontStyle,
        foregroundAsset: DesignSystemColors
    ) -> Self {
        Self(fontStyle: fontStyle, foregroundAsset: foregroundAsset, emphasis: .adjacent)
    }

    static func outer(
        fontStyle: FontStyle,
        foregroundAsset: DesignSystemColors
    ) -> Self {
        Self(fontStyle: fontStyle, foregroundAsset: foregroundAsset, emphasis: .outer)
    }
}
