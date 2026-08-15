import Foundation

#if DEBUG
import OSLog
#endif

enum TodakSSEDebugLogger {
    static func sendRequested(conversationID: UUID?, contentLength: Int) {
        log(
            "send requested conversation=\(conversationID?.uuidString.lowercased() ?? "new") "
                + "contentLength=\(contentLength)"
        )
    }

    static func rawEventReceived(name: String?, dataLength: Int?) {
        log("raw event name=\(name ?? "none") dataLength=\(dataLength.map(String.init) ?? "none")")
    }

    static func eventWithoutDataIgnored(name: String?) {
        log("raw event ignored because data is missing name=\(name ?? "none")")
    }

    static func decoded(_ event: TodakStreamEvent) {
        switch event {
        case let .start(conversationID, userMessageID, assistantMessageID, quota):
            log(
                "decoded start conversation=\(conversationID.uuidString.lowercased()) "
                    + "user=\(userMessageID.uuidString.lowercased()) "
                    + "assistant=\(assistantMessageID.uuidString.lowercased()) "
                    + "quota=\(quota.used)/\(quota.limit)"
            )
        case let .delta(text):
            log("decoded delta textLength=\(text.count)")
        case let .action(action):
            log("decoded action type=\(action.type) category=\(action.category.rawValue)")
        case let .done(assistantMessageID):
            log("decoded done assistant=\(assistantMessageID.uuidString.lowercased())")
        case let .error(code, message):
            log("decoded error code=\(code) messageLength=\(message.count)")
        }
    }

    static func streamEnded(receivedDone: Bool) {
        log("stream ended receivedDone=\(receivedDone)")
    }

    static func streamCancelled() {
        log("stream cancelled")
    }

    static func streamFailed(_ error: Error) {
        log("stream failed error=\(String(describing: error))")
    }

    static func reducerReceived(_ event: TodakStreamEvent) {
        switch event {
        case let .start(conversationID, _, assistantMessageID, quota):
            log(
                "reducer start conversation=\(conversationID.uuidString.lowercased()) "
                    + "assistant=\(assistantMessageID.uuidString.lowercased()) "
                    + "quota=\(quota.used)/\(quota.limit)"
            )
        case let .delta(text):
            log("reducer delta textLength=\(text.count)")
        case .action:
            log("reducer action")
        case let .done(assistantMessageID):
            log("reducer done assistant=\(assistantMessageID.uuidString.lowercased())")
        case let .error(code, message):
            log("reducer error code=\(code) messageLength=\(message.count)")
        }
    }

    static func fallbackShown() {
        log("reducer fallback shown because stream ended without done")
    }

    private static func log(_ message: String) {
        #if DEBUG
        logger.debug("\(message, privacy: .public)")
        #endif
    }

    #if DEBUG
    private static let logger = Logger(subsystem: "com.yapp.todakun", category: "TodakSSE")
    #endif
}
