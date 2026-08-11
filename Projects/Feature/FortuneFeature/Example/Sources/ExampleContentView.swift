import ComposableArchitecture
import FortuneFeature
import SwiftUI

struct ExampleContentView: View {
    private let store = Store(
        initialState: FortuneFeature.State(
            viewState: .loaded(.example)
        )
    ) {
        FortuneFeature()
    }

    var body: some View {
        FortuneView(store: store)
    }
}
