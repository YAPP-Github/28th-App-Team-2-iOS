import XCTest
@testable import DesignSystem

func XCTAssertColorEqual(
    _ actual: DesignSystemColors?,
    _ expected: DesignSystemColors,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertEqual(actual?.name, expected.name, file: file, line: line)
}
