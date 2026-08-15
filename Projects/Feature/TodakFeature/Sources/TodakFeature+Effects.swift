import ComposableArchitecture
import Foundation

extension TodakFeature {
    func splashDelayEffect() -> Effect<Action> {
        .run { send in
            try await clock.sleep(for: .milliseconds(1_500))
            await send(.splashElapsed)
        }
        .cancellable(id: CancelID.splash, cancelInFlight: true)
    }

    func sendMessageEffect(state: inout State, content: String) -> Effect<Action> {
        let content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return .none }

        state.draft = ""
        state.isStreaming = true
        state.assistantMessageID = nil
        state.messages.append(
            TodakMessage(
                id: uuid(),
                role: .user,
                content: content,
                status: .completed,
                createdAt: now
            )
        )
        let conversationID = state.conversationID

        return .run { send in
            do {
                for try await event in client.sendMessage(conversationID, content) {
                    await send(.streamEvent(event))
                }
                await send(.streamFinished)
            } catch is CancellationError {
                return
            } catch let error as TodakClientError {
                await send(.streamFailed(error))
            } catch {
                await send(.streamFailed(.transport))
            }
        }
        .cancellable(id: CancelID.stream, cancelInFlight: true)
    }

    func showInitialReply(state: inout State, for suggestion: TodakSuggestion) -> Effect<Action> {
        let category = suggestion.category ?? .other

        state.messages = [
            TodakMessage(
                id: uuid(),
                role: .user,
                content: suggestion.seedPrompt,
                status: .completed,
                createdAt: now
            ),
            TodakMessage(
                id: uuid(),
                role: .assistant,
                content: TodakInitialReply.content(for: category),
                status: .completed,
                createdAt: now
            )
        ]

        guard state.guideCategory != nil else { return .none }
        return guideDismissEffect()
    }

    func guideDismissEffect() -> Effect<Action> {
        .run { send in
            try await clock.sleep(for: .seconds(2))
            await send(.guideDismissed)
        }
        .cancellable(id: CancelID.guide, cancelInFlight: true)
    }

    func handleStreamEvent(_ event: TodakStreamEvent, state: inout State) -> Effect<Action> {
        switch event {
        case let .start(conversationID, _, assistantMessageID, quota):
            state.conversationID = conversationID
            state.quota = quota
            state.assistantMessageID = assistantMessageID
            state.messages.append(
                TodakMessage(
                    id: assistantMessageID,
                    role: .assistant,
                    content: "",
                    status: .streaming,
                    createdAt: now
                )
            )
            return .none

        case let .delta(text):
            guard let assistantMessageID = state.assistantMessageID,
                  let index = state.messages.firstIndex(where: { $0.id == assistantMessageID }) else {
                return .none
            }
            state.messages[index].content += text
            return .none

        case let .action(action):
            state.activeCategory = action.category
            guard let assistantMessageID = state.assistantMessageID,
                  let index = state.messages.firstIndex(where: { $0.id == assistantMessageID }) else {
                return .none
            }
            state.messages[index].action = action
            return .none

        case let .done(assistantMessageID):
            if let index = state.messages.firstIndex(where: { $0.id == assistantMessageID }) {
                state.messages[index].status = .completed
            }
            state.isStreaming = false
            state.assistantMessageID = nil
            return .none

        case let .error(code, message):
            state.isStreaming = false
            if code == "CHAT-429" {
                state.quota = TodakQuota(used: state.quota.limit, limit: state.quota.limit)
            }
            markAssistantMessageFailed(state: &state)
            state.toastMessage = message
            return toastDismissEffect()
        }
    }

    func fetchHistoryEffect() -> Effect<Action> {
        .run { send in
            do {
                await send(.historyResponse(.success(try await client.fetchConversations())))
            } catch is CancellationError {
                return
            } catch let error as TodakClientError {
                await send(.historyResponse(.failure(error)))
            } catch {
                await send(.historyResponse(.failure(.transport)))
            }
        }
        .cancellable(id: CancelID.history, cancelInFlight: true)
    }

    func fetchConversationEffect(conversationID: UUID) -> Effect<Action> {
        .run { send in
            do {
                let conversation = try await client.fetchConversation(conversationID)
                await send(.conversationResponse(.success(conversation)))
            } catch is CancellationError {
                return
            } catch let error as TodakClientError {
                await send(.conversationResponse(.failure(error)))
            } catch {
                await send(.conversationResponse(.failure(.transport)))
            }
        }
        .cancellable(id: CancelID.conversation, cancelInFlight: true)
    }

    func deleteConversationEffect(conversationID: UUID) -> Effect<Action> {
        .run { send in
            do {
                try await client.deleteConversation(conversationID)
                await send(.deleteResponse(conversationID, .success(true)))
            } catch is CancellationError {
                return
            } catch let error as TodakClientError {
                await send(.deleteResponse(conversationID, .failure(error)))
            } catch {
                await send(.deleteResponse(conversationID, .failure(.transport)))
            }
        }
        .cancellable(id: CancelID.deletion, cancelInFlight: true)
    }

    func toastDismissEffect() -> Effect<Action> {
        .run { send in
            try await clock.sleep(for: .seconds(3))
            await send(.toastDismissed)
        }
        .cancellable(id: CancelID.toast, cancelInFlight: true)
    }

    func resetConversation(state: inout State) {
        state.conversationID = nil
        state.messages = []
        state.draft = ""
        state.activeCategory = nil
        state.guideCategory = nil
        state.assistantMessageID = nil
    }

    func markAssistantMessageFailed(state: inout State) {
        guard let assistantMessageID = state.assistantMessageID,
              let index = state.messages.firstIndex(where: { $0.id == assistantMessageID }) else { return }
        state.messages[index].status = .failed
        state.assistantMessageID = nil
    }

    func message(for error: TodakClientError) -> String {
        switch error {
        case .notConfigured:
            "토닥이 서비스를 사용할 수 없어요."
        case .server, .httpStatus:
            "요청을 처리하지 못했어요. 잠시 후 다시 시도해 주세요."
        case .invalidResponse, .unsupportedCategory:
            "토닥이 응답을 읽는 중 오류가 발생했어요."
        case .transport:
            "네트워크 상태를 확인해 주세요."
        }
    }
}
