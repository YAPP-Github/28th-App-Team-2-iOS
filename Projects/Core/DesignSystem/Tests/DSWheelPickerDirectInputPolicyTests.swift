import Testing
@testable import DesignSystem

struct DSWheelPickerDirectInputPolicyTests {
    @Test("날짜 열별 최대 입력 자릿수")
    func testDateMaximumDigits() {
        #expect(
            DSWheelPickerDirectInputPolicy.maximumDigits(
                for: .date,
                columnIndex: 0
            ) == 4
        )
        #expect(
            DSWheelPickerDirectInputPolicy.maximumDigits(
                for: .date,
                columnIndex: 1
            ) == 2
        )
        #expect(
            DSWheelPickerDirectInputPolicy.maximumDigits(
                for: .date,
                columnIndex: 2
            ) == 2
        )
    }

    @Test("시간 열은 직접 입력 자릿수를 제공하지 않음")
    func testTimeMaximumDigits() {
        #expect(
            DSWheelPickerDirectInputPolicy.maximumDigits(
                for: .time,
                columnIndex: 0
            ) == nil
        )
    }

    @Test("날짜 입력은 연도에서 월, 월에서 일로 이동")
    func testDateNextColumnIndex() {
        #expect(
            DSWheelPickerDirectInputPolicy.nextColumnIndex(
                for: .date,
                columnIndex: 0,
                columnCount: 3
            ) == 1
        )
        #expect(
            DSWheelPickerDirectInputPolicy.nextColumnIndex(
                for: .date,
                columnIndex: 1,
                columnCount: 3
            ) == 2
        )
        #expect(
            DSWheelPickerDirectInputPolicy.nextColumnIndex(
                for: .date,
                columnIndex: 2,
                columnCount: 3
            ) == nil
        )
    }

    @Test(
        "숫자만 남기고 최대 자릿수로 제한",
        arguments: [
            ("19999", 4, "1999"),
            ("0a2", 2, "02"),
            ("13", 2, "13")
        ]
    )
    func testNormalizedDigits(
        input: String,
        maximumDigits: Int,
        expected: String
    ) {
        #expect(
            DSWheelPickerDirectInputPolicy.normalizedDigits(
                input,
                maximumDigits: maximumDigits
            ) == expected
        )
    }

    @Test("최대 자릿수에 도달한 경우에만 자동 확정")
    func testShouldCommit() {
        #expect(
            DSWheelPickerDirectInputPolicy.shouldCommit(
                "1999",
                maximumDigits: 4
            )
        )
        #expect(
            !DSWheelPickerDirectInputPolicy.shouldCommit(
                "199",
                maximumDigits: 4
            )
        )
        #expect(
            !DSWheelPickerDirectInputPolicy.shouldCommit(
                "19999",
                maximumDigits: 4
            )
        )
    }
}
