import DesignSystem
import SwiftUI

struct LuckyActionDateNavigation: View {
    let selectedDate: Date
    let canMoveToNextDate: Bool
    let previousDateTapped: () -> Void
    let nextDateTapped: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(LuckyActionDateFormatter.listTitle(selectedDate))
                .dsBody2SemiBold
                .foregroundStyle(Color.ds.gray975)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Button(action: previousDateTapped) {
                    LuckyActionFeatureAsset.arrowLeftS.swiftUIImage
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.ds.gray975)
                }
                .dsIconButtonStyle(width: 24, height: 24)
                .accessibilityLabel("이전 날짜")

                Button(action: nextDateTapped) {
                    LuckyActionFeatureAsset.arrowRightS.swiftUIImage
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(canMoveToNextDate ? Color.ds.gray975 : Color.ds.gray500)
                }
                .dsIconButtonStyle(width: 24, height: 24)
                .disabled(!canMoveToNextDate)
                .accessibilityLabel("다음 날짜")
            }
        }
    }
}

struct LuckyActionEmptyState: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("이 날짜의 행운 액션이 없어요.")
                .dsBody2SemiBold
                .foregroundStyle(Color.ds.gray975)

            Text("다른 날짜의 행운 액션을 확인해 보세요.")
                .dsBody3Regular
                .foregroundStyle(Color.ds.gray600)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}
