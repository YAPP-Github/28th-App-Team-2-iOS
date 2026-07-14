import UIKit
import SwiftUI
import DesignSystem

extension CGFloat {
    var ptDescription: String {
        "\(Int(self))pt"
    }

    var squarePtDescription: String {
        "\(ptDescription) × \(ptDescription)"
    }
}

extension DSComponentShape {
    var specName: String {
        switch self {
        case let .roundedRectangle(cornerRadius):
            "Rounded Rectangle (\(cornerRadius.ptDescription))"
        case .capsule:
            "Capsule"
        }
    }
}

extension FontStyle {
    var weightName: String {
        switch self {
        case .heading1ExtraBold, .heading2ExtraBold: return "ExtraBold"
        case .heading1Bold, .heading2Bold, .heading3Bold, .heading4Bold, .body1Bold: return "Bold"
        case .heading1SemiBold, .heading2SemiBold, .body2SemiBold, .body3SemiBold, .caption1SemiBold, .caption2SemiBold, .caption3SemiBold: return "Semibold"
        case .heading3Medium, .heading4Medium, .body1Medium, .body2Medium, .body3Medium, .caption1Medium, .caption2Medium, .caption3Medium: return "Medium"
        case .heading3Regular, .heading4Regular, .body1Regular, .body2Regular, .body3Regular, .caption1Regular, .caption2Regular, .caption3Regular: return "Regular"
        }
    }
    
    var specName: String {
        let caseName = String(describing: self)
        let category: String
        
        if caseName.hasPrefix("heading") {
            let num = caseName.replacingOccurrences(of: "heading", with: "")
            category = "Heading" + String(num.prefix(while: \.isNumber))
        } else if caseName.hasPrefix("body") {
            let num = caseName.replacingOccurrences(of: "body", with: "")
            category = "Body" + String(num.prefix(while: \.isNumber))
        } else if caseName.hasPrefix("caption") {
            let num = caseName.replacingOccurrences(of: "caption", with: "")
            category = "Caption" + String(num.prefix(while: \.isNumber))
        } else {
            category = "Font"
        }
        
        return "\(category)/\(weightName) (\(Int(size))pt)"
    }
}

extension DesignSystemColors {
    var displayName: String {
        name.replacingOccurrences(of: "Colors/", with: "")
    }

    var specDescription: String {
        "\(displayName) (\(color.hexString))"
    }
}

extension DesignSystemImages {
    var displayName: String {
        let rawName = name.replacingOccurrences(of: "Icons/", with: "")
        let parts = rawName.split(separator: "_")
        guard parts.count > 1 else { return rawName }
        let first = String(parts[0])
        let rest = parts.dropFirst().map { $0.capitalized }.joined()
        return first + rest
    }
}

extension UIColor {
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return String(
                format: "#%02X%02X%02X",
                Int((r * 255).rounded()),
                Int((g * 255).rounded()),
                Int((b * 255).rounded())
            )
        } else {
            var white: CGFloat = 0
            if self.getWhite(&white, alpha: &a) {
                let val = Int((white * 255).rounded())
                return String(format: "#%02X%02X%02X", val, val, val)
            }
        }
        return "Unavailable"
    }
}
