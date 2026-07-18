#if DEBUG
import XCTest
@testable import DesignSystem

final class DSLayoutRegionSelectionTests: XCTestCase {
    func testSmallestContainingRegionIsSelected() {
        let regions = [
            region(regionID: "container", frame: CGRect(x: 0, y: 0, width: 100, height: 100), depth: 1),
            region(regionID: "content", frame: CGRect(x: 10, y: 10, width: 40, height: 40), depth: 2)
        ]

        let selectedRegion = DSLayoutMeasurementCalculator.region(
            at: CGPoint(x: 20, y: 20),
            in: regions
        )

        XCTAssertEqual(selectedRegion?.regionID, "content")
    }

    func testDeeperRegionWinsForEqualFrames() {
        let frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        let regions = [
            region(regionID: "parent", frame: frame, depth: 1),
            region(regionID: "child", frame: frame, depth: 3)
        ]

        let selectedRegion = DSLayoutMeasurementCalculator.region(
            at: CGPoint(x: 20, y: 20),
            in: regions
        )

        XCTAssertEqual(selectedRegion?.regionID, "child")
    }

    func testDesignSystemRegionWinsForEqualFrames() {
        let frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        let regions = [
            region(regionID: "view", frame: frame, depth: 3),
            DSLayoutRegion(
                regionID: "component",
                name: "DSButton",
                frame: frame,
                depth: 1,
                source: .designSystem
            )
        ]

        let selectedRegion = DSLayoutMeasurementCalculator.region(
            at: CGPoint(x: 20, y: 20),
            in: regions
        )

        XCTAssertEqual(selectedRegion?.regionID, "component")
    }

    func testScreenSizedContainerCanBeSelected() {
        let viewport = CGRect(x: 0, y: 0, width: 100, height: 200)
        let regions = [
            region(regionID: "root", frame: viewport, depth: 1)
        ]

        let selectedRegion = DSLayoutMeasurementCalculator.region(
            at: CGPoint(x: 50, y: 100),
            in: regions
        )

        XCTAssertEqual(selectedRegion?.regionID, "root")
    }

    func testSelectingAnAlreadySelectedRegionDeselectsIt() {
        let selection = DSLayoutMeasurementCalculator.spacingSelectionIDs(
            afterSelecting: "first",
            currentSelection: ["first", "second"]
        )

        XCTAssertEqual(selection, ["second"])
    }

    func testSelectingThirdRegionStartsNewSelection() {
        let selection = DSLayoutMeasurementCalculator.spacingSelectionIDs(
            afterSelecting: "third",
            currentSelection: ["first", "second"]
        )

        XCTAssertEqual(selection, ["third"])
    }

    func testInspectionSelectionReplacesPreviousRegion() {
        let selection = DSLayoutMeasurementCalculator.inspectionSelectionIDs(
            afterSelecting: "second",
            currentSelection: ["first"]
        )

        XCTAssertEqual(selection, ["second"])
    }

    func testInspectionSelectionCanBeDeselected() {
        let selection = DSLayoutMeasurementCalculator.inspectionSelectionIDs(
            afterSelecting: "first",
            currentSelection: ["first"]
        )

        XCTAssertTrue(selection.isEmpty)
    }

    private func region(
        regionID: String,
        frame: CGRect,
        depth: Int
    ) -> DSLayoutRegion {
        DSLayoutRegion(
            regionID: regionID,
            name: regionID,
            frame: frame,
            depth: depth,
            source: .view
        )
    }
}
#endif
