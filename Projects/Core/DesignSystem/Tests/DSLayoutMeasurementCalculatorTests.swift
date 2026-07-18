#if DEBUG
import XCTest
@testable import DesignSystem

final class DSLayoutMeasurementCalculatorTests: XCTestCase {
    func testHorizontalGap() throws {
        let measurements = DSLayoutMeasurementCalculator.measurements(
            between: CGRect(x: 0, y: 10, width: 20, height: 20),
            and: CGRect(x: 36, y: 14, width: 20, height: 12)
        )

        let measurement = try XCTUnwrap(measurements.first)
        XCTAssertEqual(measurements.count, 1)
        XCTAssertEqual(measurement.axis, .horizontal)
        XCTAssertEqual(measurement.distance, 16)
        XCTAssertEqual(measurement.start, CGPoint(x: 20, y: 20))
        XCTAssertEqual(measurement.end, CGPoint(x: 36, y: 20))
    }

    func testHorizontalGapIsOrderIndependent() {
        let firstFrame = CGRect(x: 0, y: 10, width: 20, height: 20)
        let secondFrame = CGRect(x: 36, y: 14, width: 20, height: 12)

        XCTAssertEqual(
            DSLayoutMeasurementCalculator.measurements(
                between: firstFrame,
                and: secondFrame
            ),
            DSLayoutMeasurementCalculator.measurements(
                between: secondFrame,
                and: firstFrame
            )
        )
    }

    func testVerticalGap() throws {
        let measurements = DSLayoutMeasurementCalculator.measurements(
            between: CGRect(x: 10, y: 0, width: 20, height: 20),
            and: CGRect(x: 14, y: 36, width: 12, height: 20)
        )

        let measurement = try XCTUnwrap(measurements.first)
        XCTAssertEqual(measurements.count, 1)
        XCTAssertEqual(measurement.axis, .vertical)
        XCTAssertEqual(measurement.distance, 16)
        XCTAssertEqual(measurement.start, CGPoint(x: 20, y: 20))
        XCTAssertEqual(measurement.end, CGPoint(x: 20, y: 36))
    }

    func testContainedFramesProduceInsets() {
        let measurements = DSLayoutMeasurementCalculator.measurements(
            between: CGRect(x: 0, y: 0, width: 100, height: 100),
            and: CGRect(x: 16, y: 12, width: 64, height: 72)
        )

        XCTAssertEqual(measurements.map(\.distance), [16, 20, 12, 16])
    }

    func testOverlappingAndDiagonalFramesHaveNoGap() {
        let overlapping = DSLayoutMeasurementCalculator.measurements(
            between: CGRect(x: 0, y: 0, width: 20, height: 20),
            and: CGRect(x: 10, y: 10, width: 20, height: 20)
        )
        let diagonal = DSLayoutMeasurementCalculator.measurements(
            between: CGRect(x: 0, y: 0, width: 20, height: 20),
            and: CGRect(x: 30, y: 30, width: 20, height: 20)
        )

        XCTAssertTrue(overlapping.isEmpty)
        XCTAssertTrue(diagonal.isEmpty)
    }

    func testManualRulerMeasuresBothAxes() {
        let measurements = DSLayoutMeasurementCalculator.manualMeasurements(
            from: CGPoint(x: 10, y: 20),
            to: CGPoint(x: 42, y: 36)
        )

        XCTAssertEqual(measurements.map(\.axis), [.horizontal, .vertical])
        XCTAssertEqual(measurements.map(\.distance), [32, 16])
    }

    func testRulerTapsCompleteMeasurementAndThirdTapRestarts() {
        let firstPoint = CGPoint(x: 10, y: 20)
        let secondPoint = CGPoint(x: 42, y: 36)
        let thirdPoint = CGPoint(x: 100, y: 120)

        let afterFirstTap = DSLayoutRulerPoints.empty.afterTapping(firstPoint)
        let afterSecondTap = afterFirstTap.afterTapping(secondPoint)
        let afterThirdTap = afterSecondTap.afterTapping(thirdPoint)

        XCTAssertEqual(afterFirstTap, DSLayoutRulerPoints(start: firstPoint, end: nil))
        XCTAssertEqual(afterSecondTap, DSLayoutRulerPoints(start: firstPoint, end: secondPoint))
        XCTAssertEqual(afterThirdTap, DSLayoutRulerPoints(start: thirdPoint, end: nil))
    }

    func testRulerDragReplacesPreviousMeasurement() {
        let previous = DSLayoutRulerPoints(
            start: CGPoint(x: 10, y: 20),
            end: CGPoint(x: 42, y: 36)
        )
        let replacement = DSLayoutRulerPoints.drag(
            from: CGPoint(x: 50, y: 60),
            to: CGPoint(x: 90, y: 120)
        )

        XCTAssertNotEqual(previous, replacement)
        XCTAssertEqual(replacement.start, CGPoint(x: 50, y: 60))
        XCTAssertEqual(replacement.end, CGPoint(x: 90, y: 120))
    }

    func testRulerDistinguishesTapAndDragByDistance() {
        XCTAssertFalse(
            DSLayoutRulerPoints.isDrag(
                translation: CGSize(width: 2, height: 3)
            )
        )
        XCTAssertTrue(
            DSLayoutRulerPoints.isDrag(
                translation: CGSize(width: 4, height: 0)
            )
        )
    }
}
#endif
