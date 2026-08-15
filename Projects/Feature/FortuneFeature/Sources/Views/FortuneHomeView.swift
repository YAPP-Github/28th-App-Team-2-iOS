import DesignSystem
import SwiftUI

struct FortuneHomeView: View {
    private struct ScrollMetrics: Equatable, Sendable {
        var offsetY: CGFloat = 0
        var topSafeAreaInset: CGFloat = 0
    }

    private static let sheetTopCornerRadius: CGFloat = 32
    private static let scrollCoordinateSpaceName = "FortuneScrollView"

    let content: FortuneHomeContent
    let action: (FortuneFeature.Action.ViewAction) -> Void

    @State private var scrollMetrics = ScrollMetrics()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                FortuneHeroSection(
                    content: content,
                    notificationAction: {
                        action(.notificationButtonTapped)
                    },
                    reportAction: {
                        action(.fortuneReportButtonTapped)
                    }
                )

                VStack(alignment: .leading, spacing: 0) {
                    FortuneCategorySection(
                        categoryScores: content.categoryScores,
                        selectionAction: { category in
                            action(.fortuneCategoryTapped(category))
                        }
                    )

                    FortuneReadingSection { reading in
                        action(.fortuneReadingTapped(reading))
                    }
                    .padding(.top, 44)

                    FortuneLuckyActionBanner {
                        action(.luckyActionBannerTapped)
                    }
                    .padding(.top, 28)
                }
                .padding(.top, 36)
                .padding(.bottom, 100)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.ds.white)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: Self.sheetTopCornerRadius,
                        topTrailingRadius: Self.sheetTopCornerRadius
                    )
                )
            }
            .frame(maxWidth: .infinity)
            .onGeometryChange(for: ScrollMetrics.self) { proxy in
                let offsetY = proxy.frame(in: .named(Self.scrollCoordinateSpaceName)).minY
                let globalMinY = proxy.frame(in: .global).minY

                return ScrollMetrics(
                    offsetY: offsetY,
                    topSafeAreaInset: max(0, globalMinY - offsetY)
                )
            } action: { newMetrics in
                scrollMetrics = newMetrics
            }
        }
        .coordinateSpace(name: Self.scrollCoordinateSpaceName)
        .scrollIndicators(.hidden)
        .background(alignment: .top) {
            ZStack(alignment: .top) {
                Color.ds.white

                stretchyGalaxyBackground
            }
        }
    }

    private var stretchyGalaxyBackground: some View {
        let normalHeight = scrollMetrics.topSafeAreaInset
            + FortuneHeroSection.minimumHeight
            + Self.sheetTopCornerRadius
        let pullOffset = max(0, scrollMetrics.offsetY)
        let galaxyHeight = normalHeight + pullOffset
        let galaxyOffsetY = min(0, scrollMetrics.offsetY)

        return FortuneSpaceBackground()
            .frame(height: galaxyHeight)
            .offset(y: galaxyOffsetY)
            .ignoresSafeArea(edges: .top)
    }
}

struct FortuneSpaceBackground: View {
    private static let sourceAspectRatio = CGFloat(393.0 / 850.0)

    var body: some View {
        GeometryReader { proxy in
            let imageHeight = proxy.size.width / Self.sourceAspectRatio

            ZStack(alignment: .top) {
                Color.fortuneSpaceBase

                DSImageAsset.fortuneSpaceBackground.image
                    .resizable()
                    .frame(
                        width: proxy.size.width,
                        height: imageHeight
                    )
            }
        }
        .clipped()
    }
}

extension Color {
    static let fortuneSpaceBase = Color(
        red: 0,
        green: 1.0 / 255.0,
        blue: 11.0 / 255.0
    )
}
