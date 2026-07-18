#if DEBUG
import CoreGraphics

enum DSLayoutRegionMerger {
    static func merge(
        automaticRegions: [DSLayoutRegion],
        reportedRegions: [DSLayoutRegion],
        displayScale: CGFloat
    ) -> [DSLayoutRegion] {
        let remainingAutomaticRegions = deduplicateAutomatic(
            automaticRegions,
            displayScale: displayScale
        ).filter { automaticRegion in
            !reportedRegions.contains { reportedRegion in
                suppresses(
                    automaticRegion: automaticRegion,
                    with: reportedRegion,
                    displayScale: displayScale
                )
            }
        }

        return reportedRegions + remainingAutomaticRegions
    }

    static func deduplicateAutomatic(
        _ regions: [DSLayoutRegion],
        displayScale: CGFloat
    ) -> [DSLayoutRegion] {
        let sortedRegions = regions.sorted { firstRegion, secondRegion in
            if firstRegion.source != secondRegion.source {
                return firstRegion.source.selectionPriority
                    > secondRegion.source.selectionPriority
            }
            return firstRegion.depth > secondRegion.depth
        }

        var frameKeys = Set<String>()
        return sortedRegions.filter { region in
            frameKeys.insert(
                frameKey(region.frame, displayScale: displayScale)
            ).inserted
        }
    }

    private static func suppresses(
        automaticRegion: DSLayoutRegion,
        with reportedRegion: DSLayoutRegion,
        displayScale: CGFloat
    ) -> Bool {
        if frameKey(
            automaticRegion.frame,
            displayScale: displayScale
        ) == frameKey(
            reportedRegion.frame,
            displayScale: displayScale
        ) {
            return true
        }

        guard reportedRegion.suppressesContainedAutomaticRegions else {
            return false
        }

        let tolerance = 2 / max(displayScale, 1)
        let reportedFrame = reportedRegion.frame
        let automaticFrame = automaticRegion.frame
        let expandedReportedFrame = reportedFrame.insetBy(
            dx: -tolerance,
            dy: -tolerance
        )

        return expandedReportedFrame.contains(automaticFrame)
            && abs(reportedFrame.midX - automaticFrame.midX) <= tolerance
            && abs(reportedFrame.width - automaticFrame.width) <= tolerance * 2
    }

    private static func frameKey(
        _ frame: CGRect,
        displayScale: CGFloat
    ) -> String {
        let scale = max(displayScale, 1)
        return [frame.minX, frame.minY, frame.width, frame.height]
            .map { String(Int(($0 * scale).rounded())) }
            .joined(separator: ":")
    }
}
#endif
