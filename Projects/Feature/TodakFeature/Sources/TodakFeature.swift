import ComposableArchitecture
import Foundation

// swiftlint:disable type_body_length
@Reducer
public struct TodakFeature {
    public init() {}

    /// 채팅 화면이 표시될 때 복원할 콘텐츠 위치다.
    /// 새 채팅은 엔트리의 시작점, 기존 대화는 마지막 메시지를 가리킨다.
    public enum ChatScrollTarget: Equatable, Sendable {
        case entry
        case message(UUID)
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        public enum Screen: Equatable, Sendable {
            case chat
            case history
        }

        public var screen: Screen
        public var showsSplash: Bool
        public var didPresentSplash: Bool
        public var didCompleteSplashDelay: Bool
        public var isLoadingEntry: Bool
        public var entry: TodakEntry
        public var quota: TodakQuota
        public var conversationID: UUID?
        public var messages: [TodakMessage]
        public var chatScrollTarget: ChatScrollTarget
        /// 동일한 메시지가 스트리밍으로 갱신될 때도 스크롤 요청을 전달하기 위한 식별자다.
        public var chatScrollRequestID: Int
        public var draft: String
        public var isStreaming: Bool
        public var assistantMessageID: UUID?
        public var activeCategory: TodakCategory?
        public var guideCategory: TodakCategory?
        public var conversations: [TodakConversationSummary]
        public var isLoadingHistory: Bool
        public var pendingDeletionID: UUID?
        public var toastMessage: String?
        /// 딥링크로 열려는 대화 로드가 진행 중임을 나타낸다. 실패 시 새 채팅으로 리셋한다.
        public var isPendingDeepLinkConversation: Bool

        public init(
            screen: Screen = .chat,
            showsSplash: Bool = true,
            didPresentSplash: Bool = false,
            didCompleteSplashDelay: Bool = false,
            isLoadingEntry: Bool = false,
            entry: TodakEntry = .initial,
            quota: TodakQuota = TodakEntry.initial.quota,
            conversationID: UUID? = nil,
            messages: [TodakMessage] = [],
            chatScrollTarget: ChatScrollTarget = .entry,
            chatScrollRequestID: Int = 0,
            draft: String = "",
            isStreaming: Bool = false,
            assistantMessageID: UUID? = nil,
            activeCategory: TodakCategory? = nil,
            guideCategory: TodakCategory? = nil,
            conversations: [TodakConversationSummary] = [],
            isLoadingHistory: Bool = false,
            pendingDeletionID: UUID? = nil,
            toastMessage: String? = nil,
            isPendingDeepLinkConversation: Bool = false
        ) {
            self.screen = screen
            self.showsSplash = showsSplash
            self.didPresentSplash = didPresentSplash
            self.didCompleteSplashDelay = didCompleteSplashDelay
            self.isLoadingEntry = isLoadingEntry
            self.entry = entry
            self.quota = quota
            self.conversationID = conversationID
            self.messages = messages
            self.chatScrollTarget = chatScrollTarget
            self.chatScrollRequestID = chatScrollRequestID
            self.draft = draft
            self.isStreaming = isStreaming
            self.assistantMessageID = assistantMessageID
            self.activeCategory = activeCategory
            self.guideCategory = guideCategory
            self.conversations = conversations
            self.isLoadingHistory = isLoadingHistory
            self.pendingDeletionID = pendingDeletionID
            self.toastMessage = toastMessage
            self.isPendingDeepLinkConversation = isPendingDeepLinkConversation
        }

        public var canSend: Bool {
            !isStreaming && quota.remaining > 0 && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    public enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case task
        case splashElapsed
        case entryResponse(Result<TodakEntry, TodakClientError>)
        case closeButtonTapped
        case newChatButtonTapped
        case historyButtonTapped
        case historyBackButtonTapped
        case suggestionTapped(TodakSuggestion)
        case sendButtonTapped
        case streamEvent(TodakStreamEvent)
        case streamFinished
        case streamFailed(TodakClientError)
        case guideDismissed
        case historyResponse(Result<[TodakConversationSummary], TodakClientError>)
        case conversationTapped(UUID)
        case openConversation(UUID)
        case conversationResponse(Result<TodakConversation, TodakClientError>)
        case deleteButtonTapped(UUID)
        case deleteCancelled
        case deleteConfirmed
        case deleteResponse(UUID, Result<Bool, TodakClientError>)
        case toastDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case closeRequested
        }
    }

    enum CancelID {
        case splash
        case entry
        case guide
        case stream
        case history
        case conversation
        case deletion
        case toast
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.date.now) var now
    @Dependency(\.todakClient) var client
    @Dependency(\.uuid) var uuid

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.draft):
                if state.draft.count > 500 {
                    state.draft = String(state.draft.prefix(500))
                }
                return .none

            case .binding:
                return .none

            case .task:
                guard !state.didPresentSplash else { return .none }
                state.didPresentSplash = true
                state.isLoadingEntry = true
                return .merge(splashDelayEffect(), fetchEntryEffect())

            case .splashElapsed:
                state.didCompleteSplashDelay = true
                state.showsSplash = state.isLoadingEntry
                return .none

            case let .entryResponse(.success(entry)):
                state.entry = entry
                state.quota = entry.quota
                state.isLoadingEntry = false
                if state.didCompleteSplashDelay {
                    state.showsSplash = false
                }
                return .none

            case .entryResponse(.failure):
                state.isLoadingEntry = false
                if state.didCompleteSplashDelay {
                    state.showsSplash = false
                }
                return .none

            case .closeButtonTapped:
                return .send(.delegate(.closeRequested))

            case .newChatButtonTapped:
                guard !state.isStreaming else { return .none }
                resetConversation(state: &state)
                state.screen = .chat
                return .none

            case .historyButtonTapped:
                guard !state.isStreaming else { return .none }
                state.screen = .history
                state.isLoadingHistory = true
                return fetchHistoryEffect()

            case .historyBackButtonTapped:
                state.screen = .chat
                return .cancel(id: CancelID.history)

            case let .suggestionTapped(suggestion):
                guard !state.isStreaming, state.quota.remaining > 0 else { return .none }
                state.activeCategory = suggestion.category ?? .other
                state.guideCategory = suggestion.category
                return showInitialReply(state: &state, for: suggestion)

            case .sendButtonTapped:
                guard state.canSend else { return .none }
                return sendMessageEffect(state: &state, content: state.draft)

            case let .streamEvent(event):
                return handleStreamEvent(event, state: &state)

            case .streamFinished:
                guard state.isStreaming else { return .none }
                TodakSSEDebugLogger.fallbackShown()
                state.isStreaming = false
                markAssistantMessageFailed(state: &state)
                state.toastMessage = "답변을 끝까지 받지 못했어요. 다시 시도해 주세요."
                return toastDismissEffect()

            case let .streamFailed(error):
                state.isStreaming = false
                markAssistantMessageFailed(state: &state)
                state.toastMessage = message(for: error)
                return toastDismissEffect()

            case .guideDismissed:
                state.guideCategory = nil
                return .cancel(id: CancelID.guide)

            case let .historyResponse(.success(conversations)):
                state.isLoadingHistory = false
                state.conversations = conversations.sorted { lhs, rhs in
                    (lhs.lastMessageAt ?? .distantPast) > (rhs.lastMessageAt ?? .distantPast)
                }
                return .none

            case let .historyResponse(.failure(error)):
                state.isLoadingHistory = false
                state.toastMessage = message(for: error)
                return toastDismissEffect()

            case let .conversationTapped(conversationID):
                return fetchConversationEffect(conversationID: conversationID)

            case let .openConversation(conversationID):
                state.screen = .chat
                state.isPendingDeepLinkConversation = true
                let shouldPresentSplash = !state.didPresentSplash
                state.showsSplash = shouldPresentSplash
                state.didPresentSplash = true
                state.didCompleteSplashDelay = !shouldPresentSplash
                state.isLoadingHistory = false
                state.isStreaming = false
                state.isLoadingEntry = true
                let splashEffect = shouldPresentSplash ? splashDelayEffect() : .none
                return .merge(
                    .cancel(id: CancelID.stream),
                    fetchConversationEffect(conversationID: conversationID),
                    fetchEntryEffect(),
                    splashEffect
                )

            case let .conversationResponse(.success(conversation)):
                state.screen = .chat
                state.isPendingDeepLinkConversation = false
                state.conversationID = conversation.id
                state.messages = conversation.messages
                requestScrollToLatestContent(state: &state)
                state.conversations = state.conversations.map { summary in
                    guard summary.id == conversation.id else { return summary }
                    return TodakConversationSummary(
                        id: summary.id,
                        title: summary.title,
                        lastMessageAt: summary.lastMessageAt,
                        unread: false
                    )
                }
                return .none

            case let .conversationResponse(.failure(error)):
                let wasDeepLink = state.isPendingDeepLinkConversation
                state.isPendingDeepLinkConversation = false
                if wasDeepLink {
                    // 딥링크로 진입했지만 해당 채팅방이 없으면 새 채팅으로 이동 + 토스트 표시
                    resetConversation(state: &state)
                    state.screen = .chat
                    state.toastMessage = deepLinkConversationErrorMessage(for: error)
                } else {
                    state.toastMessage = message(for: error)
                }
                return toastDismissEffect()

            case let .deleteButtonTapped(conversationID):
                state.pendingDeletionID = conversationID
                return .none

            case .deleteCancelled:
                state.pendingDeletionID = nil
                return .none

            case .deleteConfirmed:
                guard let conversationID = state.pendingDeletionID else { return .none }
                state.pendingDeletionID = nil
                return deleteConversationEffect(conversationID: conversationID)

            case let .deleteResponse(conversationID, .success):
                state.conversations.removeAll { $0.id == conversationID }
                if state.conversationID == conversationID { resetConversation(state: &state) }
                state.toastMessage = "대화가 삭제되었어요."
                return toastDismissEffect()

            case let .deleteResponse(_, .failure(error)):
                state.toastMessage = message(for: error)
                return toastDismissEffect()

            case .toastDismissed:
                state.toastMessage = nil
                return .cancel(id: CancelID.toast)

            case .delegate:
                return .none
            }
        }
    }

}
// swiftlint:enable type_body_length
