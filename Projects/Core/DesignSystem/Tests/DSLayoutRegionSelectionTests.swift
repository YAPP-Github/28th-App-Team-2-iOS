#if DEBUG
import Testing
@testable import DesignSystem
import CoreGraphics

struct DSLayoutRegionSelectionTests {
    @Test("포함하는 가장 작은 영역이 선택되는지 검증")
    func testSmallestContainingRegionIsSelected() {
        let regions = [
            region(regionID: "container", frame: CGRect(x: 0, y: 0, width: 100, height: 100), depth: 1),
            region(regionID: "content", frame: CGRect(x: 10, y: 10, width: 40, height: 40), depth: 2)
        ]

        let selectedRegion = DSLayoutMeasurementCalculator.region(
            at: CGPoint(x: 20, y: 20),
            in: regions
        )

        #expect(selectedRegion?.regionID == "content")
    }

    @Test("동일 프레임일 때 더 깊은 depth 영역 우선권 검증")
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

        #expect(selectedRegion?.regionID == "child")
    }

    @Test("동일 프레임일 때 디자인시스템 영역 우선권 검증")
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

        #expect(selectedRegion?.regionID == "component")
    }

    @Test("화면 크기의 루트 컨테이너 선택 가능 검증")
    func testScreenSizedContainerCanBeSelected() {
        let viewport = CGRect(x: 0, y: 0, width: 100, height: 200)
        let regions = [
            region(regionID: "root", frame: viewport, depth: 1)
        ]

        let selectedRegion = DSLayoutMeasurementCalculator.region(
            at: CGPoint(x: 50, y: 100),
            in: regions
        )

        #expect(selectedRegion?.regionID == "root")
    }

    @Test("기선택된 영역 재선택 시 선택 해제 검증")
    func testSelectingAnAlreadySelectedRegionDeselectsIt() {
        let selection = DSLayoutMeasurementCalculator.spacingSelectionIDs(
            afterSelecting: "first",
            currentSelection: ["first", "second"]
        )

        #expect(selection == ["second"])
    }

    @Test("세 번째 영역 선택 시 새로운 선택이 시작되는지 검증")
    func testSelectingThirdRegionStartsNewSelection() {
        let selection = DSLayoutMeasurementCalculator.spacingSelectionIDs(
            afterSelecting: "third",
            currentSelection: ["first", "second"]
        )

        #expect(selection == ["third"])
    }

    @Test("검사 선택 시 이전 영역을 대체하는지 검증")
    func testInspectionSelectionReplacesPreviousRegion() {
        let selection = DSLayoutMeasurementCalculator.inspectionSelectionIDs(
            afterSelecting: "second",
            currentSelection: ["first"]
        )

        #expect(selection == ["second"])
    }

    @Test("검사 선택 해제 가능 검증")
    func testInspectionSelectionCanBeDeselected() {
        let selection = DSLayoutMeasurementCalculator.inspectionSelectionIDs(
            afterSelecting: "first",
            currentSelection: ["first"]
        )

        #expect(selection.isEmpty)
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
