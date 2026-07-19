#if DEBUG
import Testing
@testable import DesignSystem
import CoreGraphics
import Foundation

struct DSLayoutMeasurementCalculatorTests {
    @Test("수평 간격 측정 검증")
    func testHorizontalGap() throws {
        let measurements = DSLayoutMeasurementCalculator.measurements(
            between: CGRect(x: 0, y: 10, width: 20, height: 20),
            and: CGRect(x: 36, y: 14, width: 20, height: 12)
        )

        let measurement = try #require(measurements.first)
        #expect(measurements.count == 1)
        #expect(measurement.axis == .horizontal)
        #expect(measurement.distance == 16)
        #expect(measurement.start == CGPoint(x: 20, y: 20))
        #expect(measurement.end == CGPoint(x: 36, y: 20))
    }

    @Test("수평 간격 측정 시 순서 독립성 검증")
    func testHorizontalGapIsOrderIndependent() {
        let firstFrame = CGRect(x: 0, y: 10, width: 20, height: 20)
        let secondFrame = CGRect(x: 36, y: 14, width: 20, height: 12)

        #expect(
            DSLayoutMeasurementCalculator.measurements(
                between: firstFrame,
                and: secondFrame
            ) ==
            DSLayoutMeasurementCalculator.measurements(
                between: secondFrame,
                and: firstFrame
            )
        )
    }

    @Test("수직 간격 측정 검증")
    func testVerticalGap() throws {
        let measurements = DSLayoutMeasurementCalculator.measurements(
            between: CGRect(x: 10, y: 0, width: 20, height: 20),
            and: CGRect(x: 14, y: 36, width: 12, height: 20)
        )

        let measurement = try #require(measurements.first)
        #expect(measurements.count == 1)
        #expect(measurement.axis == .vertical)
        #expect(measurement.distance == 16)
        #expect(measurement.start == CGPoint(x: 20, y: 20))
        #expect(measurement.end == CGPoint(x: 20, y: 36))
    }

    @Test("내포된 프레임 간의 인셋 측정 검증")
    func testContainedFramesProduceInsets() {
        let measurements = DSLayoutMeasurementCalculator.measurements(
            between: CGRect(x: 0, y: 0, width: 100, height: 100),
            and: CGRect(x: 16, y: 12, width: 64, height: 72)
        )

        #expect(measurements.map(\.distance) == [16, 20, 12, 16])
    }

    @Test("겹치거나 대각선에 위치한 프레임 간격 없음 검증")
    func testOverlappingAndDiagonalFramesHaveNoGap() {
        let overlapping = DSLayoutMeasurementCalculator.measurements(
            between: CGRect(x: 0, y: 0, width: 20, height: 20),
            and: CGRect(x: 10, y: 10, width: 20, height: 20)
        )
        let diagonal = DSLayoutMeasurementCalculator.measurements(
            between: CGRect(x: 0, y: 0, width: 20, height: 20),
            and: CGRect(x: 30, y: 30, width: 20, height: 20)
        )

        #expect(overlapping.isEmpty)
        #expect(diagonal.isEmpty)
    }

    @Test("수동 자(Ruler)의 양방향 축 측정 검증")
    func testManualRulerMeasuresBothAxes() {
        let measurements = DSLayoutMeasurementCalculator.manualMeasurements(
            from: CGPoint(x: 10, y: 20),
            to: CGPoint(x: 42, y: 36)
        )

        #expect(measurements.map(\.axis) == [.horizontal, .vertical])
        #expect(measurements.map(\.distance) == [32, 16])
    }

    @Test("자(Ruler) 탭 인터랙션에 따른 측정 완료 및 재시작 검증")
    func testRulerTapsCompleteMeasurementAndThirdTapRestarts() {
        let firstPoint = CGPoint(x: 10, y: 20)
        let secondPoint = CGPoint(x: 42, y: 36)
        let thirdPoint = CGPoint(x: 100, y: 120)

        let afterFirstTap = DSLayoutRulerPoints.empty.afterTapping(firstPoint)
        let afterSecondTap = afterFirstTap.afterTapping(secondPoint)
        let afterThirdTap = afterSecondTap.afterTapping(thirdPoint)

        #expect(afterFirstTap == DSLayoutRulerPoints(start: firstPoint, end: nil))
        #expect(afterSecondTap == DSLayoutRulerPoints(start: firstPoint, end: secondPoint))
        #expect(afterThirdTap == DSLayoutRulerPoints(start: thirdPoint, end: nil))
    }

    @Test("자(Ruler) 드래그 시 기존 측정값 대체 검증")
    func testRulerDragReplacesPreviousMeasurement() {
        let previous = DSLayoutRulerPoints(
            start: CGPoint(x: 10, y: 20),
            end: CGPoint(x: 42, y: 36)
        )
        let replacement = DSLayoutRulerPoints.drag(
            from: CGPoint(x: 50, y: 60),
            to: CGPoint(x: 90, y: 120)
        )

        #expect(previous != replacement)
        #expect(replacement.start == CGPoint(x: 50, y: 60))
        #expect(replacement.end == CGPoint(x: 90, y: 120))
    }

    @Test("이동 거리에 따른 자(Ruler)의 탭/드래그 구분 검증")
    func testRulerDistinguishesTapAndDragByDistance() {
        #expect(
            !DSLayoutRulerPoints.isDrag(
                translation: CGSize(width: 2, height: 3)
            )
        )
        #expect(
            DSLayoutRulerPoints.isDrag(
                translation: CGSize(width: 4, height: 0)
            )
        )
    }
}
#endif
