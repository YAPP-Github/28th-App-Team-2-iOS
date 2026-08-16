import ComposableArchitecture
import FortuneFeature
import Foundation
import LuckyActionFeature
import Testing
import TodakFeature
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
    func fortuneDelegateLuckyActionTabRequestedSwitchesTab() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        await store.send(.fortune(.delegate(.luckyActionTabRequested))) {
            $0.selectedTab = .luckyAction
        }
    }

    @Test
    func fortuneDelegateLuckyActionPushRequestedPresentsLuckyAction() async {
        let now = Date(timeIntervalSince1970: 1_786_762_800)
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        } withDependencies: {
            $0.date.now = now
        }

        await store.send(.fortune(.delegate(.luckyActionPushRequested))) {
            $0.pushedLuckyAction = LuckyActionFeature.State(
                presentationStyle: .pushed,
                today: now
            )
        }
    }

    @Test
    func dismissingPushedLuckyActionPreservesFortuneReportPath() async {
        var state = MainTabFeature.State()
        state.fortune.path.append(.report(.init(dailyFortuneID: UUID())))
        state.pushedLuckyAction = .init(presentationStyle: .pushed)
        let store = TestStore(initialState: state) {
            MainTabFeature()
        }

        await store.send(.pushedLuckyAction(.presented(.delegate(.dismissRequested)))) {
            $0.pushedLuckyAction = nil
        }

        #expect(store.state.fortune.path.count == 1)
    }

    @Test
    func backFromPushedLuckyActionDismissesPresentationAndPreservesReportPath() async {
        var state = MainTabFeature.State()
        state.fortune.path.append(.report(.init(dailyFortuneID: UUID())))
        state.pushedLuckyAction = .init(presentationStyle: .pushed)
        let store = TestStore(initialState: state) {
            MainTabFeature()
        }

        await store.send(.pushedLuckyAction(.presented(.view(.backButtonTapped))))
        await store.receive(.pushedLuckyAction(.presented(.delegate(.dismissRequested)))) {
            $0.pushedLuckyAction = nil
        }

        #expect(store.state.fortune.path.count == 1)
    }

    @Test
    func reopeningPushedLuckyActionCreatesFreshState() async {
        let now = Date(timeIntervalSince1970: 1_786_762_800)
        var previousPresentation = LuckyActionFeature.State(
            presentationStyle: .pushed,
            today: now
        )
        previousPresentation.selectedDate = previousPresentation.today.addingTimeInterval(-86_400)
        let store = TestStore(
            initialState: MainTabFeature.State(
                pushedLuckyAction: previousPresentation
            )
        ) {
            MainTabFeature()
        } withDependencies: {
            $0.date.now = now
        }

        await store.send(.pushedLuckyAction(.presented(.delegate(.dismissRequested)))) {
            $0.pushedLuckyAction = nil
        }

        await store.send(.fortune(.delegate(.luckyActionPushRequested))) {
            $0.pushedLuckyAction = LuckyActionFeature.State(
                presentationStyle: .pushed,
                today: now
            )
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
        var state = MainTabFeature.State()
        state.fortune.path.append(.compatibility(.init()))
        let store = TestStore(initialState: state) {
            MainTabFeature()
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.fortune(.delegate(.myInfoEditRequested))) {
            $0.compatibilityEditSourceID = 0
        }
        await store.receive(.myPage(.presentEdit))

        #expect(store.state.selectedTab == .fortune)
    }

    @Test
    func poppedCompatibilityDiscardsPendingMyInfoEditPresentation() async {
        var state = MainTabFeature.State()
        state.fortune.path.append(.compatibility(.init()))
        state.compatibilityEditSourceID = 0
        state.myPage.isPendingEditPresentation = true
        state.fortune.path.removeLast()

        let store = TestStore(initialState: state) {
            MainTabFeature()
        }

        await store.send(.fortuneNavigationChanged) {
            $0.compatibilityEditSourceID = nil
        }
        await store.receive(.myPage(.discardPendingEditPresentation)) {
            $0.myPage.isPendingEditPresentation = false
        }
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

    @Test
    func closingTodakReturnsToPreviousTab() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        await store.send(.selectedTabChanged(.myPage)) {
            $0.selectedTab = .myPage
        }
        await store.send(.selectedTabChanged(.todak)) {
            $0.previousTab = .myPage
            $0.selectedTab = .todak
        }
        await store.send(.todak(.delegate(.closeRequested))) {
            $0.selectedTab = .myPage
        }
    }
}
