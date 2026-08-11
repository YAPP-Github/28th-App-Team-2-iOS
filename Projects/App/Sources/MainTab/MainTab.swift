import ComposableArchitecture
import DesignSystem
import MyPageFeature
import SwiftUI

@Reducer
struct MainTabFeature {
    @ObservableState
    struct State: Equatable {
        var selectedItem: DSBottomNavigationItem = .fortune
        var myPage = MyPageFeature.State()
    }

    enum Action: Equatable {
        case selectedItemChanged(DSBottomNavigationItem)
        case myPage(MyPageFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.myPage, action: \.myPage) {
            MyPageFeature()
        }

        Reduce { state, action in
            switch action {
            case let .selectedItemChanged(item):
                state.selectedItem = item
                return .none
            case .myPage:
                return .none
            }
        }
    }
}

struct MainTabView: View {
    @Bindable var store: StoreOf<MainTabFeature>

    var body: some View {
        VStack(spacing: 0) {
            selectedContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if store.myPage.edit == nil, store.myPage.sajuDetail == nil {
                DSBottomNavigation(
                    selectedItem: $store.selectedItem.sending(\.selectedItemChanged)
                )
            }
        }
        .background {
            Color.ds.white
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch store.selectedItem {
        case .fortune:
            ContentUnavailableView("운세", systemImage: "sparkles")
        case .todak:
            ContentUnavailableView("토닥이", systemImage: "message")
        case .luckyAction:
            ContentUnavailableView("행운 액션", systemImage: "heart")
        case .myPage:
            MyPageView(store: store.scope(state: \.myPage, action: \.myPage))
        }
    }
}
