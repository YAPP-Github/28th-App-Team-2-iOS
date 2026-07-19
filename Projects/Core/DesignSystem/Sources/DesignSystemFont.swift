import SwiftUI
import UIKit

public enum FontStyle: Equatable, Sendable {
    // Heading
    case heading1ExtraBold, heading1Bold, heading1SemiBold
    case heading2ExtraBold, heading2Bold, heading2SemiBold
    case heading3Bold, heading3Medium, heading3Regular
    case heading4Bold, heading4Medium, heading4Regular

    // Body
    case body1Bold, body1Medium, body1Regular
    case body2SemiBold, body2Medium, body2Regular
    case body3SemiBold, body3Medium, body3Regular

    // Caption
    case caption1SemiBold, caption1Medium, caption1Regular
    case caption2SemiBold, caption2Medium, caption2Regular
    case caption3SemiBold, caption3Medium, caption3Regular

    public var size: CGFloat {
        switch self {
        case .heading1ExtraBold, .heading1Bold, .heading1SemiBold: return 32
        case .heading2ExtraBold, .heading2Bold, .heading2SemiBold: return 28
        case .heading3Bold, .heading3Medium, .heading3Regular: return 24
        case .heading4Bold, .heading4Medium, .heading4Regular: return 22
        case .body1Bold, .body1Medium, .body1Regular: return 18
        case .body2SemiBold, .body2Medium, .body2Regular: return 16
        case .body3SemiBold, .body3Medium, .body3Regular: return 14
        case .caption1SemiBold, .caption1Medium, .caption1Regular: return 12
        case .caption2SemiBold, .caption2Medium, .caption2Regular: return 11
        case .caption3SemiBold, .caption3Medium, .caption3Regular: return 10
        }
    }

    public var lineHeight: CGFloat {
        switch self {
        case .heading1ExtraBold, .heading1Bold, .heading1SemiBold: return 44
        case .heading2ExtraBold, .heading2Bold, .heading2SemiBold: return 38
        case .heading3Bold, .heading3Medium, .heading3Regular: return 32
        case .heading4Bold, .heading4Medium, .heading4Regular: return 30
        case .body1Bold, .body1Medium, .body1Regular: return 26
        case .body2SemiBold, .body2Medium, .body2Regular: return 24
        case .body3SemiBold, .body3Medium, .body3Regular: return 20
        case .caption1SemiBold, .caption1Medium, .caption1Regular: return 16
        case .caption2SemiBold, .caption2Medium, .caption2Regular: return 14
        case .caption3SemiBold, .caption3Medium, .caption3Regular: return 13
        }
    }

    // Tuist 자동 생성 accessor를 통해 번들 내 폰트 파일과 타입세이프하게 연결
    var fontConvertible: DesignSystemFontConvertible {
        switch self {
        case .heading1ExtraBold, .heading2ExtraBold:
            return DesignSystemFontFamily.Pretendard.extraBold
        case .heading1Bold, .heading2Bold, .heading3Bold, .heading4Bold, .body1Bold:
            return DesignSystemFontFamily.Pretendard.bold
        case .heading1SemiBold, .heading2SemiBold, .body2SemiBold, .body3SemiBold,
             .caption1SemiBold, .caption2SemiBold, .caption3SemiBold:
            return DesignSystemFontFamily.Pretendard.semiBold
        case .heading3Medium, .heading4Medium, .body1Medium, .body2Medium,
             .body3Medium, .caption1Medium, .caption2Medium, .caption3Medium:
            return DesignSystemFontFamily.Pretendard.medium
        case .heading3Regular, .heading4Regular, .body1Regular, .body2Regular,
             .body3Regular, .caption1Regular, .caption2Regular, .caption3Regular:
            return DesignSystemFontFamily.Pretendard.regular
        }
    }
}

public extension Font {
    static let ds = DesignSystemFont.self
}

public struct DesignSystemFont {
    public static func font(_ style: FontStyle) -> Font {
        // swiftUIFont() 내부에서 폰트 등록 여부를 자동 체크하고 필요시에만 등록 수행
        return style.fontConvertible.swiftUIFont(size: style.size)
    }
}

// MARK: - Fixed Line Height ViewModifier

struct DSLineHeightModifier: ViewModifier {
    let fontSize: CGFloat
    let lineHeight: CGFloat
    let fontConvertible: DesignSystemFontConvertible

    func body(content: Content) -> some View {
        let uiFont = UIFont(font: fontConvertible, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let spacing = lineHeight - uiFont.lineHeight

        return content
            .lineSpacing(spacing)
            .padding(.vertical, spacing / 2)
    }
}

// internal extension으로 분리하여 외부 모듈 노출 차단 (캡슐화)
extension View {
    // 공통 폰트 지정 기반 뷰 모디파이어
    func dsFont(_ style: FontStyle) -> some View {
        dsStyledFont(style)
            .dsDebugTypographyGeometry("Typography.\(String(describing: style))")
    }

    private func dsStyledFont(_ style: FontStyle) -> some View {
        self
            .font(.ds.font(style))
            .modifier(
                DSLineHeightModifier(
                    fontSize: style.size,
                    lineHeight: style.lineHeight,
                    fontConvertible: style.fontConvertible
                )
            )
    }
}

// MARK: - 타입세이프 30개 개별 호출 뷰 확장 (괄호 없이 연산 프로퍼티 var로 바로 체이닝)
public extension View {
    // Headings
    var dsHeading1ExtraBold: some View { self.dsFont(.heading1ExtraBold) }
    var dsHeading1Bold: some View { self.dsFont(.heading1Bold) }
    var dsHeading1SemiBold: some View { self.dsFont(.heading1SemiBold) }

    var dsHeading2ExtraBold: some View { self.dsFont(.heading2ExtraBold) }
    var dsHeading2Bold: some View { self.dsFont(.heading2Bold) }
    var dsHeading2SemiBold: some View { self.dsFont(.heading2SemiBold) }

    var dsHeading3Bold: some View { self.dsFont(.heading3Bold) }
    var dsHeading3Medium: some View { self.dsFont(.heading3Medium) }
    var dsHeading3Regular: some View { self.dsFont(.heading3Regular) }

    var dsHeading4Bold: some View { self.dsFont(.heading4Bold) }
    var dsHeading4Medium: some View { self.dsFont(.heading4Medium) }
    var dsHeading4Regular: some View { self.dsFont(.heading4Regular) }

    // Bodies
    var dsBody1Bold: some View { self.dsFont(.body1Bold) }
    var dsBody1Medium: some View { self.dsFont(.body1Medium) }
    var dsBody1Regular: some View { self.dsFont(.body1Regular) }

    var dsBody2SemiBold: some View { self.dsFont(.body2SemiBold) }
    var dsBody2Medium: some View { self.dsFont(.body2Medium) }
    var dsBody2Regular: some View { self.dsFont(.body2Regular) }

    var dsBody3SemiBold: some View { self.dsFont(.body3SemiBold) }
    var dsBody3Medium: some View { self.dsFont(.body3Medium) }
    var dsBody3Regular: some View { self.dsFont(.body3Regular) }

    // Captions
    var dsCaption1SemiBold: some View { self.dsFont(.caption1SemiBold) }
    var dsCaption1Medium: some View { self.dsFont(.caption1Medium) }
    var dsCaption1Regular: some View { self.dsFont(.caption1Regular) }

    var dsCaption2SemiBold: some View { self.dsFont(.caption2SemiBold) }
    var dsCaption2Medium: some View { self.dsFont(.caption2Medium) }
    var dsCaption2Regular: some View { self.dsFont(.caption2Regular) }

    var dsCaption3SemiBold: some View { self.dsFont(.caption3SemiBold) }
    var dsCaption3Medium: some View { self.dsFont(.caption3Medium) }
    var dsCaption3Regular: some View { self.dsFont(.caption3Regular) }
}
