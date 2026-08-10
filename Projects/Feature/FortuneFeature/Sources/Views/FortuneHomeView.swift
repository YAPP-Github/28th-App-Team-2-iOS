import DesignSystem
import SwiftUI

struct FortuneHomeView: View {
    let content: FortuneHomeContent
    let action: (FortuneFeature.Action.ViewAction) -> Void

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
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.ds.white)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 32,
                        topTrailingRadius: 32
                    )
                )
            }
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .background {
            FortuneSpaceBackground()
        }
    }
}

private struct FortuneSpaceBackground: View {
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
        .ignoresSafeArea()
    }
}

private extension Color {
    static let fortuneSpaceBase = Color(
        red: 0,
        green: 1.0 / 255.0,
        blue: 11.0 / 255.0
    )
}
