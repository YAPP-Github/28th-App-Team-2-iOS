import AuthSession
import ComposableArchitecture
import DesignSystem
import XCTest
@testable import Todakun

@MainActor
final class RootFeatureTests: XCTestCase {
    func testLaunchWithoutStoredSessionShowsOnboarding() async {
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

    func testLaunchWithStoredSessionShowsAuthenticatedRoute() async {
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

    func testLaunchWithSessionRestoreFailureShowsOnboarding() async {
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

    func testTaskDoesNotRestoreSessionAfterRouteIsResolved() async {
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
        XCTAssertEqual(restoreCount, 0)
    }

    func testOnboardingCompletionShowsAuthenticatedRoute() async {
        var state = RootFeature.State()
        state.route = .unauthenticated
        let store = TestStore(initialState: state) {
            RootFeature()
        }

        await store.send(.onboarding(.delegate(.authenticationCompleted))) {
            $0.route = .authenticated
        }
    }

    func testMainTabSelectionChanges() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        await store.send(.selectedItemChanged(.myPage)) {
            $0.selectedItem = .myPage
        }
    }

    func testSessionEndFromMyPageClearsSessionAndShowsOnboarding() async {
        var state = RootFeature.State()
        state.route = .authenticated
        let store = TestStore(initialState: state) {
            RootFeature()
        } withDependencies: {
            $0.authSession.clear = {}
        }

        await store.send(.mainTab(.myPage(.delegate(.sessionEnded))))
        await store.receive(.sessionCleared) {
            $0.mainTab = MainTabFeature.State()
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
