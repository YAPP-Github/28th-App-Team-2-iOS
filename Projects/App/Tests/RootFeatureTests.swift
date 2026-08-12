import AuthSession
import ComposableArchitecture
import OnboardingFeature
import Testing
@testable import Todakun

@Suite
@MainActor
struct RootFeatureTests {
    @Test
    func launchWithoutStoredSessionShowsOnboarding() async {
        let store = TestStore(initialState: RootFeature.State()) {
            RootFeature()
        } withDependencies: {
            $0.authSession.restore = { false }
        }

        await store.send(.task)
        await store.receive(.sessionRestored(.success(false))) {
            $0.route = .unauthenticated
        }
    }

    @Test
    func launchWithStoredSessionShowsAuthenticatedRoute() async {
        let store = TestStore(initialState: RootFeature.State()) {
            RootFeature()
        } withDependencies: {
            $0.authSession.restore = { true }
        }

        await store.send(.task)
        await store.receive(.sessionRestored(.success(true))) {
            $0.route = .authenticated
        }
    }

    @Test
    func launchWithSessionRestoreFailureShowsOnboarding() async {
        let store = TestStore(initialState: RootFeature.State()) {
            RootFeature()
        } withDependencies: {
            $0.authSession.restore = { throw AuthSessionError.loadFailed }
        }

        await store.send(.task)
        await store.receive(.sessionRestored(.failure(.loadFailed))) {
            $0.route = .unauthenticated
        }
    }

    @Test
    func taskDoesNotRestoreSessionAfterRouteIsResolved() async {
        let counter = RestoreCounter()
        var state = RootFeature.State()
        state.route = .unauthenticated
        let store = TestStore(initialState: state) {
            RootFeature()
        } withDependencies: {
            $0.authSession.restore = {
                await counter.increment()
                return false
            }
        }

        await store.send(.task)

        let restoreCount = await counter.value
        #expect(restoreCount == 0)
    }

    @Test
    func onboardingCompletionShowsAuthenticatedRoute() async {
        var state = RootFeature.State()
        state.route = .unauthenticated
        state.mainTab.selectedTab = .myPage
        let store = TestStore(initialState: state) {
            RootFeature()
        }

        await store.send(.onboarding(.delegate(.authenticationCompleted))) {
            $0.route = .authenticated
        }
        #expect(store.state.mainTab.selectedTab == .myPage)
    }

    @Test
    func sessionEndFromMyPageClearsSessionAndShowsOnboarding() async {
        var state = RootFeature.State()
        state.route = .authenticated
        state.onboarding.route = .home
        let store = TestStore(initialState: state) {
            RootFeature()
        } withDependencies: {
            $0.authSession.clear = {}
        }

        await store.send(.mainTab(.myPage(.delegate(.sessionEnded))))
        await store.receive(.sessionCleared) {
            $0.mainTab = MainTabFeature.State()
            $0.onboarding = OnboardingFeature.State()
            $0.route = .unauthenticated
        }
    }
}

private actor RestoreCounter {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}
