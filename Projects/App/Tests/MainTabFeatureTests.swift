import ComposableArchitecture
import FortuneFeature
import Testing
@testable import Todakun

@Suite
@MainActor
struct MainTabFeatureTests {
    @Test
    func defaultSelectedTabIsFortune() {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        #expect(store.state.selectedTab == .fortune)
    }

    @Test
    func selectedTabChanged() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        await store.send(.selectedTabChanged(.todak)) {
            $0.selectedTab = .todak
        }

        await store.send(.selectedTabChanged(.myPage)) {
            $0.selectedTab = .myPage
        }
    }

    @Test
    func fortuneDelegateLuckyActionRequestedSwitchesTab() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        await store.send(.fortune(.delegate(.luckyActionRequested))) {
            $0.selectedTab = .luckyAction
        }
    }

    @Test
    func fortuneDelegateTodakRequestedSwitchesTab() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        await store.send(.fortune(.delegate(.todakRequested))) {
            $0.selectedTab = .todak
        }
    }

    @Test
    func fortuneDelegateMyPageRequestedSwitchesTab() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        await store.send(.fortune(.delegate(.myPageRequested))) {
            $0.selectedTab = .myPage
        }
    }

    @Test
    func fortuneDelegateMyInfoEditRequestedPresentsEditWithoutSwitchingTab() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.fortune(.delegate(.myInfoEditRequested)))
        await store.receive(.myPage(.presentEdit))

        #expect(store.state.selectedTab == .fortune)
    }

    @Test
    func profileUpdateRefreshesMySajuInCurrentCompatibilityScreen() async {
        var state = MainTabFeature.State()
        state.fortune.path.append(.compatibility(.init()))
        let store = TestStore(initialState: state) {
            MainTabFeature()
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.myPage(.delegate(.profileUpdated)))
        await store.receive(
            .fortune(
                .path(
                    .element(
                        id: 0,
                        action: .compatibility(.mySajuRefreshRequested)
                    )
                )
            )
        )
    }

    @Test
    func statePersistedAcrossTabChanges() async {
        var initialState = MainTabFeature.State()
        initialState.fortune.viewState = .failed(message: "네트워크 오류가 발생했습니다.")

        let store = TestStore(initialState: initialState) {
            MainTabFeature()
        }

        await store.send(.selectedTabChanged(.todak)) {
            $0.selectedTab = .todak
        }

        #expect(
            store.state.fortune.viewState == .failed(message: "네트워크 오류가 발생했습니다.")
        )

        await store.send(.selectedTabChanged(.fortune)) {
            $0.selectedTab = .fortune
        }

        #expect(
            store.state.fortune.viewState == .failed(message: "네트워크 오류가 발생했습니다.")
        )
    }
}
