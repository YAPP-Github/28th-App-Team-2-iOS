import SwiftUI

/// DesignSystem 아이콘을 지정한 크기로 렌더링합니다.
///
/// 아이콘 크기는 사용하는 컴포넌트 또는 화면 레이아웃이 결정하므로 기본값을 두지 않습니다.
public struct DSIcon: View {
    private let asset: DSIconAsset
    private let width: CGFloat
    private let height: CGFloat

    public init(
        _ asset: DSIconAsset,
        width: CGFloat,
        height: CGFloat
    ) {
        self.asset = asset
        self.width = width
        self.height = height
    }

    public var body: some View {
        asset.image
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
            .dsDebugGeometry("Icon.\(asset.name)")
    }
}
