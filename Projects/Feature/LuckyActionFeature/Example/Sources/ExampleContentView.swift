import ComposableArchitecture
import DesignSystem
import LuckyActionFeature
import LuckyActionFeatureTesting
import SwiftUI

struct ExampleContentView: View {
    @Bindable private var store: StoreOf<LuckyActionFeature>

    init() {
        let repository = LuckyActionMock()
        store = Store(initialState: LuckyActionFeature.State()) {
            LuckyActionFeature()
        } withDependencies: {
            $0.luckyActionClient = .mock(repository: repository)
        }
    }

    var body: some View {
        ZStack {
            LuckyActionView(store: store)
                .disabled(store.completion != nil)
                .accessibilityHidden(store.completion != nil)

            if let completion = store.completion {
                ZStack {
                    Color.ds.opacity50
                        .ignoresSafeArea()
                        .accessibilityHidden(true)

                    LuckyActionCompletionContent(
                        completion: completion,
                        dismiss: { store.send(.view(.completionDismissButtonTapped)) }
                    )
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.completion != nil)
    }
}
