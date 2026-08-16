import EventKit
import EventKitUI
import SwiftUI

struct CalendarEventEditor: UIViewControllerRepresentable {
    let draft: CalendarEventDraft
    let completed: (CalendarEventEditorResult) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(completed: completed)
    }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let eventStore = context.coordinator.eventStore
        let event = EKEvent(eventStore: eventStore)
        let calendar = calendar(for: draft)

        event.title = draft.title
        event.startDate = calendar.startOfDay(for: draft.date)
        event.endDate = calendar.date(byAdding: .day, value: 1, to: event.startDate)
        event.isAllDay = draft.isAllDay
        event.notes = draft.notes

        let editor = EKEventEditViewController()
        editor.eventStore = eventStore
        editor.event = event
        editor.editViewDelegate = context.coordinator
        return editor
    }

    func updateUIViewController(_: EKEventEditViewController, context _: Context) {}

    private func calendar(for draft: CalendarEventDraft) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: draft.timeZoneIdentifier) ?? .current
        return calendar
    }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        let eventStore = EKEventStore()
        private let completed: (CalendarEventEditorResult) -> Void

        init(completed: @escaping (CalendarEventEditorResult) -> Void) {
            self.completed = completed
        }

        func eventEditViewController(
            _: EKEventEditViewController,
            didCompleteWith action: EKEventEditViewAction
        ) {
            switch action {
            case .saved:
                completed(.saved)
            case .canceled, .deleted:
                completed(.cancelled)
            @unknown default:
                completed(.cancelled)
            }
        }
    }
}
