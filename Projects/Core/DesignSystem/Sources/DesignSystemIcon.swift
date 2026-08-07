import SwiftUI

/// DesignSystem 에셋 카탈로그에 등록된 아이콘을 식별합니다.
public enum DSIconAsset: String, CaseIterable, Hashable, Sendable {
    case bell
    case chatAdd
    case checkLine
    case deleteLine
    case edit
    case circleXFill
    case chevronLeftPlain
    case chevronLeftNarrow
    case notes
    case chevronSmallBottom
    case tooltipArrow
    case closeLine
    case arrowUpward
    case delete
    case naviLuckyOn
    case naviLuckyOff
    case naviAiOn
    case naviAiOff
    case naviActionOn
    case naviActionOff
    case naviMyOn
    case naviMyOff

    /// 디버그 검사기와 Catalog에서 사용하는 안정적인 에셋 식별자입니다.
    public var name: String { rawValue }

    var image: Image {
        switch self {
        case .bell:
            DesignSystemAsset.Icons.bell.swiftUIImage
        case .chatAdd:
            DesignSystemAsset.Icons.chatAdd.swiftUIImage
        case .checkLine:
            DesignSystemAsset.Icons.checkLine.swiftUIImage
        case .deleteLine:
            DesignSystemAsset.Icons.deleteLine.swiftUIImage
        case .edit:
            DesignSystemAsset.Icons.edit.swiftUIImage
        case .circleXFill:
            DesignSystemAsset.Icons.circleXFill.swiftUIImage
        case .chevronLeftPlain:
            DesignSystemAsset.Icons.chevronLeftPlain.swiftUIImage
        case .chevronLeftNarrow:
            DesignSystemAsset.Icons.chevronLeftNarrow.swiftUIImage
        case .notes:
            DesignSystemAsset.Icons.notes.swiftUIImage
        case .chevronSmallBottom:
            DesignSystemAsset.Icons.chevronSmallBottom.swiftUIImage
        case .tooltipArrow:
            DesignSystemAsset.Icons.tooltipArrow.swiftUIImage
        case .closeLine:
            DesignSystemAsset.Icons.closeLine.swiftUIImage
        case .arrowUpward:
            DesignSystemAsset.Icons.arrowUpward.swiftUIImage
        case .delete:
            DesignSystemAsset.Icons.delete.swiftUIImage
        case .naviLuckyOn:
            DesignSystemAsset.Icons.naviLuckyOn.swiftUIImage
        case .naviLuckyOff:
            DesignSystemAsset.Icons.naviLuckyOff.swiftUIImage
        case .naviAiOn:
            DesignSystemAsset.Icons.naviAiOn.swiftUIImage
        case .naviAiOff:
            DesignSystemAsset.Icons.naviAiOff.swiftUIImage
        case .naviActionOn:
            DesignSystemAsset.Icons.naviActionOn.swiftUIImage
        case .naviActionOff:
            DesignSystemAsset.Icons.naviActionOff.swiftUIImage
        case .naviMyOn:
            DesignSystemAsset.Icons.naviMyOn.swiftUIImage
        case .naviMyOff:
            DesignSystemAsset.Icons.naviMyOff.swiftUIImage
        }
    }
}
