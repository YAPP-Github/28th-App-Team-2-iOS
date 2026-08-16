import ComposableArchitecture
import SwiftUI
import TodakFeature

struct ExampleContentView: View {
    private let store = Store(
        initialState: TodakFeature.State(
            entry: TodakEntry(
                greeting: "오늘은 어떤게 궁금해?",
                suggestions: [
                    TodakSuggestion(
                        emoji: "💼",
                        label: "커리어 흐름이나, 목표에 대한 성과가 궁금해",
                        seedPrompt: "이직할까 말까?",
                        category: .achievement
                    )
                ],
                quota: TodakQuota(used: 0, limit: 3)
            ),
            quota: TodakQuota(used: 0, limit: 3)
        )
    ) {
        TodakFeature()
    }

    var body: some View {
        TodakView(store: store)
    }
}
