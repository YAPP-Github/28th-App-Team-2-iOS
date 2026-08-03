import SwiftUI

/// DesignSystem 에셋 카탈로그에 등록된 아이콘을 식별합니다.
public enum DSIconAsset: String, CaseIterable, Hashable, Sendable {
    case chatAdd
    case checkLine
    case deleteLine
    case edit
    case circleXFill
    case chevronLeftPlain
    case notes
    case chevronSmallBottom
    case tooltipArrow
    case closeLine

    /// 디버그 검사기와 Catalog에서 사용하는 안정적인 에셋 식별자입니다.
    public var name: String { rawValue }

    var image: Image {
        switch self {
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
        case .notes:
            DesignSystemAsset.Icons.notes.swiftUIImage
        case .chevronSmallBottom:
            DesignSystemAsset.Icons.chevronSmallBottom.swiftUIImage
        case .tooltipArrow:
            DesignSystemAsset.Icons.tooltipArrow.swiftUIImage
        case .closeLine:
            DesignSystemAsset.Icons.closeLine.swiftUIImage
        }
    }
}
