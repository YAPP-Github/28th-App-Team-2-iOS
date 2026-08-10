import ComposableArchitecture
import DesignSystem
import SwiftUI

struct UserStatusView: View {
    @Bindable private var store: StoreOf<OnboardingFeature>

    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            DSProgressBar(progress: 1) {
                store.send(.onboardingBackButtonTapped)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 36) {
                    Text("당신에 대해 조금만 더\n알려주세요.")
                        .dsHeading2SemiBold
                        .foregroundStyle(Color.ds.gray975)

                    optionSection(
                        question: UserStatusQuestion(
                            number: "Q1",
                            text: "주로 어떤 일상을 보내고 계신가요?"
                        ),
                        options: DailyRoutine.allCases,
                        selectedOption: store.dailyRoutine,
                        optionTitle: \.title,
                        selectionAction: OnboardingFeature.Action.dailyRoutineChanged
                    )

                    optionSection(
                        question: UserStatusQuestion(
                            number: "Q2",
                            text: "현재 연애 상태를 알려주세요."
                        ),
                        options: RomanticRelationshipStatus.allCases,
                        selectedOption: store.romanticRelationshipStatus,
                        optionTitle: \.title,
                        selectionAction: OnboardingFeature.Action.romanticRelationshipStatusChanged
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 64)
                .padding(.bottom, 24)
            }

            if let errorMessage = store.signupPhase.errorMessage {
                VStack(spacing: 8) {
                    Text(errorMessage)
                        .dsCaption1Regular
                        .foregroundStyle(Color.ds.red500)

                    Button("다시 시도") {
                        store.send(.signupRetryButtonTapped)
                    }
                    .dsBody3SemiBold
                    .foregroundStyle(Color.ds.primary600)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }

            DSPrimaryLargeButton(store.signupPhase.isLoading ? "가입 중…" : "시작하기") {
                store.send(.userStatusNextButtonTapped)
            }
            .disabled(!store.isSignupReady || store.signupPhase.isLoading)
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
        .overlay {
            if store.signupPhase.isLoading {
                OnboardingSignupLoadingView()
            }
        }
    }

    private func optionSection<Option: Hashable>(
        question: UserStatusQuestion,
        options: [Option],
        selectedOption: Option?,
        optionTitle: KeyPath<Option, String>,
        selectionAction: @escaping (Option) -> OnboardingFeature.Action
    ) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Text(question.number)
                    .dsBody1Bold
                    .foregroundStyle(Color.ds.primary600)

                Text(question.text)
                    .dsBody1Bold
                    .foregroundStyle(Color.ds.gray975)
            }

            UserStatusFlowLayout(horizontalSpacing: 12, verticalSpacing: 12) {
                ForEach(options, id: \.self) { option in
                    DSChip(
                        option[keyPath: optionTitle],
                        isSelected: selectedOption == option
                    ) {
                        store.send(selectionAction(option))
                    }
                }
            }
        }
    }
}

private struct UserStatusFlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout Void
    ) -> CGSize {
        let availableWidth = proposal.width ?? subviews.reduce(0) { partialResult, subview in
            partialResult + subview.sizeThatFits(.unspecified).width
        }
        let layoutSize = layoutSize(availableWidth: availableWidth, subviews: subviews)

        return CGSize(width: proposal.width ?? layoutSize.width, height: layoutSize.height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal _: ProposedViewSize,
        subviews: Subviews,
        cache _: inout Void
    ) {
        var horizontalPosition = bounds.minX
        var verticalPosition = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if horizontalPosition > bounds.minX && horizontalPosition + size.width > bounds.maxX {
                horizontalPosition = bounds.minX
                verticalPosition += rowHeight + verticalSpacing
                rowHeight = 0
            }

            subview.place(
                at: CGPoint(x: horizontalPosition, y: verticalPosition),
                anchor: .topLeading,
                proposal: ProposedViewSize(size)
            )
            horizontalPosition += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }

    private func layoutSize(availableWidth: CGFloat, subviews: Subviews) -> CGSize {
        var horizontalPosition: CGFloat = 0
        var verticalPosition: CGFloat = 0
        var rowHeight: CGFloat = 0
        var contentWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if horizontalPosition > 0 && horizontalPosition + size.width > availableWidth {
                contentWidth = max(contentWidth, horizontalPosition - horizontalSpacing)
                horizontalPosition = 0
                verticalPosition += rowHeight + verticalSpacing
                rowHeight = 0
            }

            horizontalPosition += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }

        contentWidth = max(contentWidth, horizontalPosition - horizontalSpacing)
        return CGSize(width: contentWidth, height: verticalPosition + rowHeight)
    }
}

private struct UserStatusQuestion {
    let number: String
    let text: String
}
