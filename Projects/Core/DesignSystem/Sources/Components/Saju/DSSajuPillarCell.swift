import SwiftUI

public enum DSSajuElement: String, Sendable, Equatable, Hashable, Codable {
    case wood = "WOOD"
    case fire = "FIRE"
    case earth = "EARTH"
    case metal = "METAL"
    case water = "WATER"
    case unknown

    public var label: String {
        switch self {
        case .wood: "목"
        case .fire: "화"
        case .earth: "토"
        case .metal: "금"
        case .water: "수"
        case .unknown: "-"
        }
    }

    public var hanja: String {
        switch self {
        case .wood: "木"
        case .fire: "火"
        case .earth: "土"
        case .metal: "金"
        case .water: "水"
        case .unknown: "-"
        }
    }

    public var backgroundAsset: DesignSystemColors {
        switch self {
        case .wood: DesignSystemAsset.Colors.teal200
        case .fire: DesignSystemAsset.Colors.red200
        case .earth: DesignSystemAsset.Colors.orange200
        case .metal: DesignSystemAsset.Colors.coolGray300
        case .water: DesignSystemAsset.Colors.sky200
        case .unknown: DesignSystemAsset.Colors.gray100
        }
    }

    public static func from(hanja: String) -> DSSajuElement {
        switch hanja {
        case "甲", "乙", "寅", "卯": .wood
        case "丙", "丁", "巳", "午": .fire
        case "戊", "己", "辰", "戌", "丑", "未": .earth
        case "庚", "辛", "申", "酉": .metal
        case "壬", "癸", "亥", "子": .water
        default: .unknown
        }
    }

    public static func from(text: String) -> DSSajuElement {
        let upper = text.uppercased()
        if upper.contains("WOOD") || upper.contains("MOK") || upper.contains("목") || upper.contains("木") { return .wood }
        if upper.contains("FIRE") || upper.contains("HWA") || upper.contains("화") || upper.contains("火") { return .fire }
        if upper.contains("EARTH") || upper.contains("TO") || upper.contains("토") || upper.contains("土") { return .earth }
        if upper.contains("METAL") || upper.contains("GEUM") || upper.contains("금") || upper.contains("金") { return .metal }
        if upper.contains("WATER") || upper.contains("SU") || upper.contains("수") || upper.contains("水") { return .water }
        return .unknown
    }
}

public struct DSSajuPillarCell: View {
    public struct Specification: Sendable {
        public let size: CGFloat
        public let shape: DSComponentShape
        public let backgroundAsset: DesignSystemColors
        public let foregroundAsset: DesignSystemColors
    }

    public static func specification(element: DSSajuElement) -> Specification {
        Specification(
            size: 48,
            shape: .roundedRectangle(cornerRadius: 12),
            backgroundAsset: element.backgroundAsset,
            foregroundAsset: DesignSystemAsset.Colors.gray975
        )
    }

    private let hanja: String
    private let sublabel: String
    private let element: DSSajuElement

    public static func yinYangSign(for hanja: String) -> String {
        switch hanja {
        case "甲", "丙", "戊", "庚", "壬", "子", "寅", "辰", "午", "申", "戌":
            return "+"
        case "乙", "丁", "己", "辛", "癸", "丑", "卯", "巳", "未", "酉", "亥":
            return "-"
        default:
            return "-"
        }
    }

    public init(
        hanja: String,
        reading: String,
        element: DSSajuElement? = nil,
        showElementHanja: Bool = true
    ) {
        self.hanja = hanja
        let resolvedElement = element ?? DSSajuElement.from(hanja: hanja)
        self.element = resolvedElement
        let sign = Self.yinYangSign(for: hanja)
        let cleanedReading = reading.trimmingCharacters(in: CharacterSet(charactersIn: "+- "))
        if showElementHanja && resolvedElement != .unknown {
            self.sublabel = "\(sign)\(cleanedReading), \(resolvedElement.hanja)"
        } else {
            self.sublabel = "\(sign)\(cleanedReading)"
        }
    }

    public init(
        hanja: String,
        sublabel: String,
        element: DSSajuElement
    ) {
        self.hanja = hanja
        self.sublabel = sublabel
        self.element = element
    }

    public var body: some View {
        let spec = Self.specification(element: element)

        VStack(spacing: 2) {
            Text(hanja)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(spec.foregroundAsset.swiftUIColor)
            Text(sublabel)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(spec.foregroundAsset.swiftUIColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(width: spec.size, height: spec.size)
        .background(spec.backgroundAsset.swiftUIColor)
        .clipShape(spec.shape.swiftUIShape)
        .dsDebugGeometry("DSSajuPillarCell")
    }
}
