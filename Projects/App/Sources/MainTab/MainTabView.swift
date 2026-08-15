import ComposableArchitecture
import DesignSystem
import FortuneFeature
import Foundation
import LuckyActionFeature
import MyPageFeature
import SwiftUI

struct MainTabView: View {
    @Bindable var store: StoreOf<MainTabFeature>

    init(store: StoreOf<MainTabFeature>) {
        self.store = store
    }

    var body: some View {
        ZStack {
            switch store.selectedTab {
            case .fortune:
                fortuneTab

            case .todak:
                UnavailableTabView(title: "토닥이")

            case .luckyAction:
                LuckyActionView(
                    store: store.scope(state: \.luckyAction, action: \.luckyAction)
                )

            case .myPage:
                MyPageView(
                    store: store.scope(state: \.myPage, action: \.myPage)
                )
            }

            if isMyInfoEditPresented {
                MyPageEditView(
                    store: store.scope(state: \.myPage, action: \.myPage)
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isMyInfoEditPresented)
        .onChange(of: currentCompatibilityDestinationID) { _, _ in
            store.send(.fortuneNavigationChanged)
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
        let fortuneShowing = store.selectedTab != .fortune || !store.fortune.isShowingDetail
        let myPageShowing = store.selectedTab != .myPage || (
            store.myPage.edit == nil
            && store.myPage.sajuDetail == nil
            && store.myPage.notificationSettings == nil
            && store.myPage.appSettings == nil
            && store.myPage.withdrawal == nil
            && store.myPage.sajuManagement == nil
        )
        return fortuneShowing
            && myPageShowing
            && !isMyInfoEditPresented
            && store.pushedLuckyAction == nil
    }

    private var fortuneTab: some View {
        FortuneNavigationView(
            store: store.scope(state: \.fortune, action: \.fortune),
            isLuckyActionPresented: Binding(
                get: { store.pushedLuckyAction != nil },
                set: { isPresented in
                    store.send(.pushedLuckyActionPresentationChanged(isPresented))
                }
            ),
            luckyActionDestination: AnyView(pushedLuckyActionDestination)
        )
    }

    @ViewBuilder
    private var pushedLuckyActionDestination: some View {
        if let luckyActionStore = store.scope(
            state: \.pushedLuckyAction,
            action: \.pushedLuckyAction.presented
        ) {
            LuckyActionView(store: luckyActionStore)
        } else {
            EmptyView()
        }
    }

    private var isMyInfoEditPresented: Bool {
        guard let currentCompatibilityDestinationID else { return false }
        return store.selectedTab == .fortune
            && store.compatibilityEditSourceID == currentCompatibilityDestinationID
            && store.myPage.edit != nil
    }

    private var currentCompatibilityDestinationID: StackElementID? {
        guard let destinationID = store.fortune.path.ids.last,
              case .compatibility = store.fortune.path[id: destinationID]
        else {
            return nil
        }
        return destinationID
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
