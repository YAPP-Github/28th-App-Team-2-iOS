import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct TodakView: View {
    @Bindable var store: StoreOf<TodakFeature>

    private enum ScrollAnchor {
        static let entry = "todak-entry"
    }

    public init(store: StoreOf<TodakFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            switch store.screen {
            case .chat:
                chatScreen
            case .history:
                historyScreen
            }

            if store.showsSplash {
                splashView
                    .transition(.opacity)
                    .zIndex(2)
            }

            if let category = store.guideCategory {
                guideOverlay(category: category)
                    .zIndex(3)
            }

            if store.pendingDeletionID != nil {
                deleteConfirmationOverlay
                    .zIndex(4)
            }
        }
        .overlay(alignment: .bottom) {
            if let message = store.toastMessage {
                DSToast(message) {
                    store.send(.toastDismissed)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(5)
            }
        }
        .animation(.easeOut(duration: 0.2), value: store.showsSplash)
        .animation(.easeOut(duration: 0.2), value: store.guideCategory)
        .animation(.easeOut(duration: 0.2), value: store.toastMessage)
        .background(DesignSystemAsset.Colors.white.swiftUIColor)
        .task { store.send(.task) }
    }

    private var chatScreen: some View {
        VStack(spacing: 0) {
            DSTodakHeader(
                remainingFreeChatCount: store.quota.remaining,
                freeChatLimit: store.quota.limit,
                rightItems: [
                    DSHeaderActionItem(identifier: "new-chat", icon: .chatAdd) {
                        store.send(.newChatButtonTapped)
                    },
                    DSHeaderActionItem(identifier: "history", icon: .notes) {
                        store.send(.historyButtonTapped)
                    }
                ],
                onClose: { store.send(.closeButtonTapped) }
            )

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        if store.messages.isEmpty {
                            entryContent
                                .id(ScrollAnchor.entry)
                        } else {
                            TodakChatAvatar(category: store.activeCategory)

                            Text(store.entry.greeting)
                                .dsBody1Medium
                                .foregroundStyle(DesignSystemAsset.Colors.black.swiftUIColor)

                            ForEach(store.messages) { message in
                                messageView(message)
                                    .id(message.id)
                            }

                            if store.isStreaming && store.assistantMessageID == nil {
                                typingIndicator
                                    .id("typing-indicator")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, store.messages.isEmpty ? 16 : 20)
                    .padding(.bottom, 20)
                }
                .defaultScrollAnchor(.top)
                .onAppear {
                    scrollToCurrentContent(using: proxy, animated: false)
                }
                .onChange(of: store.messages) { _, _ in
                    scrollToCurrentContent(
                        using: proxy,
                        animated: !store.messages.isEmpty
                    )
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            DSChatTypeBox(
                text: $store.draft,
                placeholder: inputPlaceholder,
                onSend: { store.send(.sendButtonTapped) }
            )
            .disabled(store.isStreaming || store.quota.remaining == 0)
            .opacity(store.isStreaming || store.quota.remaining == 0 ? 0.6 : 1)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .background(DesignSystemAsset.Colors.white.swiftUIColor)
        }
    }

    private var entryContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            TodakChatAvatar(category: nil)

            Text(store.entry.greeting)
                .dsBody1Medium
                .foregroundStyle(DesignSystemAsset.Colors.black.swiftUIColor)
                .padding(.top, 20)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(store.entry.suggestions) { suggestion in
                    Button {
                        store.send(.suggestionTapped(suggestion))
                    } label: {
                        DSTodakExampleQuestion(suggestion.displayText)
                    }
                    .buttonStyle(.plain)
                    .disabled(store.isStreaming || store.quota.remaining == 0)
                    .accessibilityLabel(suggestion.displayText)
                }
            }
            .padding(.top, 20)
        }
    }

    @ViewBuilder
    private func messageView(_ message: TodakMessage) -> some View {
        switch message.role {
        case .user:
            DSUserChat(message.content)
                .frame(maxWidth: .infinity, alignment: .trailing)

        case .assistant, .unknown:
            VStack(alignment: .leading, spacing: 12) {
                if message.content.isEmpty && message.status == .streaming {
                    typingIndicator
                } else {
                    Text(message.content)
                        .dsBody2Regular
                        .foregroundStyle(DesignSystemAsset.Colors.black.swiftUIColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let action = message.action {
                    DSTodakExampleQuestion("📅 \(action.label)")
                        .accessibilityLabel(action.label)
                }
            }
        }
    }

    private var typingIndicator: some View {
        TodakTypingIndicator()
    }

    private var inputPlaceholder: String {
        store.quota.remaining == 0 ? "오늘 무료 채팅을 모두 사용했어요" : "토닥이에게 운세 물어보기"
    }

    private func scrollToCurrentContent(
        using proxy: ScrollViewProxy,
        animated: Bool
    ) {
        let destination: (id: AnyHashable, alignment: UnitPoint)

        if let messageID = store.messages.last?.id {
            destination = (AnyHashable(messageID), .bottom)
        } else {
            destination = (AnyHashable(ScrollAnchor.entry), .top)
        }

        if animated {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(destination.id, anchor: destination.alignment)
            }
        } else {
            proxy.scrollTo(destination.id, anchor: destination.alignment)
        }
    }
}

private struct TodakTypingIndicator: View {
    private let dotSize: CGFloat = 4
    private let dotSpacing: CGFloat = 3

    var body: some View {
        HStack(spacing: 9) {
            HStack(spacing: dotSpacing) {
                ForEach(0..<3, id: \.self) { index in
                    TodakTypingDot(
                        color: index == 2
                            ? DesignSystemAsset.Colors.primary300.swiftUIColor
                            : DesignSystemAsset.Colors.primary700.swiftUIColor,
                        delay: Double(index) * 0.12,
                        size: dotSize
                    )
                }
            }
            .frame(width: 18, height: 7, alignment: .bottom)

            Text("생각 중")
                .dsBody2Regular
                .foregroundStyle(DesignSystemAsset.Colors.primary700.swiftUIColor)
        }
    }
}

private struct TodakTypingDot: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isRaised = false

    let color: Color
    let delay: TimeInterval
    let size: CGFloat

    private let travel: CGFloat = 3

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .offset(y: isRaised ? -travel : 0)
            .accessibilityHidden(true)
            .onAppear(perform: updateAnimation)
            .onChange(of: reduceMotion) { _, _ in
                updateAnimation()
            }
    }

    private func updateAnimation() {
        guard !reduceMotion else {
            withAnimation(.none) {
                isRaised = false
            }
            return
        }

        withAnimation(.none) {
            isRaised = false
        }
        withAnimation(
            .easeInOut(duration: 0.3)
                .repeatForever(autoreverses: true)
                .delay(delay)
        ) {
            isRaised = true
        }
    }
}
