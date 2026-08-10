import DesignSystem
import SwiftUI

struct OnboardingSignupLoadingView: View {
    private enum Layout {
        static let referenceHeight: CGFloat = 852
        static let topMessageOffset: CGFloat = 142
        static let topMessageHeight: CGFloat = 48
        static let imageTopSpacing: CGFloat = 30
        static let imageMaximumSide: CGFloat = 378
        static let imageHorizontalInset: CGFloat = 7.5
        static let loadingMessageTopSpacing: CGFloat = 14
        static let loadingMessageHeight: CGFloat = 60
        static let minimumBottomSpacing: CGFloat = 48
    }

    var body: some View {
        GeometryReader { geometry in
            let topMessageOffset = min(
                Layout.topMessageOffset,
                geometry.size.height * Layout.topMessageOffset / Layout.referenceHeight
            )
            let imageTopOffset = topMessageOffset
                + Layout.topMessageHeight
                + Layout.imageTopSpacing
            let availableImageHeight = geometry.size.height
                - imageTopOffset
                - Layout.loadingMessageTopSpacing
                - Layout.loadingMessageHeight
                - Layout.minimumBottomSpacing
            let imageSide = min(
                Layout.imageMaximumSide,
                geometry.size.width - Layout.imageHorizontalInset * 2,
                availableImageHeight
            )
            let loadingMessageOffset = imageTopOffset
                + imageSide
                + Layout.loadingMessageTopSpacing

            ZStack(alignment: .top) {
                signupLoadingBackground

                Text("환영해요!\n가입이 완료되었어요.")
                    .dsBody2Medium
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .offset(y: topMessageOffset)

                OnboardingFeatureAsset.Brand.signupLoadingCharacter.swiftUIImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSide, height: imageSide)
                    .offset(y: imageTopOffset)

                TimelineView(.periodic(from: .now, by: 0.5)) { context in
                    Text(loadingMessage(at: context.date))
                        .dsHeading4Bold
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .frame(height: Layout.loadingMessageHeight, alignment: .top)
                .offset(y: loadingMessageOffset)
                .accessibilityLabel("토닥운이 사주 기반으로 운세를 분석하고 있어요")
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }

    private var signupLoadingBackground: some View {
        Color(red: 1.0 / 255.0, green: 0, blue: 24.0 / 255.0)
            .contentShape(Rectangle())
    }

    private func loadingMessage(at date: Date) -> String {
        let tick = Int(date.timeIntervalSinceReferenceDate * 2)
        let dots = String(repeating: ".", count: tick % 3 + 1)
        return "토닥운이 사주 기반으로\n운세를 분석하고 있어요\(dots)"
    }
}

#Preview {
    OnboardingSignupLoadingView()
}
