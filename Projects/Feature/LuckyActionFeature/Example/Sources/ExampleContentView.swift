import ComposableArchitecture
import LuckyActionFeature
import LuckyActionFeatureTesting
import SwiftUI

struct ExampleContentView: View {
    private let store: StoreOf<LuckyActionFeature>

    init() {
        let repository = LuckyActionMock()
        store = Store(initialState: LuckyActionFeature.State()) {
            LuckyActionFeature()
        } withDependencies: {
            $0.luckyActionClient = .mock(repository: repository)
        }
    }

    var body: some View {
        LuckyActionView(store: store)
    }
}
