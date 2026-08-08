import Testing
import Model
@testable import DesignSystem

struct DSEnterTimeOfBirthSpecificationTests {
    @Test("Enter Time of Birth 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSEnterTimeOfBirth.specification()

        #expect(specification.contentSpacing == 16)
        #expect(specification.fieldSpacing == 12)
        #expect(specification.labelFontStyle == .body1Bold)
        expectColorEqual(
            specification.labelForegroundAsset,
            DesignSystemAsset.Colors.black
        )

        let unknownTimeOption = specification.unknownTimeOption

        #expect(
            unknownTimeOption.shape
                == .roundedRectangle(cornerRadius: 12)
        )
        expectColorEqual(
            unknownTimeOption.backgroundAsset,
            DesignSystemAsset.Colors.gray25
        )
        #expect(unknownTimeOption.horizontalPadding == 16)
        #expect(unknownTimeOption.verticalPadding == 14)
        #expect(unknownTimeOption.labelSpacing == 6)
        #expect(unknownTimeOption.labelFontStyle == .body3Medium)
        expectColorEqual(
            unknownTimeOption.labelForegroundAsset,
            DesignSystemAsset.Colors.gray975
        )
    }

    @Test("Enter Time of Birth 모델 표시 문자열 검증")
    func testDisplayTitles() {
        #expect(DSEnterTimeOfBirth.displayTitle(for: nil) == nil)
        #expect(
            DSEnterTimeOfBirth.displayTitle(for: .inTime)
                == "인시 (寅時): 03:30 ~ 05:29"
        )
    }

    @Test("출생 시간 전체 피커 표시 문자열 검증")
    func testPickerTitles() {
        #expect(
            BirthTimePeriod.allCases.map(DSEnterTimeOfBirth.pickerTitle(for:)) == [
                "자시 (子時): 23:30 ~ 01:29",
                "축시 (丑時): 01:30 ~ 03:29",
                "인시 (寅時): 03:30 ~ 05:29",
                "묘시 (卯時): 05:30 ~ 07:29",
                "진시 (辰時): 07:30 ~ 09:29",
                "사시 (巳時): 09:30 ~ 11:29",
                "오시 (午時): 11:30 ~ 13:29",
                "미시 (未時): 13:30 ~ 15:29",
                "신시 (申時): 15:30 ~ 17:29",
                "유시 (酉時): 17:30 ~ 19:29",
                "술시 (戌時): 19:30 ~ 21:29",
                "해시 (亥時): 21:30 ~ 23:29"
            ]
        )
    }

    @Test("Enter Time of Birth 표시 binding clear 전달 검증")
    func testSelectionResolution() {
        #expect(
            DSEnterTimeOfBirth.resolvedSelection(
                current: .inTime,
                displayValue: "인시 (寅時): 03:30 ~ 05:29"
            ) == .inTime
        )
        #expect(
            DSEnterTimeOfBirth.resolvedSelection(
                current: .inTime,
                displayValue: nil
            ) == nil
        )
    }

    @Test("시간 모름 선택 시 기존 시간 선택 해제")
    func testUnknownTimeClearsSelection() {
        let previous = DSEnterTimeOfBirth.InputState(
            selection: .inTime,
            isTimeUnknown: false
        )
        let current = DSEnterTimeOfBirth.InputState(
            selection: .inTime,
            isTimeUnknown: true
        )

        let resolved = DSEnterTimeOfBirth.resolvedInputState(
            previous: previous,
            current: current
        )

        #expect(resolved.selection == nil)
        #expect(resolved.isTimeUnknown)
    }

    @Test("시간 선택 시 시간 모름 해제")
    func testSelectionClearsUnknownTime() {
        let previous = DSEnterTimeOfBirth.InputState(
            selection: nil,
            isTimeUnknown: true
        )
        let current = DSEnterTimeOfBirth.InputState(
            selection: .inTime,
            isTimeUnknown: true
        )

        let resolved = DSEnterTimeOfBirth.resolvedInputState(
            previous: previous,
            current: current
        )

        #expect(resolved.selection == .inTime)
        #expect(!resolved.isTimeUnknown)
    }

    @Test("초기 중복 상태는 시간 모름 우선으로 정규화")
    func testInitialConflictPrefersUnknownTime() {
        let state = DSEnterTimeOfBirth.InputState(
            selection: .inTime,
            isTimeUnknown: true
        )

        let resolved = DSEnterTimeOfBirth.resolvedInputState(
            previous: state,
            current: state
        )

        #expect(resolved.selection == nil)
        #expect(resolved.isTimeUnknown)
    }

    @Test("시간 모름 해제 시 이전 시간 복원 안 함")
    func testTurningOffUnknownTimeDoesNotRestoreSelection() {
        let resolved = DSEnterTimeOfBirth.resolvedInputState(
            previous: DSEnterTimeOfBirth.InputState(
                selection: nil,
                isTimeUnknown: true
            ),
            current: DSEnterTimeOfBirth.InputState(
                selection: nil,
                isTimeUnknown: false
            )
        )

        #expect(resolved.selection == nil)
        #expect(!resolved.isTimeUnknown)
    }
}
