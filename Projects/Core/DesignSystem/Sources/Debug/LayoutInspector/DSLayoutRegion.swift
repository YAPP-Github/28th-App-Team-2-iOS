#if DEBUG
import CoreGraphics

enum DSLayoutRegionSource: String {
    case view = "View"
    case accessibility = "접근성 요소"
    case designSystem = "DesignSystem"
    case designSystemDetail = "DesignSystem 세부"

    var selectionPriority: Int {
        switch self {
        case .view:
            0
        case .accessibility:
            1
        case .designSystem:
            2
        case .designSystemDetail:
            3
        }
    }
}

struct DSLayoutRegion: Equatable {
    let regionID: String
    let name: String
    let frame: CGRect
    let depth: Int
    let source: DSLayoutRegionSource
    let suppressesContainedAutomaticRegions: Bool

    init(
        regionID: String,
        name: String,
        frame: CGRect,
        depth: Int,
        source: DSLayoutRegionSource,
        suppressesContainedAutomaticRegions: Bool = false
    ) {
        self.regionID = regionID
        self.name = name
        self.frame = frame
        self.depth = depth
        self.source = source
        self.suppressesContainedAutomaticRegions = suppressesContainedAutomaticRegions
    }
}

enum DSLayoutInspectorConstants {
    static let accessibilityPrefix = "DSLayoutInspector"
}
#endif
