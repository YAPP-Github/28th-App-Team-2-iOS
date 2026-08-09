import AuthSession
import ComposableArchitecture
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
}
