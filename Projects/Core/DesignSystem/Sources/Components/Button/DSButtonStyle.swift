import SwiftUI
import UIKit

public enum DSButtonVariant {
    case primary
    case secondary
    
    public func bgAsset(isEnabled: Bool) -> DesignSystemColors {
        guard isEnabled else { return DesignSystemAsset.Colors.gray100 }
        switch self {
        case .primary: return DesignSystemAsset.Colors.primary600
        case .secondary: return DesignSystemAsset.Colors.primary50
        }
    }
    
    public func textAsset(isEnabled: Bool) -> DesignSystemColors {
        guard isEnabled else { return DesignSystemAsset.Colors.gray400 }
        switch self {
        case .primary: return DesignSystemAsset.Colors.white
        case .secondary: return DesignSystemAsset.Colors.primary700
        }
    }
}

public enum DSButtonSize {
    case large
    case medium
    case small
    
    public var height: CGFloat {
        switch self {
        case .large: return 52
        case .medium: return 44
        case .small: return 32
        }
    }
    
    // 피그마 가이드상 크기별 아이콘 크기 규격
    public var iconSize: CGFloat {
        switch self {
        case .large: return 20
        case .medium: return 16
        case .small: return 14
        }
    }
    
    // 디자인 명세에 맞춘 버튼 크기별 폰트 스타일 매핑
    public func fontStyle(isEnabled: Bool) -> FontStyle {
        guard isEnabled else {
            switch self {
            case .large: return .body2Medium
            case .medium: return .body3Medium
            case .small: return .caption1Medium
            }
        }
        
        switch self {
        case .large: return .body2SemiBold
        case .medium: return .body3Medium
        case .small: return .caption1SemiBold
        }
    }
}

public struct DSButtonStyle: ButtonStyle {
    public static let cornerRadius: CGFloat = 12
    
    let variant: DSButtonVariant
    let size: DSButtonSize
    
    @Environment(\.isEnabled) private var isEnabled
    
    public init(variant: DSButtonVariant, size: DSButtonSize) {
        self.variant = variant
        self.size = size
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        // 우리가 약속한 30종 뷰 연산 프로퍼티(.dsBody2SemiBold 등) 체이닝 적용
        applyFont(to: configuration.label)
            .foregroundColor(foregroundColor())
            .frame(height: size.height)
            .padding(.horizontal, 20) // 글자 길이에 따라 유연하게 늘어나도록 좌우 패딩만 제공
            .background(backgroundColor())
            .cornerRadius(Self.cornerRadius) // 정의한 공용 상수 적용
    }
    
    // 피그마 디자인 명세에 명시된 폰트 스타일을 30종 연산 프로퍼티로 1:1 보정 적용
    @ViewBuilder
    private func applyFont(to label: Configuration.Label) -> some View {
        let style = size.fontStyle(isEnabled: isEnabled)
        applySpecificFont(to: label, style: style)
    }
    
    @ViewBuilder
    private func applySpecificFont(to label: Configuration.Label, style: FontStyle) -> some View {
        switch style {
        case .body2Medium: label.dsBody2Medium
        case .body3Medium: label.dsBody3Medium
        case .caption1Medium: label.dsCaption1Medium
        case .body2SemiBold: label.dsBody2SemiBold
        case .caption1SemiBold: label.dsCaption1SemiBold
        default: label
        }
    }
    
    // 에셋 메타데이터로부터 실시간 swiftUIColor 객체를 추출해 렌더링
    private func backgroundColor() -> Color {
        variant.bgAsset(isEnabled: isEnabled).swiftUIColor
    }
    
    private func foregroundColor() -> Color {
        variant.textAsset(isEnabled: isEnabled).swiftUIColor
    }
}
