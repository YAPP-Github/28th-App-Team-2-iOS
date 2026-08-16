import ComposableArchitecture
import DesignSystem
import NotificationFeatureInterface
import SwiftUI

public struct NotificationView: View {
    @Bindable private var store: StoreOf<NotificationFeature>
    private let loadsOnAppear: Bool

    @Dependency(\.date.now) private var now

    public init(
        store: StoreOf<NotificationFeature>,
        loadsOnAppear: Bool = true
    ) {
        self.store = store
        self.loadsOnAppear = loadsOnAppear
    }

    public var body: some View {
        VStack(spacing: 0) {
            DSHeaderSub(
                title: "알림",
                leftItem: DSHeaderActionItem(
                    identifier: "back",
                    icon: .chevronLeftNarrow,
                    action: { store.send(.view(.backButtonTapped)) }
                )
            )

            content
        }
        .background(Color.ds.white)
        .task {
            if loadsOnAppear {
                await store.send(.view(.task)).finish()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var content: some View {
        switch store.viewState {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded([]):
            NotificationEmptyView()

        case let .loaded(notifications):
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(notifications) { notification in
                        NotificationRow(
                            notification: notification,
                            time: NotificationTimeFormatter.string(
                                createdAt: notification.createdAt,
                                now: now
                            ),
                            isReadPending: store.pendingReadIDs.contains(notification.id),
                            action: { store.send(.view(.notificationTapped(notification.id))) }
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)

        case let .failed(message):
            NotificationFailureView(
                message: message,
                retry: { store.send(.view(.retryButtonTapped)) }
            )
        }
    }
}

private struct NotificationRow: View {
    let notification: InAppNotification
    let time: String
    let isReadPending: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    DSBadge(notification.type.label, variant: .gray)

                    Spacer(minLength: 0)

                    Text(time)
                        .dsCaption1Regular
                        .foregroundStyle(DesignSystemAsset.Colors.gray600.swiftUIColor)
                }
                .frame(minHeight: 20)

                Text(notification.content)
                    .dsBody2Medium
                    .foregroundStyle(Color.ds.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
            .contentShape(Rectangle())
        }
        .dsSurfaceButtonStyle(shape: .roundedRectangle(cornerRadius: 0))
        .disabled(isReadPending)

        DSThinDivider()
    }
}

private struct NotificationEmptyView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("새로운 알림이 없어요.")
                .dsBody2Medium
                .foregroundStyle(Color.ds.black)

            Text("새 소식이 도착하면 여기에서 알려드릴게요.")
                .dsBody3Regular
                .foregroundStyle(DesignSystemAsset.Colors.gray500.swiftUIColor)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }
}

private struct NotificationFailureView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .dsBody2Medium
                .foregroundStyle(Color.ds.black)

            DSButton("다시 시도", variant: .secondary, size: .medium, action: retry)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }
}
