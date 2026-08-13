import ComposableArchitecture
import DesignSystem
import FortuneFeature
import Foundation
import MyPageFeature
import SwiftUI
import TodakFeature

struct MainTabView: View {
    @Bindable var store: StoreOf<MainTabFeature>

    init(store: StoreOf<MainTabFeature>) {
        self.store = store
    }

    var body: some View {
        ZStack {
            switch store.selectedTab {
            case .fortune:
                FortuneView(
                    store: store.scope(state: \.fortune, action: \.fortune)
                )

            case .todak:
                TodakView(
                    store: store.scope(state: \.todak, action: \.todak)
                )

            case .luckyAction:
                UnavailableTabView(title: "행운 액션")

            case .myPage:
                MyPageView(
                    store: store.scope(state: \.myPage, action: \.myPage)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if shouldShowBottomNavigation {
                DSBottomNavigation(
                    selectedItem: bottomNavigationBinding
                )
            }
        }
    }

    private var shouldShowBottomNavigation: Bool {
        store.selectedTab != .todak
            && store.myPage.edit == nil
            && store.myPage.sajuDetail == nil
            && store.myPage.notificationSettings == nil
            && store.myPage.appSettings == nil
            && store.myPage.withdrawal == nil
            && store.myPage.sajuManagement == nil
    }

    private var bottomNavigationBinding: Binding<DSBottomNavigationItem> {
        Binding(
            get: { store.selectedTab.bottomNavigationItem },
            set: { store.send(.selectedTabChanged($0.tab)) }
        )
    }
}

private extension MainTabFeature.Tab {
    var bottomNavigationItem: DSBottomNavigationItem {
        switch self {
        case .fortune: .fortune
        case .todak: .todak
        case .luckyAction: .luckyAction
        case .myPage: .myPage
        }
    }
}

private extension DSBottomNavigationItem {
    var tab: MainTabFeature.Tab {
        switch self {
        case .fortune: .fortune
        case .todak: .todak
        case .luckyAction: .luckyAction
        case .myPage: .myPage
        }
    }
}

private struct UnavailableTabView: View {
    let title: LocalizedStringResource

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(DesignSystemAsset.Colors.gray975.swiftUIColor)

            Text("준비 중인 기능이에요.")
                .font(.subheadline)
                .foregroundStyle(DesignSystemAsset.Colors.gray600.swiftUIColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystemAsset.Colors.gray100.swiftUIColor)
    }
}
