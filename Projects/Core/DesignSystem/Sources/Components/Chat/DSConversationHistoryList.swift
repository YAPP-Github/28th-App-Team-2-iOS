import SwiftUI

public struct DSConversationHistoryList: View {
    public struct Specification: Sendable {
        public let contentWidth: CGFloat
        public let horizontalPadding: CGFloat
        public let topPadding: CGFloat
        public let bottomPadding: CGFloat
        public let titleFont: FontStyle
        public let titleColorAsset: DesignSystemColors
        public let titleLineLimit: Int
        public let titleIndicatorWidth: CGFloat
        public let indicatorSize: CGFloat
        public let indicatorColorAsset: DesignSystemColors
        public let titleIndicatorSpacing: CGFloat
        public let deleteIcon: DSIconAsset
        public let deleteIconSize: CGFloat
        public let deleteIconColorAsset: DesignSystemColors
        public let titleDeleteSpacing: CGFloat
        public let timeFont: FontStyle
        public let timeColorAsset: DesignSystemColors
        public let titleTimeSpacing: CGFloat
    }

    public static let specification = Specification(
        contentWidth: 353,
        horizontalPadding: 20,
        topPadding: 20,
        bottomPadding: 20,
        titleFont: .body1Medium,
        titleColorAsset: DesignSystemAsset.Colors.black,
        titleLineLimit: 1,
        titleIndicatorWidth: 320,
        indicatorSize: 6,
        indicatorColorAsset: DesignSystemAsset.Colors.red400,
        titleIndicatorSpacing: 6,
        deleteIcon: .delete,
        deleteIconSize: 23,
        deleteIconColorAsset: DesignSystemAsset.Colors.gray500,
        titleDeleteSpacing: 10,
        timeFont: .body3Regular,
        timeColorAsset: DesignSystemAsset.Colors.gray600,
        titleTimeSpacing: 10
    )

    private let title: String
    private let time: String
    private let showsUnreadIndicator: Bool
    private let onDelete: () -> Void

    public init(
        title: String,
        time: String,
        showsUnreadIndicator: Bool,
        onDelete: @escaping () -> Void
    ) {
        self.title = title
        self.time = time
        self.showsUnreadIndicator = showsUnreadIndicator
        self.onDelete = onDelete
    }

    public var body: some View {
        let specification = Self.specification

        VStack(alignment: .leading, spacing: specification.titleTimeSpacing) {
            HStack(alignment: .top, spacing: specification.titleDeleteSpacing) {
                HStack(alignment: .top, spacing: specification.titleIndicatorSpacing) {
                    Text(title)
                        .dsFont(specification.titleFont)
                        .foregroundStyle(specification.titleColorAsset.swiftUIColor)
                        .lineLimit(specification.titleLineLimit)
                        .truncationMode(.tail)

                    if showsUnreadIndicator {
                        Circle()
                            .fill(specification.indicatorColorAsset.swiftUIColor)
                            .frame(
                                width: specification.indicatorSize,
                                height: specification.indicatorSize
                            )
                            .dsDebugDetailGeometry("DSConversationHistoryList.UnreadIndicator")
                    }
                }
                .frame(width: specification.titleIndicatorWidth, alignment: .leading)

                Button(action: onDelete) {
                    DSIcon(
                        specification.deleteIcon,
                        width: specification.deleteIconSize,
                        height: specification.deleteIconSize
                    )
                    .foregroundStyle(specification.deleteIconColorAsset.swiftUIColor)
                    .dsDebugDetailGeometry("DSConversationHistoryList.Delete")
                }
                .buttonStyle(
                    DSIconButtonStyle(
                        iconAsset: specification.deleteIcon,
                        iconSize: CGSize(width: specification.deleteIconSize, height: specification.deleteIconSize),
                        pressedOverlay: .standard
                    )
                )
            }
            .frame(width: specification.contentWidth, alignment: .leading)

            Text(time)
                .dsFont(specification.timeFont)
                .foregroundStyle(specification.timeColorAsset.swiftUIColor)
                .frame(width: specification.contentWidth, alignment: .leading)
        }
        .padding(.horizontal, specification.horizontalPadding)
        .padding(.top, specification.topPadding)
        .padding(.bottom, specification.bottomPadding)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .dsDebugGeometry("DSConversationHistoryList")
    }
}
