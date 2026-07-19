import XCTest
@testable import DesignSystem

final class DSIconAssetTests: XCTestCase {
    func testAssetNames() {
        XCTAssertEqual(
            DSIconAsset.allCases.map(\.name),
            ["checkLine", "edit"]
        )
    }
}
