#if DEBUG
import CoreGraphics

enum DSLayoutMeasurementAxis: String {
    case horizontal
    case vertical
}

struct DSLayoutMeasurement: Equatable {
    let axis: DSLayoutMeasurementAxis
    let start: CGPoint
    let end: CGPoint
    let distance: CGFloat

    var measurementID: String {
        "\(axis.rawValue)-\(start.x)-\(start.y)-\(end.x)-\(end.y)"
    }
}

struct DSLayoutRulerPoints: Equatable {
    let start: CGPoint?
    let end: CGPoint?

    static let empty = DSLayoutRulerPoints(start: nil, end: nil)
    static let tapMovementTolerance: CGFloat = 4

    func afterTapping(_ point: CGPoint) -> DSLayoutRulerPoints {
        guard let start else {
            return DSLayoutRulerPoints(start: point, end: nil)
        }

        guard end == nil else {
            return DSLayoutRulerPoints(start: point, end: nil)
        }

        return DSLayoutRulerPoints(start: start, end: point)
    }

    static func drag(
        from start: CGPoint,
        to end: CGPoint
    ) -> DSLayoutRulerPoints {
        DSLayoutRulerPoints(start: start, end: end)
    }

    static func isDrag(translation: CGSize) -> Bool {
        hypot(translation.width, translation.height) >= tapMovementTolerance
    }
}

enum DSLayoutMeasurementCalculator {
    static func measurements(
        between firstFrame: CGRect,
        and secondFrame: CGRect
    ) -> [DSLayoutMeasurement] {
        guard firstFrame != secondFrame,
              !firstFrame.isEmpty,
              !secondFrame.isEmpty else {
            return []
        }

        if firstFrame.contains(secondFrame) {
            return insetMeasurements(container: firstFrame, content: secondFrame)
        }

        if secondFrame.contains(firstFrame) {
            return insetMeasurements(container: secondFrame, content: firstFrame)
        }

        let verticalOverlap = overlap(
            firstFrame.minY ... firstFrame.maxY,
            secondFrame.minY ... secondFrame.maxY
        )
        let horizontalOverlap = overlap(
            firstFrame.minX ... firstFrame.maxX,
            secondFrame.minX ... secondFrame.maxX
        )

        if let verticalOverlap,
           firstFrame.maxX <= secondFrame.minX || secondFrame.maxX <= firstFrame.minX {
            let leftFrame = firstFrame.minX < secondFrame.minX ? firstFrame : secondFrame
            let rightFrame = leftFrame == firstFrame ? secondFrame : firstFrame
            let lineY = verticalOverlap.lowerBound + verticalOverlap.length / 2

            return [
                measurement(
                    axis: .horizontal,
                    start: CGPoint(x: leftFrame.maxX, y: lineY),
                    end: CGPoint(x: rightFrame.minX, y: lineY)
                )
            ]
        }

        if let horizontalOverlap,
           firstFrame.maxY <= secondFrame.minY || secondFrame.maxY <= firstFrame.minY {
            let topFrame = firstFrame.minY < secondFrame.minY ? firstFrame : secondFrame
            let bottomFrame = topFrame == firstFrame ? secondFrame : firstFrame
            let lineX = horizontalOverlap.lowerBound + horizontalOverlap.length / 2

            return [
                measurement(
                    axis: .vertical,
                    start: CGPoint(x: lineX, y: topFrame.maxY),
                    end: CGPoint(x: lineX, y: bottomFrame.minY)
                )
            ]
        }

        return []
    }

    static func manualMeasurements(
        from start: CGPoint,
        to end: CGPoint
    ) -> [DSLayoutMeasurement] {
        let corner = CGPoint(x: end.x, y: start.y)
        var measurements: [DSLayoutMeasurement] = []

        if abs(end.x - start.x) >= 0.5 {
            measurements.append(
                measurement(axis: .horizontal, start: start, end: corner)
            )
        }

        if abs(end.y - start.y) >= 0.5 {
            measurements.append(
                measurement(axis: .vertical, start: corner, end: end)
            )
        }

        return measurements
    }

    static func region(
        at point: CGPoint,
        in regions: [DSLayoutRegion]
    ) -> DSLayoutRegion? {
        regions
            .filter { $0.frame.contains(point) }
            .sorted { firstRegion, secondRegion in
                let firstArea = firstRegion.frame.width * firstRegion.frame.height
                let secondArea = secondRegion.frame.width * secondRegion.frame.height

                if firstArea == secondArea {
                    if firstRegion.source != secondRegion.source {
                        return firstRegion.source.selectionPriority
                            > secondRegion.source.selectionPriority
                    }
                    return firstRegion.depth > secondRegion.depth
                }
                return firstArea < secondArea
            }
            .first
    }

    static func inspectionSelectionIDs(
        afterSelecting regionID: String,
        currentSelection: [String]
    ) -> [String] {
        currentSelection == [regionID] ? [] : [regionID]
    }

    static func spacingSelectionIDs(
        afterSelecting regionID: String,
        currentSelection: [String]
    ) -> [String] {
        if currentSelection.contains(regionID) {
            return currentSelection.filter { $0 != regionID }
        }

        if currentSelection.count >= 2 {
            return [regionID]
        }

        return currentSelection + [regionID]
    }

    private static func insetMeasurements(
        container: CGRect,
        content: CGRect
    ) -> [DSLayoutMeasurement] {
        [
            measurement(
                axis: .horizontal,
                start: CGPoint(x: container.minX, y: content.midY),
                end: CGPoint(x: content.minX, y: content.midY)
            ),
            measurement(
                axis: .horizontal,
                start: CGPoint(x: content.maxX, y: content.midY),
                end: CGPoint(x: container.maxX, y: content.midY)
            ),
            measurement(
                axis: .vertical,
                start: CGPoint(x: content.midX, y: container.minY),
                end: CGPoint(x: content.midX, y: content.minY)
            ),
            measurement(
                axis: .vertical,
                start: CGPoint(x: content.midX, y: content.maxY),
                end: CGPoint(x: content.midX, y: container.maxY)
            )
        ]
    }

    private static func measurement(
        axis: DSLayoutMeasurementAxis,
        start: CGPoint,
        end: CGPoint
    ) -> DSLayoutMeasurement {
        let distance: CGFloat = switch axis {
        case .horizontal:
            abs(end.x - start.x)
        case .vertical:
            abs(end.y - start.y)
        }

        return DSLayoutMeasurement(
            axis: axis,
            start: start,
            end: end,
            distance: distance
        )
    }

    private static func overlap(
        _ firstRange: ClosedRange<CGFloat>,
        _ secondRange: ClosedRange<CGFloat>
    ) -> ClosedRange<CGFloat>? {
        let lowerBound = max(firstRange.lowerBound, secondRange.lowerBound)
        let upperBound = min(firstRange.upperBound, secondRange.upperBound)
        return lowerBound < upperBound ? lowerBound ... upperBound : nil
    }
}

private extension ClosedRange where Bound == CGFloat {
    var length: CGFloat {
        upperBound - lowerBound
    }
}
#endif
