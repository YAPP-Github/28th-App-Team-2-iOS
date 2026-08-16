import DesignSystem
import LuckyActionFeatureInterface
import SwiftUI

public struct LuckyActionCompletionContent: View {
    private let completion: LuckyActionCompletion
    private let dismiss: () -> Void

    public init(
        completion: LuckyActionCompletion,
        dismiss: @escaping () -> Void
    ) {
        self.completion = completion
        self.dismiss = dismiss
    }

    public var body: some View {
        VStack(spacing: 36) {
            LuckyActionFeatureAsset.luckyActionCompletionCharacter.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 229)
                .accessibilityHidden(true)

            LuckyActionCompletionBubble(
                completion: completion,
                dismiss: dismiss
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

private struct LuckyActionCompletionBubble: View {
    let completion: LuckyActionCompletion
    let dismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            LuckyActionBubblePointer()
                .fill(Color.ds.white)
                .frame(width: 19.5, height: 14)
                .offset(y: -114)

            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Color.clear
                        .frame(width: 20, height: 20)

                    Text("행운 액션 완료!")
                        .dsHeading4Bold
                        .foregroundStyle(Color.ds.coolGray900)
                        .frame(maxWidth: .infinity)

                    Button(action: dismiss) {
                        DSIcon(.closeLine, width: 20, height: 20)
                            .foregroundStyle(Color.ds.gray500)
                    }
                    .dsIconButtonStyle(.closeLine, width: 20, height: 20)
                }
                .frame(height: 30)

                Text("오늘의 \(completion.category.summaryTitle)이 올랐어요 💌")
                    .dsBody2Regular
                    .foregroundStyle(Color.ds.coolGray600)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, minHeight: 114, maxHeight: 114)
            .background(Color.ds.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity, minHeight: 128, maxHeight: 128)
    }
}
