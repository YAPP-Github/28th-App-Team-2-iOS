import DesignSystem
import SwiftUI

struct FortuneLuckyActionBanner: View {
    let action: () -> Void

    private static let aspectRatio = 353.0 / 100.0

    var body: some View {
        Button(action: action) {
            Color.clear
                .aspectRatio(Self.aspectRatio, contentMode: .fit)
                .overlay(alignment: .leading) {
                    bannerContent
                        .padding(.leading, 16)
                        .padding(.trailing, 120)
                }
                .background {
                    DSImageAsset.fortuneLuckyActionBanner.image
                        .resizable()
                        .scaledToFill()
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .dsSurfaceButtonStyle(shape: .roundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityHint("행운 액션 탭으로 이동합니다")
    }

    private var bannerContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("운세 기반 행운 액션")
                    .dsBody2SemiBold
                    .foregroundStyle(Color.ds.gray975)

                Circle()
                    .fill(Color.ds.whiteOpacity80)
                    .frame(width: 16, height: 16)
                    .overlay {
                        DSIcon(.chevronSmallRight, width: 12, height: 12)
                            .foregroundStyle(Color.ds.gray600)
                    }
            }

            Text("5개 행운 액션으로 하루 시작하기!")
                .dsCaption2Medium
                .foregroundStyle(Color.ds.opacity60)
        }
    }
}
