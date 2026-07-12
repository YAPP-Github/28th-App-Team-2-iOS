import UIKit
import SwiftUI
import DesignSystem

// MARK: - 디자인 QA용 예제 앱 전용 디버그 확장 (프로덕션 SDK 오염 방지 격리 수용)

extension DSButtonVariant {
    func specBgColorName(isEnabled: Bool) -> String {
        let asset = bgAsset(isEnabled: isEnabled)
        return "\(asset.displayName) (\(asset.color.hexString))"
    }
    
    func specTextColorName(isEnabled: Bool) -> String {
        let asset = textAsset(isEnabled: isEnabled)
        return "\(asset.displayName) (\(asset.color.hexString))"
    }
}

extension DSButtonSize {
    func specFontName(isEnabled: Bool) -> String {
        fontStyle(isEnabled: isEnabled).specName
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
            category = "Heading" + (num.first.map(String.init) ?? "")
        } else if caseName.hasPrefix("body") {
            let num = caseName.replacingOccurrences(of: "body", with: "")
            category = "Body" + (num.first.map(String.init) ?? "")
        } else if caseName.hasPrefix("caption") {
            let num = caseName.replacingOccurrences(of: "caption", with: "")
            category = "Caption" + (num.first.map(String.init) ?? "")
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
}

extension UIColor {
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        } else {
            var white: CGFloat = 0
            if self.getWhite(&white, alpha: &a) {
                let val = Int(white * 255)
                return String(format: "#%02X%02X%02X", val, val, val)
            }
        }
        return "#FFFFFF"
    }
}

