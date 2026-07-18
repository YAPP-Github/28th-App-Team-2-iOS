#if DEBUG
import CoreGraphics

enum DSLayoutRegionMerger {
    static func merge(
        automaticRegions: [DSLayoutRegion],
        reportedRegions: [DSLayoutRegion],
        displayScale: CGFloat
    ) -> [DSLayoutRegion] {
        // UIKit·접근성에서 자동 수집한 영역은 넓고 일반적인 경우가 많다. 반면
        // DesignSystem이 직접 보고한 geometry는 컴포넌트의 의도적인 외곽·line box다.
        // 같은 영역은 DS 정보를 우선해 이름과 측정 기준이 더 정확하게 보이게 한다.
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
        // 같은 프레임은 selection priority(DS > 접근성 > UIView), 그 다음 깊이 순으로
        // 하나만 남긴다. display scale 단위로 정규화해 부동소수점 오차 때문에 같은
        // 화면 영역이 중복되는 일을 막는다.
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
        // 정확히 같은 프레임은 항상 중복 영역이다. Typography는 실제 line box가
        // 접근성 bounds보다 좁을 수 있어, 아래의 포함 관계 규칙으로만 자동 영역을
        // 추가 제거한다.
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

        // 한 physical pixel 안팎의 차이는 SwiftUI·UIKit 좌표 변환 과정의 반올림으로
        // 본다. 가운데와 폭도 비슷할 때만 같은 텍스트 계열 영역으로 간주해, 실제
        // 자식 View를 실수로 숨기지 않는다.
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
