import ComposableArchitecture
import Foundation
import Testing
@testable import TodakFeature

@Suite
@MainActor
struct TodakFeatureTests {
    @Test("직접 입력한 질문의 SSE 이벤트를 순서대로 반영한다")
    func directMessageStreamsAssistantMessage() async {
        let localMessageID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let conversationID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let userMessageID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        let assistantMessageID = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let clock = TestClock()
        let client = makeClient(
            sendMessage: { _, _ in
                AsyncThrowingStream { continuation in
                    continuation.yield(
                        .start(
                            conversationID: conversationID,
                            userMessageID: userMessageID,
                            assistantMessageID: assistantMessageID,
                            quota: .init(used: 1, limit: 3)
                        )
                    )
                    continuation.yield(.delta("좋은 흐름이에요."))
                    continuation.yield(.done(assistantMessageID: assistantMessageID))
                    continuation.finish()
                }
            }
        )
        let store = TestStore(
            initialState: TodakFeature.State(draft: "이직할까 말까?")
        ) {
            TodakFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.date.now = now
            $0.todakClient = client
            $0.uuid = .incrementing
        }

        await store.send(.sendButtonTapped) {
            $0.draft = ""
            $0.isStreaming = true
            $0.messages = [
                TodakMessage(
                    id: localMessageID,
                    role: .user,
                    content: "이직할까 말까?",
                    status: .completed,
                    createdAt: now
                )
            ]
        }
        await store.receive(
            .streamEvent(
                .start(
                    conversationID: conversationID,
                    userMessageID: userMessageID,
                    assistantMessageID: assistantMessageID,
                    quota: .init(used: 1, limit: 3)
                )
            )
        ) {
            $0.conversationID = conversationID
            $0.quota = .init(used: 1, limit: 3)
            $0.assistantMessageID = assistantMessageID
            $0.messages.append(
                TodakMessage(
                    id: assistantMessageID,
                    role: .assistant,
                    content: "",
                    status: .streaming,
                    createdAt: now
                )
            )
        }
        await store.receive(.streamEvent(.delta("좋은 흐름이에요."))) {
            $0.messages[1].content = "좋은 흐름이에요."
        }
        await store.receive(.streamEvent(.done(assistantMessageID: assistantMessageID))) {
            $0.messages[1].status = .completed
            $0.isStreaming = false
            $0.assistantMessageID = nil
        }
        await store.receive(.streamFinished)
    }

    @Test("최초 진입은 네트워크 없이 클라이언트 템플릿을 표시한다")
    func initialEntryUsesClientTemplate() async {
        let clock = TestClock()
        let store = TestStore(initialState: TodakFeature.State()) {
            TodakFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        #expect(store.state.entry == .initial)
        #expect(store.state.entry.suggestions.count == 6)
        #expect(store.state.quota == .init(used: 0, limit: 3))
        #expect(store.state.showsSplash)

        await store.send(.task) {
            $0.didPresentSplash = true
        }
        await clock.advance(by: .milliseconds(1_500))
        await store.receive(.splashElapsed) {
            $0.showsSplash = false
        }
    }

    @Test("추천 질문은 네트워크 없이 고정 답변과 해당 카테고리 팝업을 표시한다")
    func categorySuggestionPresentsLocalReplyAndMatchingGuide() async {
        let userMessageID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let assistantMessageID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let clock = TestClock()
        let suggestion = TodakEntry.initial.suggestions[0]
        let store = TestStore(initialState: TodakFeature.State()) {
            TodakFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.date.now = now
            $0.todakClient = .unavailable
            $0.uuid = .incrementing
        }

        await store.send(.suggestionTapped(suggestion)) {
            $0.activeCategory = .relationship
            $0.guideCategory = .relationship
            $0.messages = [
                TodakMessage(
                    id: userMessageID,
                    role: .user,
                    content: "요즘 관계운이 궁금해.",
                    status: .completed,
                    createdAt: now
                ),
                TodakMessage(
                    id: assistantMessageID,
                    role: .assistant,
                    content: TodakInitialReply.content(for: .relationship),
                    status: .completed,
                    createdAt: now
                )
            ]
        }
        await store.send(.guideDismissed) {
            $0.guideCategory = nil
        }
    }
}

@Suite
@MainActor
struct TodakFeatureRegressionTests {
    @Test("기획 확정 전까지 모든 추천 질문은 성취운 고정 답변을 사용한다")
    func initialRepliesUseAchievementContentForEveryCategory() {
        let achievementContent = TodakInitialReply.content(for: .achievement)

        for category in [
            TodakCategory.relationship,
            .love,
            .achievement,
            .money,
            .health,
            .other
        ] {
            #expect(TodakInitialReply.content(for: category) == achievementContent)
        }
    }

    @Test("SSE 오류는 토닥이 답변을 실패 상태와 서버 안내 문구로 전환한다")
    func streamErrorFailsAssistantMessage() async {
        let assistantMessageID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let clock = TestClock()
        let store = TestStore(
            initialState: TodakFeature.State(
                messages: [
                    TodakMessage(
                        id: assistantMessageID,
                        role: .assistant,
                        content: "답변을 만들고 있어요.",
                        status: .streaming
                    )
                ],
                isStreaming: true,
                assistantMessageID: assistantMessageID
            )
        ) {
            TodakFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(
            TodakFeature.Action.streamEvent(
                TodakStreamEvent.error(code: "CHAT-500", message: "토닥이 답변 생성에 실패했습니다.")
            )
        ) {
            $0.isStreaming = false
            $0.assistantMessageID = nil
            $0.messages[0].status = .failed
            $0.toastMessage = "토닥이 답변 생성에 실패했습니다."
        }
        await store.send(TodakFeature.Action.toastDismissed) {
            $0.toastMessage = nil
        }
    }

    @Test("quota 오류는 남은 무료 채팅 횟수를 즉시 0으로 갱신한다")
    func quotaErrorExhaustsRemainingFreeChatCount() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: TodakFeature.State(
                quota: .init(used: 2, limit: 3),
                isStreaming: true
            )
        ) {
            TodakFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(
            .streamEvent(
                .error(code: "CHAT-429", message: "오늘 무료 채팅 횟수를 모두 사용했습니다.")
            )
        ) {
            $0.isStreaming = false
            $0.quota = .init(used: 3, limit: 3)
            $0.toastMessage = "오늘 무료 채팅 횟수를 모두 사용했습니다."
        }
        await store.send(.toastDismissed) {
            $0.toastMessage = nil
        }
    }

    @Test("대화 삭제 성공 시 목록과 현재 대화를 즉시 제거하고 안내 문구를 표시한다")
    func deletingConversationRemovesItImmediately() async {
        let conversationID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
        let summary = TodakConversationSummary(
            id: conversationID,
            title: "삭제할 대화",
            lastMessageAt: nil,
            unread: true
        )
        let clock = TestClock()
        let client = makeClient(deleteConversation: { deletedConversationID in
            #expect(deletedConversationID == conversationID)
        })
        let store = TestStore(
            initialState: TodakFeature.State(
                conversationID: conversationID,
                messages: [
                    TodakMessage(id: UUID(), role: .user, content: "질문", status: .completed)
                ],
                conversations: [summary]
            )
        ) {
            TodakFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.todakClient = client
        }

        await store.send(.deleteButtonTapped(conversationID)) {
            $0.pendingDeletionID = conversationID
        }
        await store.send(.deleteConfirmed) {
            $0.pendingDeletionID = nil
        }
        await store.receive(.deleteResponse(conversationID, .success(true))) {
            $0.conversations = []
            $0.conversationID = nil
            $0.messages = []
            $0.toastMessage = "대화가 삭제되었어요."
        }
        await store.send(.toastDismissed) {
            $0.toastMessage = nil
        }
    }

    @Test("대화 삭제를 취소하면 목록을 유지한다")
    func cancellingConversationDeletionKeepsConversation() async {
        let conversationID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
        let summary = TodakConversationSummary(
            id: conversationID,
            title: "유지할 대화",
            lastMessageAt: nil,
            unread: false
        )
        let store = TestStore(
            initialState: TodakFeature.State(
                conversations: [summary],
                pendingDeletionID: conversationID
            )
        ) {
            TodakFeature()
        }

        await store.send(.deleteCancelled) {
            $0.pendingDeletionID = nil
        }
        #expect(store.state.conversations == [summary])
    }

    @Test("대화 히스토리는 최근 메시지 순으로 정렬한다")
    func historyIsSortedByMostRecentMessage() async {
        let olderID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
        let newerID = UUID(uuidString: "00000000-0000-0000-0000-000000000011")!
        let undatedID = UUID(uuidString: "00000000-0000-0000-0000-000000000012")!
        let older = TodakConversationSummary(
            id: olderID,
            title: "어제 질문",
            lastMessageAt: Date(timeIntervalSince1970: 1_700_000_000),
            unread: false
        )
        let newer = TodakConversationSummary(
            id: newerID,
            title: "오늘 질문",
            lastMessageAt: Date(timeIntervalSince1970: 1_800_000_000),
            unread: true
        )
        let undated = TodakConversationSummary(
            id: undatedID,
            title: "시간 없는 질문",
            lastMessageAt: nil,
            unread: false
        )
        let store = TestStore(initialState: TodakFeature.State(isLoadingHistory: true)) {
            TodakFeature()
        }

        await store.send(.historyResponse(.success([older, undated, newer]))) {
            $0.isLoadingHistory = false
            $0.conversations = [newer, older, undated]
        }
    }
}

private func makeClient(
    deleteConversation: @escaping @Sendable (UUID) async throws -> Void = { _ in },
    sendMessage: @escaping @Sendable (UUID?, String) -> AsyncThrowingStream<TodakStreamEvent, Error> = { _, _ in
        AsyncThrowingStream { $0.finish() }
    }
) -> TodakClient {
    TodakClient(
        fetchConversations: { [] },
        fetchConversation: { conversationID in
            TodakConversation(id: conversationID, title: "", messages: [])
        },
        deleteConversation: deleteConversation,
        sendMessage: sendMessage
    )
}
