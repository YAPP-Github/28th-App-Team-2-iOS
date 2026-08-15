import ComposableArchitecture
import DesignSystem
import LuckyActionFeatureInterface
import SwiftUI

public struct LuckyActionView: View {
    @Bindable private var store: StoreOf<LuckyActionFeature>

    public init(store: StoreOf<LuckyActionFeature>) {
        self.store = store
    }

    public var body: some View {
        LuckyActionScreen(
            presentationStyle: store.presentationStyle,
            selectedDate: store.selectedDate,
            canMoveToNextDate: store.canMoveToNextDate,
            canToggleActions: store.canToggleActions,
            viewState: store.viewState,
            pendingActionIDs: store.pendingActionIDs,
            completion: store.completion,
            send: { store.send(.view($0)) }
        )
        .task {
            await store.send(.view(.task)).finish()
        }
        .toolbar(
            store.presentationStyle == .pushed ? .hidden : .automatic,
            for: .navigationBar
        )
    }
}

private struct LuckyActionScreen: View {
    let presentationStyle: LuckyActionFeature.PresentationStyle
    let selectedDate: Date
    let canMoveToNextDate: Bool
    let canToggleActions: Bool
    let viewState: LuckyActionFeature.State.ViewState
    let pendingActionIDs: Set<LuckyAction.ID>
    let completion: LuckyActionCompletion?
    let send: (LuckyActionFeature.Action.ViewAction) -> Void

    var body: some View {
        ZStack {
            Color.ds.white.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                content
            }

            if let completion {
                LuckyActionCompletionOverlay(
                    completion: completion,
                    dismiss: { send(.completionDismissButtonTapped) }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: completion)
    }

    @ViewBuilder
    private var header: some View {
        switch presentationStyle {
        case .tab:
            DSHeaderMain(title: "행운 액션")
        case .pushed:
            DSHeaderSub(
                title: "행운 액션",
                leftItem: DSHeaderActionItem(
                    identifier: "lucky-action-back",
                    icon: .chevronLeftNarrow,
                    action: { send(.backButtonTapped) }
                )
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewState {
        case .loading:
            ProgressView()
                .tint(Color.ds.primary600)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .loaded(actions):
            LuckyActionContent(
                actions: actions,
                pendingActionIDs: pendingActionIDs,
                isActionToggleEnabled: canToggleActions,
                selectedDate: selectedDate,
                canMoveToNextDate: canMoveToNextDate,
                actionToggled: { send(.actionToggled($0)) },
                previousDateTapped: { send(.previousDateTapped) },
                nextDateTapped: { send(.nextDateTapped) }
            )

        case let .failed(message):
            LuckyActionFailureView(
                message: message,
                retry: { send(.retryButtonTapped) }
            )
        }
    }
}

private struct LuckyActionContent: View {
    let actions: [LuckyAction]
    let pendingActionIDs: Set<LuckyAction.ID>
    let isActionToggleEnabled: Bool
    let selectedDate: Date
    let canMoveToNextDate: Bool
    let actionToggled: (LuckyAction.ID) -> Void
    let previousDateTapped: () -> Void
    let nextDateTapped: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                LuckyActionGuide()

                if !actions.isEmpty {
                    LuckyActionScoreSummary(actions: actions)
                }

                LuckyActionList(
                    actions: actions,
                    pendingActionIDs: pendingActionIDs,
                    isActionToggleEnabled: isActionToggleEnabled,
                    selectedDate: selectedDate,
                    canMoveToNextDate: canMoveToNextDate,
                    actionToggled: actionToggled,
                    previousDateTapped: previousDateTapped,
                    nextDateTapped: nextDateTapped
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 72)
        }
    }
}

private struct LuckyActionGuide: View {
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("사주 분석을 바탕으로\n행운을 올릴 수 있는\n액션을 추천드려요")
                .dsBody1Bold
                .foregroundStyle(Color.ds.gray975)

            Spacer(minLength: 0)

            LuckyActionFeatureAsset.luckyActionClover.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 92, height: 92)
                .accessibilityHidden(true)
        }
    }
}

private struct LuckyActionScoreSummary: View {
    let actions: [LuckyAction]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                VStack(spacing: 8) {
                    Text(action.category.summaryTitle)
                        .dsCaption3SemiBold
                        .foregroundStyle(Color.ds.gray975)
                        .frame(maxWidth: .infinity)

                    Text("\(action.score)")
                        .dsBody3SemiBold
                        .foregroundStyle(Color.ds.primary700)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 2)
                        .background(Color.ds.white.opacity(0.9))
                        .clipShape(Capsule())
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, minHeight: 45)

                if index < actions.count - 1 {
                    Rectangle()
                        .fill(Color.ds.opacity05)
                        .frame(width: 1, height: 48)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(height: 72)
        .frame(maxWidth: .infinity)
        .background(Color.ds.primary100)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut(duration: 0.25), value: actions)
    }
}

private struct LuckyActionList: View {
    let actions: [LuckyAction]
    let pendingActionIDs: Set<LuckyAction.ID>
    let isActionToggleEnabled: Bool
    let selectedDate: Date
    let canMoveToNextDate: Bool
    let actionToggled: (LuckyAction.ID) -> Void
    let previousDateTapped: () -> Void
    let nextDateTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LuckyActionDateNavigation(
                selectedDate: selectedDate,
                canMoveToNextDate: canMoveToNextDate,
                previousDateTapped: previousDateTapped,
                nextDateTapped: nextDateTapped
            )

            if actions.isEmpty {
                LuckyActionEmptyState()
            } else {
                VStack(spacing: 12) {
                    ForEach(actions) { action in
                        LuckyActionCard(
                            action: action,
                            isPending: pendingActionIDs.contains(action.id),
                            isActionToggleEnabled: isActionToggleEnabled,
                            toggle: { actionToggled(action.id) }
                        )
                    }
                }
            }
        }
    }
}

private struct LuckyActionCard: View {
    let action: LuckyAction
    let isPending: Bool
    let isActionToggleEnabled: Bool
    let toggle: () -> Void

    var body: some View {
        DSCheckboxRow(
            isOn: Binding(
                get: { action.isAchieved },
                set: { _ in toggle() }
            ),
            indicatorPlacement: .trailing,
            minimumIndicatorSpacing: 12
        ) {
            HStack(alignment: .center, spacing: 8) {
                DSBadge(action.category.badgeTitle, variant: badgeVariant)

                Text(action.title)
                    .dsBody3SemiBold
                    .foregroundStyle(Color.ds.gray975)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(20)
        .background(Color.ds.coolGray50)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .disabled(isPending || !isActionToggleEnabled)
        .animation(.easeInOut(duration: 0.2), value: action.isAchieved)
    }

    private var badgeVariant: DSBadgeVariant {
        switch action.category {
        case .relationship: .purple
        case .love: .pink
        case .achievement: .green
        case .health: .yellow
        case .money: .blue
        }
    }
}

private struct LuckyActionFailureView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .dsBody2Medium
                .foregroundStyle(Color.ds.gray600)

            Button("다시 시도") {
                retry()
            }
            .dsSurfaceButtonStyle(shape: .roundedRectangle(cornerRadius: 6))
            .dsBody3SemiBold
            .foregroundStyle(Color.ds.primary700)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct LuckyActionCompletionOverlay: View {
    let completion: LuckyActionCompletion
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.ds.opacity50
                .ignoresSafeArea()
                .accessibilityHidden(true)

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

                Text("오늘의 \(completion.category.summaryTitle)이 올랐어요 💗")
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
