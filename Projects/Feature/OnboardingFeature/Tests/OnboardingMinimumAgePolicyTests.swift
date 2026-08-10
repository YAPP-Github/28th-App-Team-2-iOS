import ComposableArchitecture
import Foundation
import Model
import XCTest
@testable import OnboardingFeature

@MainActor
final class OnboardingMinimumAgePolicyTests: XCTestCase {
    func testFortuneInformationBlocksUnderageBirthDate() async {
        let store = TestStore(initialState: makeFortuneInformationState()) {
            OnboardingFeature()
        } withDependencies: {
            $0.date.now = makeDate(year: 2026, month: 8, day: 9)
        }

        await store.send(.birthDateChanged(BirthDate(year: 2012, month: 8, day: 10))) {
            $0.birthDate = BirthDate(year: 2012, month: 8, day: 10)
            $0.birthDateAgeValidationMessage = OnboardingMinimumAgePolicy.minimumAgeMessage
        }
        XCTAssertFalse(store.state.isFortuneInformationValid)

        await store.send(.fortuneInformationNextButtonTapped)
        XCTAssertEqual(store.state.onboardingStep, .fortuneInformation)
    }

    func testFortuneInformationAllowsUserOnFourteenthBirthday() async {
        let store = TestStore(initialState: makeFortuneInformationState()) {
            OnboardingFeature()
        } withDependencies: {
            $0.date.now = makeDate(year: 2026, month: 8, day: 9)
        }

        await store.send(.birthDateChanged(BirthDate(year: 2012, month: 8, day: 9))) {
            $0.birthDate = BirthDate(year: 2012, month: 8, day: 9)
        }
        XCTAssertTrue(store.state.isFortuneInformationValid)

        await store.send(.fortuneInformationNextButtonTapped) {
            $0.onboardingStep = .userStatus
        }
    }

    private func makeFortuneInformationState() -> OnboardingFeature.State {
        var state = OnboardingFeature.State()
        state.onboardingStep = .fortuneInformation
        state.gender = .female
        state.birthDateCalendar = .solar
        state.isBirthTimeUnknown = true
        return state
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar.date(
            from: DateComponents(year: year, month: month, day: day, hour: 12)
        ) ?? .distantPast
    }
}
