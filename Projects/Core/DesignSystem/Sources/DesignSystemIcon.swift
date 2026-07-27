import SwiftUI

/// DesignSystem 에셋 카탈로그에 등록된 아이콘을 식별합니다.
public enum DSIconAsset: String, CaseIterable, Hashable, Sendable {
    case checkLine
    case edit
    case tooltipArrow

    /// 디버그 검사기와 Catalog에서 사용하는 안정적인 에셋 식별자입니다.
    public var name: String { rawValue }

    var image: Image {
        switch self {
        case .checkLine:
            DesignSystemAsset.Icons.checkLine.swiftUIImage
        case .edit:
            DesignSystemAsset.Icons.edit.swiftUIImage
        case .tooltipArrow:
            DesignSystemAsset.Icons.tooltipArrow.swiftUIImage
        }
    }
}
