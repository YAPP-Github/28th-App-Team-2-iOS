#if DEBUG
import CoreGraphics
import XCTest
@testable import DesignSystem

final class DSLayoutRegionMergerTests: XCTestCase {
    func testDesignSystemRegionWinsForSameFrame() {
        let frame = CGRect(x: 10, y: 20, width: 100, height: 40)
        let result = DSLayoutRegionMerger.merge(
            automaticRegions: [region(regionID: "view", frame: frame, source: .view)],
            reportedRegions: [region(regionID: "button", frame: frame, source: .designSystem)],
            displayScale: 3
        )

        XCTAssertEqual(result.map(\.regionID), ["button"])
    }

    func testDetailsAreAlwaysVisible() {
        let outer = region(
            regionID: "button",
            frame: CGRect(x: 0, y: 0, width: 100, height: 40),
            source: .designSystem
        )
        let detail = region(
            regionID: "title",
            frame: CGRect(x: 20, y: 10, width: 60, height: 20),
            source: .designSystemDetail
        )

        let result = DSLayoutRegionMerger.merge(
            automaticRegions: [],
            reportedRegions: [outer, detail],
            displayScale: 3
        )

        XCTAssertEqual(result.map(\.regionID), ["button", "title"])
    }

    func testTypographyLineBoxReplacesAccessibilityBounds() {
        let accessibilityText = region(
            regionID: "accessibility-text",
            frame: CGRect(x: 10, y: 12.9, width: 100, height: 170.3),
            source: .accessibility
        )
        let typography = region(
            regionID: "typography",
            frame: CGRect(x: 10, y: 10, width: 100, height: 176),
            source: .designSystemDetail,
            suppressesContainedAutomaticRegions: true
        )

        let result = DSLayoutRegionMerger.merge(
            automaticRegions: [accessibilityText],
            reportedRegions: [typography],
            displayScale: 3
        )

        XCTAssertEqual(result.map(\.regionID), ["typography"])
    }

    func testTypographyKeepsNarrowerChildRegion() {
        let child = region(
            regionID: "child",
            frame: CGRect(x: 30, y: 12, width: 20, height: 20),
            source: .accessibility
        )
        let typography = region(
            regionID: "typography",
            frame: CGRect(x: 10, y: 10, width: 100, height: 24),
            source: .designSystemDetail,
            suppressesContainedAutomaticRegions: true
        )

        let result = DSLayoutRegionMerger.merge(
            automaticRegions: [child],
            reportedRegions: [typography],
            displayScale: 3
        )

        XCTAssertEqual(result.map(\.regionID), ["typography", "child"])
    }

    func testDisplayScaleQuantization() {
        let regions = [
            region(
                regionID: "first",
                frame: CGRect(x: 1.0 / 3.0, y: 0, width: 10, height: 10),
                source: .view
            ),
            region(
                regionID: "second",
                frame: CGRect(x: 2.0 / 3.0, y: 0, width: 10, height: 10),
                source: .view
            )
        ]

        let result = DSLayoutRegionMerger.deduplicateAutomatic(
            regions,
            displayScale: 3
        )

        XCTAssertEqual(result.count, 2)
    }

    private func region(
        regionID: String,
        frame: CGRect,
        source: DSLayoutRegionSource,
        suppressesContainedAutomaticRegions: Bool = false
    ) -> DSLayoutRegion {
        DSLayoutRegion(
            regionID: regionID,
            name: regionID,
            frame: frame,
            depth: 0,
            source: source,
            suppressesContainedAutomaticRegions:
                suppressesContainedAutomaticRegions
        )
    }
}
#endif
