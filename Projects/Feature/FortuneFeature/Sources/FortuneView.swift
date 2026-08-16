import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct FortuneView: View {
    @Bindable private var store: StoreOf<FortuneFeature>

    public init(store: StoreOf<FortuneFeature>) {
        self.store = store
    }

    public var body: some View {
        FortuneNavigationView(
            store: store,
            isLuckyActionPresented: .constant(false),
            luckyActionDestination: AnyView(EmptyView()),
            isNotificationPresented: .constant(false),
            notificationDestination: AnyView(EmptyView())
        )
    }
}

public struct FortuneNavigationView: View {
    @Bindable private var store: StoreOf<FortuneFeature>
    @Binding private var isLuckyActionPresented: Bool
    private let luckyActionDestination: AnyView
    @Binding private var isNotificationPresented: Bool
    private let notificationDestination: AnyView

    public init(
        store: StoreOf<FortuneFeature>,
        isLuckyActionPresented: Binding<Bool>,
        luckyActionDestination: AnyView,
        isNotificationPresented: Binding<Bool>,
        notificationDestination: AnyView
    ) {
        self.store = store
        self._isLuckyActionPresented = isLuckyActionPresented
        self.luckyActionDestination = luckyActionDestination
        self._isNotificationPresented = isNotificationPresented
        self.notificationDestination = notificationDestination
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack {
                rootBackgroundColor.ignoresSafeArea()

                switch store.viewState {
                case .loading:
                    FortuneLoadingView()

                case let .loaded(content):
                    FortuneHomeView(
                        content: content,
                        unreadNotificationCount: store.unreadNotificationCount,
                        action: { store.send(.view($0)) }
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
            .navigationDestination(isPresented: $isNotificationPresented) {
                notificationDestination
            }
        } destination: { pathStore in
            switch pathStore.case {
            case let .report(store):
                FortuneReportView(store: store) {
                    popLastDestination()
                }
                .navigationDestination(isPresented: $isLuckyActionPresented) {
                    luckyActionDestination
                }

            case let .compatibility(store):
                CompatibilityView(store: store) {
                    popLastDestination()
                }

            case let .dayFortune(store):
                DayFortuneView(store: store) {
                    popLastDestination()
                }

            case let .yearFortune(store):
                YearFortuneView(store: store) {
                    popLastDestination()
                }
            }
        }
        .task {
            await store.send(.view(.task)).finish()
        }
        .onDisappear {
            store.send(.view(.requestCancelled))
        }
        .sheet(
            item: $store.scope(state: \.categoryDetail, action: \.categoryDetail)
        ) { categoryStore in
            FortuneCategoryDetailView(store: categoryStore)
                .presentationDetents([.fraction(0.8)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(28)
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

    private func popLastDestination() {
        guard let destinationID = store.path.ids.last else { return }
        store.send(.path(.popFrom(id: destinationID)))
    }
}
