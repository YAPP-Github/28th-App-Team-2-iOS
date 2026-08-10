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
