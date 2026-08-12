import DesignSystem
import SwiftUI

struct FortuneLoadingView: View {
    var body: some View {
        ProgressView("오늘의 운세를 불러오는 중이에요")
            .tint(Color.ds.white)
            .foregroundStyle(Color.ds.white)
            .dsBody3Medium
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("오늘의 운세를 불러오는 중")
    }
}

struct FortuneFailureView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .dsBody1Medium
                .foregroundStyle(Color.ds.white)
                .multilineTextAlignment(.center)

            DSPrimaryMediumButton("다시 시도", action: retryAction)
                .frame(maxWidth: 180)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
