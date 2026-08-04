import SwiftUI

public enum DSIconRenderingMode: Sendable {
    case template
    case original
}

/// DesignSystem 아이콘을 지정한 크기로 렌더링합니다.
///
/// 아이콘 크기는 사용하는 컴포넌트 또는 화면 레이아웃이 결정하므로 기본값을 두지 않습니다.
public struct DSIcon: View {
    private let asset: DSIconAsset
    private let width: CGFloat
    private let height: CGFloat
    private let renderingMode: DSIconRenderingMode

    public init(
        _ asset: DSIconAsset,
        width: CGFloat,
        height: CGFloat,
        renderingMode: DSIconRenderingMode = .template
    ) {
        self.asset = asset
        self.width = width
        self.height = height
        self.renderingMode = renderingMode
    }

    public var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
            .dsDebugGeometry("Icon.\(asset.name)")
    }

    private var image: Image {
        switch renderingMode {
        case .template:
            asset.image.renderingMode(.template)
        case .original:
            asset.image.renderingMode(.original)
        }
    }
}
