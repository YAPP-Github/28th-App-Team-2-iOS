#if DEBUG
import CoreGraphics
import Testing
@testable import DesignSystem

struct DSLayoutRegionMergerTests {
    @Test("동일 프레임일 때 디자인시스템 영역 우선권 검증")
    func testDesignSystemRegionWinsForSameFrame() {
        let frame = CGRect(x: 10, y: 20, width: 100, height: 40)
        let result = DSLayoutRegionMerger.merge(
            automaticRegions: [region(regionID: "view", frame: frame, source: .view)],
            reportedRegions: [region(regionID: "button", frame: frame, source: .designSystem)],
            displayScale: 3
        )

        #expect(result.map(\.regionID) == ["button"])
    }

    @Test("디테일 영역은 항상 표시됨을 검증")
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

        #expect(result.map(\.regionID) == ["button", "title"])
    }

    @Test("타이포그래피 라인 박스가 접근성 영역을 대체하는지 검증")
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

        #expect(result.map(\.regionID) == ["typography"])
    }

    @Test("타이포그래피 영역 내 좁은 자식 영역 보존 검증")
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

        #expect(result.map(\.regionID) == ["typography", "child"])
    }

    @Test("디스플레이 스케일에 따른 픽셀 양자화 검증")
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

        #expect(result.count == 2)
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
