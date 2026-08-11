import DesignSystem
import SwiftUI

struct FortuneHeroSection: View {
    static let minimumHeight: CGFloat = 319

    let content: FortuneHomeContent
    let notificationAction: () -> Void
    let reportAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            FortuneHomeHeader(notificationAction: notificationAction)

            HStack(alignment: .center, spacing: 0) {
                Text(content.title)
                    .dsBody1Bold
                    .foregroundStyle(Color.ds.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)

                FortuneMoodCharacterImage(moodLevel: content.moodLevel)
                    .frame(width: 109, height: 102)
                    .padding(10)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 28)
            .frame(minHeight: 122)

            FortuneScoreCard(
                score: content.displayScore,
                scoreDescription: content.scoreDescription,
                action: reportAction
            )
            .padding(.horizontal, 28)
            .padding(.top, 24)

            Spacer(minLength: 44)
        }
        .frame(minHeight: Self.minimumHeight)
    }
}

private struct FortuneHomeHeader: View {
    let notificationAction: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            DSImageAsset.fortuneLogo.image
                .resizable()
                .scaledToFit()
                .frame(width: 89, height: 26)
                .accessibilityLabel("토닥운")

            Spacer(minLength: 0)

            Button(action: notificationAction) {
                DSIcon(.bell, width: 24, height: 24)
                    .foregroundStyle(Color.ds.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .dsIconButtonStyle(.bell, width: 24, height: 24)
            .accessibilityLabel("알림")
        }
        .padding(.leading, 20)
        .padding(.trailing, 10)
        .frame(height: 60)
    }
}

private struct FortuneScoreCard: View {
    let score: Int
    let scoreDescription: String?
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("오늘의 점수")
                    .dsCaption3Regular
                    .foregroundStyle(Color.ds.whiteOpacity60)

                HStack(spacing: 4) {
                    Text("\(score)점")
                        .dsBody2SemiBold
                        .foregroundStyle(Color.ds.white)

                    if let scoreDescription {
                        Text("∙")
                            .dsBody3Medium
                            .foregroundStyle(Color.ds.primary300)

                        Text(scoreDescription)
                            .dsBody3Medium
                            .foregroundStyle(Color.ds.primary300)
                            .lineLimit(1)
                    }
                }
            }
            .layoutPriority(1)

            Spacer(minLength: 0)

            Button(action: action) {
                HStack(spacing: 4) {
                    Text("운세 리포트")
                        .dsBody3Medium

                    DSIcon(.chevronSmallRight, width: 16, height: 16)
                }
                .foregroundStyle(Color.ds.white)
                .padding(.horizontal, 8)
                .frame(width: 100, height: 28)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color.ds.whiteOpacity80, lineWidth: 0.5)
                }
            }
            .dsSurfaceButtonStyle(shape: .capsule)
            .frame(width: 100, height: 44)
            .contentShape(Rectangle())
            .accessibilityLabel("운세 리포트 보기")
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 69)
        .background(Color.ds.whiteOpacity10)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.ds.whiteOpacity30, lineWidth: 1)
        }
    }
}
