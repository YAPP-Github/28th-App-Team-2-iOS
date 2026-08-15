import DesignSystem
import SwiftUI

struct FortuneResultScoreRing: View {
    let score: Int
    let caption: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.ds.whiteOpacity10, lineWidth: 14)

            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(score, 100))) / 100)
                .stroke(
                    LinearGradient(
                        colors: [Color.ds.primary200, Color.ds.primary400],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(Color.ds.white)

                Text(caption)
                    .dsBody3Medium
                    .foregroundStyle(Color.ds.whiteOpacity60)
            }
        }
        .frame(width: 172, height: 172)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(caption) \(score)점")
    }
}

struct FortuneTodakInquiryBar: View {
    let tooltip: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: -6) {
            DSTooltip(tooltip, variant: .standard)
                .zIndex(1)

            DSPrimaryLargeButton("토닥이에게 더 물어보기", action: action)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color.clear)
    }
}
