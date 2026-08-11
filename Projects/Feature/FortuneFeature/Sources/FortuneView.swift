import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct FortuneView: View {
    private let store: StoreOf<FortuneFeature>

    public init(store: StoreOf<FortuneFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            rootBackgroundColor.ignoresSafeArea()

            switch store.viewState {
            case .loading:
                FortuneLoadingView()

            case let .loaded(content):
                FortuneHomeView(
                    content: content,
                    action: { store.send(.view($0)) },
                    onRefresh: {
                        await store.send(.view(.refresh)).finish()
                    }
                )

            case let .failed(message):
                FortuneFailureView(
                    message: message,
                    retryAction: {
                        store.send(.view(.retryButtonTapped))
                    }
                )
            }
        }
        .task {
            await store.send(.view(.task)).finish()
        }
        .onDisappear {
            store.send(.view(.requestCancelled))
        }
    }

    private var rootBackgroundColor: Color {
        switch store.viewState {
        case .loaded:
            return Color.ds.white
        case .loading, .failed:
            return Color.ds.black
        }
    }
}
