import AuthSession
import ComposableArchitecture
import Foundation
import Model
import NetworkCore
import XCTest
@testable import OnboardingFeature

@MainActor
final class OnboardingSignupTests: XCTestCase {
    func testSignupSubmitsOnboardingValuesThenStoresSession() async {
        let tokens = SessionTokens(accessToken: "access-token", refreshToken: "refresh-token")
        var initialState = OnboardingFeature.State()
        initialState.route = .onboarding
        initialState.onboardingStep = .userStatus
        initialState.onboardingToken = "onboarding-token"
        initialState.onboardingName = "홍길동"
        initialState.gender = .female
        initialState.birthDateCalendar = .lunar
        initialState.birthDate = BirthDate(year: 2000, month: 1, day: 2)
        initialState.isBirthTimeUnknown = true
        initialState.dailyRoutine = .selfEmployedOrFreelance
        initialState.romanticRelationshipStatus = .divorced

        let store = TestStore(initialState: initialState) {
            OnboardingFeature()
        } withDependencies: {
            $0.authClient.signup = { input in
                XCTAssertEqual(input, expectedSignupInput)
                return tokens
            }
            $0.notificationAuthorizationClient.requestAuthorization = { true }
            $0.authSession.save = { savedTokens in
                XCTAssertEqual(savedTokens, tokens)
            }
        }

        await store.send(.userStatusNextButtonTapped) {
            $0.signupPhase = .signingUp
        }
        await store.receive(.signupResponse(.success(tokens))) {
            $0.pendingSignupTokens = tokens
            $0.signupPhase = .savingSession
        }
        await store.receive(.signupTokenStorageSucceeded) {
            $0.pendingSignupTokens = nil
            $0.onboardingToken = nil
            $0.signupPhase = .requestingNotificationAuthorization
        }
        await store.receive(.notificationAuthorizationResponse(true)) {
            $0.signupPhase = .idle
            $0.route = .home
        }
        await store.receive(.delegate(.authenticationCompleted))
    }

    func testNotificationAuthorizationDenialStillCompletesOnboarding() async {
        var initialState = OnboardingFeature.State()
        initialState.route = .onboarding
        initialState.signupPhase = .savingSession

        let store = TestStore(initialState: initialState) {
            OnboardingFeature()
        } withDependencies: {
            $0.notificationAuthorizationClient.requestAuthorization = { false }
        }

        await store.send(.signupTokenStorageSucceeded) {
            $0.signupPhase = .requestingNotificationAuthorization
        }
        await store.receive(.notificationAuthorizationResponse(false)) {
            $0.signupPhase = .idle
            $0.route = .home
        }
        await store.receive(.delegate(.authenticationCompleted))
    }

    func testExpiredSignupPresentsDialogThenReturnsToLoginAfterConfirmation() async {
        var initialState = OnboardingFeature.State()
        initialState.route = .onboarding
        initialState.signupPhase = .signingUp
        initialState.onboardingStep = .userStatus
        initialState.onboardingToken = "expired-onboarding-token"
        initialState.terms[0].isAgreed = true
        initialState.selectedTermDetail = initialState.terms[0]
        initialState.onboardingName = "홍길동"
        initialState.gender = .female
        initialState.birthDateCalendar = .lunar
        initialState.birthDate = BirthDate(year: 2000, month: 1, day: 2)
        initialState.isBirthTimeUnknown = true
        initialState.dailyRoutine = .employed
        initialState.romanticRelationshipStatus = .dating

        let store = TestStore(initialState: initialState) {
            OnboardingFeature()
        }

        // 만료 응답만으로는 로그인 화면으로 이동하지 않는다.
        await store.send(.signupResponse(.failure(.expired))) {
            $0.onboardingToken = nil
            $0.signupPhase = .idle
            $0.isSignupExpirationDialogPresented = true
        }

        XCTAssertEqual(store.state.route, .onboarding)
        XCTAssertFalse(store.state.signupPhase.showsSignupLoading)

        // 사용자가 만료 안내를 확인한 뒤 초기 로그인으로 이동한다.
        await store.send(.signupExpirationDialogConfirmed) {
            $0.route = .login
            $0.isSignupExpirationDialogPresented = false
            $0.onboardingStep = .terms
            $0.terms = OnboardingTerm.defaultTerms
            $0.selectedTermDetail = nil
            $0.onboardingName = ""
            $0.gender = nil
            $0.birthDateCalendar = nil
            $0.birthDate = nil
            $0.isBirthTimeUnknown = false
            $0.dailyRoutine = nil
            $0.romanticRelationshipStatus = nil
        }
    }

    func testNonExpiredSignupFailureRemainsRetryable() async {
        var initialState = OnboardingFeature.State()
        initialState.route = .onboarding
        initialState.signupPhase = .signingUp

        let store = TestStore(initialState: initialState) {
            OnboardingFeature()
        }

        await store.send(.signupResponse(.failure(.requestFailed))) {
            $0.signupPhase = .failed(.signup(.requestFailed))
        }

        XCTAssertFalse(store.state.isSignupExpirationDialogPresented)
    }

    func testSignupLoadingPresentationStartsWhenRequestStarts() {
        XCTAssertTrue(SignupPhase.signingUp.showsSignupLoading)
        XCTAssertTrue(SignupPhase.savingSession.showsSignupLoading)
        XCTAssertTrue(SignupPhase.requestingNotificationAuthorization.showsSignupLoading)
        XCTAssertFalse(SignupPhase.idle.showsSignupLoading)
        XCTAssertFalse(SignupPhase.failed(.signup(.requestFailed)).showsSignupLoading)
    }

    func testLiveSignupClientEncodesSwaggerSchema() async throws {
        let recorder = RequestRecorder()
        let httpClient = HTTPClient(
            baseURL: try XCTUnwrap(URL(string: "https://api-dev.todakun.com")),
            transport: { request in
                await recorder.record(request)
                let responseData = Data(
                    """
                    {"success":true,"data":{"accessToken":"access-token","refreshToken":"refresh-token"}}
                    """.utf8
                )
                let response = HTTPURLResponse(
                    url: request.url ?? URL(fileURLWithPath: "/"),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (responseData, response)
            }
        )

        let tokens = try await AuthClient.live(httpClient: httpClient).signup(expectedSignupInput)
        XCTAssertEqual(tokens, SessionTokens(accessToken: "access-token", refreshToken: "refresh-token"))

        let request = await recorder.value()
        XCTAssertEqual(request?.url?.path, "/api/v1/auth/signup")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/json")

        let payload = try JSONDecoder().decode(SignupRequestBody.self, from: try XCTUnwrap(request?.httpBody))
        XCTAssertEqual(payload, SignupRequestBody(input: expectedSignupInput))
    }

    func testLiveSignupClientDoesNotRetryUnauthorizedResponse() async throws {
        let counter = UnauthorizedHandlerCounter()
        let httpClient = HTTPClient(
            baseURL: try XCTUnwrap(URL(string: "https://api-dev.todakun.com")),
            transport: { request in
                let response = HTTPURLResponse(
                    url: request.url ?? URL(fileURLWithPath: "/"),
                    statusCode: 401,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (Data(), response)
            },
            onUnauthorized: {
                await counter.increment()
                return true
            }
        )

        do {
            _ = try await AuthClient.live(httpClient: httpClient).signup(expectedSignupInput)
            XCTFail("signup endpoint의 401은 갱신 처리기를 호출하면 안 됩니다.")
        } catch let error as AuthClientError {
            XCTAssertEqual(error, .expired)
        } catch {
            XCTFail("예상하지 못한 오류: \(error)")
        }

        let invocationCount = await counter.value
        XCTAssertEqual(invocationCount, 0)
    }

    func testLiveRefreshClientRotatesSessionTokens() async throws {
        let recorder = RequestRecorder()
        let httpClient = HTTPClient(
            baseURL: try XCTUnwrap(URL(string: "https://api-dev.todakun.com")),
            transport: { request in
                await recorder.record(request)
                let responseData = Data(
                    """
                    {"success":true,"data":{"accessToken":"new-access","refreshToken":"new-refresh"}}
                    """.utf8
                )
                let response = HTTPURLResponse(
                    url: request.url ?? URL(fileURLWithPath: "/"),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (responseData, response)
            }
        )

        let tokens = try await AuthClient.live(httpClient: httpClient).refresh("old-refresh")

        XCTAssertEqual(tokens, SessionTokens(accessToken: "new-access", refreshToken: "new-refresh"))
        let request = await recorder.value()
        XCTAssertEqual(request?.url?.path, "/api/v1/auth/refresh")
        let body = try JSONDecoder().decode(
            RefreshRequestBody.self,
            from: try XCTUnwrap(request?.httpBody)
        )
        XCTAssertEqual(body.refreshToken, "old-refresh")
    }

    func testLiveRefreshClientDoesNotRetryItsOwnUnauthorizedResponse() async throws {
        let counter = UnauthorizedHandlerCounter()
        let httpClient = HTTPClient(
            baseURL: try XCTUnwrap(URL(string: "https://api-dev.todakun.com")),
            transport: { request in
                let response = HTTPURLResponse(
                    url: request.url ?? URL(fileURLWithPath: "/"),
                    statusCode: 401,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (Data(), response)
            },
            onUnauthorized: {
                await counter.increment()
                return true
            }
        )

        do {
            _ = try await AuthClient.live(httpClient: httpClient).refresh("expired-refresh")
            XCTFail("refresh endpoint의 401은 갱신 처리기를 호출하면 안 됩니다.")
        } catch let error as AuthClientError {
            XCTAssertEqual(error, .expired)
        } catch {
            XCTFail("예상하지 못한 오류: \(error)")
        }

        let invocationCount = await counter.value
        XCTAssertEqual(invocationCount, 0)
    }
}

private let expectedSignupInput = SignupInput(
    onboardingToken: "onboarding-token",
    name: "홍길동",
    birthDate: "2000-01-02",
    birthTime: "UNKNOWN",
    calendarType: "LUNAR",
    gender: "FEMALE",
    job: "FREELANCER",
    relationshipStatus: "REMARRY"
)

private actor RequestRecorder {
    private var request: URLRequest?

    func record(_ request: URLRequest) {
        self.request = request
    }

    func value() -> URLRequest? {
        request
    }
}

private actor UnauthorizedHandlerCounter {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}

private struct SignupRequestBody: Decodable, Equatable {
    let onboardingToken: String
    let name: String
    let birthDate: String
    let birthTime: String
    let calendarType: String
    let gender: String
    let job: String
    let relationshipStatus: String

    init(input: SignupInput) {
        onboardingToken = input.onboardingToken
        name = input.name
        birthDate = input.birthDate
        birthTime = input.birthTime
        calendarType = input.calendarType
        gender = input.gender
        job = input.job
        relationshipStatus = input.relationshipStatus
    }
}

private struct RefreshRequestBody: Decodable, Equatable {
    let refreshToken: String
}
