import SwiftUI

public extension Color {
    static let ds = DesignSystemColor.self
}

public enum DesignSystemColor {
    // Common
    public static let white = DesignSystemAsset.Colors.white.swiftUIColor
    public static let black = DesignSystemAsset.Colors.black.swiftUIColor

    // Gray
    public static let gray25 = DesignSystemAsset.Colors.gray25.swiftUIColor
    public static let gray50 = DesignSystemAsset.Colors.gray50.swiftUIColor
    public static let gray100 = DesignSystemAsset.Colors.gray100.swiftUIColor
    public static let gray200 = DesignSystemAsset.Colors.gray200.swiftUIColor
    public static let gray300 = DesignSystemAsset.Colors.gray300.swiftUIColor
    public static let gray400 = DesignSystemAsset.Colors.gray400.swiftUIColor
    public static let gray500 = DesignSystemAsset.Colors.gray500.swiftUIColor
    public static let gray600 = DesignSystemAsset.Colors.gray600.swiftUIColor
    public static let gray700 = DesignSystemAsset.Colors.gray700.swiftUIColor
    public static let gray800 = DesignSystemAsset.Colors.gray800.swiftUIColor
    public static let gray900 = DesignSystemAsset.Colors.gray900.swiftUIColor
    public static let gray925 = DesignSystemAsset.Colors.gray925.swiftUIColor
    public static let gray950 = DesignSystemAsset.Colors.gray950.swiftUIColor
    public static let gray975 = DesignSystemAsset.Colors.gray975.swiftUIColor

    // Primary
    public static let primary50 = DesignSystemAsset.Colors.primary50.swiftUIColor
    public static let primary100 = DesignSystemAsset.Colors.primary100.swiftUIColor
    public static let primary200 = DesignSystemAsset.Colors.primary200.swiftUIColor
    public static let primary300 = DesignSystemAsset.Colors.primary300.swiftUIColor
    public static let primary400 = DesignSystemAsset.Colors.primary400.swiftUIColor
    public static let primary500 = DesignSystemAsset.Colors.primary500.swiftUIColor
    public static let primary600 = DesignSystemAsset.Colors.primary600.swiftUIColor
    public static let primary700 = DesignSystemAsset.Colors.primary700.swiftUIColor
    public static let primary800 = DesignSystemAsset.Colors.primary800.swiftUIColor
    public static let primary900 = DesignSystemAsset.Colors.primary900.swiftUIColor

    // CoolGray
    public static let coolGray50 = DesignSystemAsset.Colors.coolGray50.swiftUIColor
    public static let coolGray100 = DesignSystemAsset.Colors.coolGray100.swiftUIColor
    public static let coolGray200 = DesignSystemAsset.Colors.coolGray200.swiftUIColor
    public static let coolGray300 = DesignSystemAsset.Colors.coolGray300.swiftUIColor
    public static let coolGray400 = DesignSystemAsset.Colors.coolGray400.swiftUIColor
    public static let coolGray500 = DesignSystemAsset.Colors.coolGray500.swiftUIColor
    public static let coolGray600 = DesignSystemAsset.Colors.coolGray600.swiftUIColor
    public static let coolGray700 = DesignSystemAsset.Colors.coolGray700.swiftUIColor
    public static let coolGray800 = DesignSystemAsset.Colors.coolGray800.swiftUIColor
    public static let coolGray900 = DesignSystemAsset.Colors.coolGray900.swiftUIColor

    // Sky
    public static let sky50 = DesignSystemAsset.Colors.sky50.swiftUIColor
    public static let sky100 = DesignSystemAsset.Colors.sky100.swiftUIColor
    public static let sky200 = DesignSystemAsset.Colors.sky200.swiftUIColor
    public static let sky300 = DesignSystemAsset.Colors.sky300.swiftUIColor
    public static let sky400 = DesignSystemAsset.Colors.sky400.swiftUIColor
    public static let sky500 = DesignSystemAsset.Colors.sky500.swiftUIColor
    public static let sky600 = DesignSystemAsset.Colors.sky600.swiftUIColor
    public static let sky700 = DesignSystemAsset.Colors.sky700.swiftUIColor
    public static let sky800 = DesignSystemAsset.Colors.sky800.swiftUIColor
    public static let sky900 = DesignSystemAsset.Colors.sky900.swiftUIColor

    // Pink
    public static let pink50 = DesignSystemAsset.Colors.pink50.swiftUIColor
    public static let pink100 = DesignSystemAsset.Colors.pink100.swiftUIColor
    public static let pink200 = DesignSystemAsset.Colors.pink200.swiftUIColor
    public static let pink300 = DesignSystemAsset.Colors.pink300.swiftUIColor
    public static let pink400 = DesignSystemAsset.Colors.pink400.swiftUIColor
    public static let pink500 = DesignSystemAsset.Colors.pink500.swiftUIColor
    public static let pink600 = DesignSystemAsset.Colors.pink600.swiftUIColor
    public static let pink700 = DesignSystemAsset.Colors.pink700.swiftUIColor
    public static let pink800 = DesignSystemAsset.Colors.pink800.swiftUIColor
    public static let pink900 = DesignSystemAsset.Colors.pink900.swiftUIColor

    // Red
    public static let red50 = DesignSystemAsset.Colors.red50.swiftUIColor
    public static let red100 = DesignSystemAsset.Colors.red100.swiftUIColor
    public static let red200 = DesignSystemAsset.Colors.red200.swiftUIColor
    public static let red300 = DesignSystemAsset.Colors.red300.swiftUIColor
    public static let red400 = DesignSystemAsset.Colors.red400.swiftUIColor
    public static let red500 = DesignSystemAsset.Colors.red500.swiftUIColor
    public static let red600 = DesignSystemAsset.Colors.red600.swiftUIColor
    public static let red700 = DesignSystemAsset.Colors.red700.swiftUIColor
    public static let red800 = DesignSystemAsset.Colors.red800.swiftUIColor
    public static let red900 = DesignSystemAsset.Colors.red900.swiftUIColor

    // Orange
    public static let orange50 = DesignSystemAsset.Colors.orange50.swiftUIColor
    public static let orange100 = DesignSystemAsset.Colors.orange100.swiftUIColor
    public static let orange200 = DesignSystemAsset.Colors.orange200.swiftUIColor
    public static let orange300 = DesignSystemAsset.Colors.orange300.swiftUIColor
    public static let orange400 = DesignSystemAsset.Colors.orange400.swiftUIColor
    public static let orange500 = DesignSystemAsset.Colors.orange500.swiftUIColor
    public static let orange600 = DesignSystemAsset.Colors.orange600.swiftUIColor
    public static let orange700 = DesignSystemAsset.Colors.orange700.swiftUIColor
    public static let orange800 = DesignSystemAsset.Colors.orange800.swiftUIColor
    public static let orange900 = DesignSystemAsset.Colors.orange900.swiftUIColor

    // Teal
    public static let teal50 = DesignSystemAsset.Colors.teal50.swiftUIColor
    public static let teal100 = DesignSystemAsset.Colors.teal100.swiftUIColor
    public static let teal200 = DesignSystemAsset.Colors.teal200.swiftUIColor
    public static let teal300 = DesignSystemAsset.Colors.teal300.swiftUIColor
    public static let teal400 = DesignSystemAsset.Colors.teal400.swiftUIColor
    public static let teal500 = DesignSystemAsset.Colors.teal500.swiftUIColor
    public static let teal600 = DesignSystemAsset.Colors.teal600.swiftUIColor
    public static let teal700 = DesignSystemAsset.Colors.teal700.swiftUIColor
    public static let teal800 = DesignSystemAsset.Colors.teal800.swiftUIColor
    public static let teal900 = DesignSystemAsset.Colors.teal900.swiftUIColor

    // Opacity (Black α - Base: #1B1B1B)
    public static let opacity05 = DesignSystemAsset.Colors.opacity05.swiftUIColor
    public static let opacity10 = DesignSystemAsset.Colors.opacity10.swiftUIColor
    public static let opacity20 = DesignSystemAsset.Colors.opacity20.swiftUIColor
    public static let opacity30 = DesignSystemAsset.Colors.opacity30.swiftUIColor
    public static let opacity50 = DesignSystemAsset.Colors.opacity50.swiftUIColor
    public static let opacity60 = DesignSystemAsset.Colors.opacity60.swiftUIColor
    public static let opacity80 = DesignSystemAsset.Colors.opacity80.swiftUIColor

    // White-Opacity (White α - Base: #FFFFFF)
    public static let whiteOpacity05 = DesignSystemAsset.Colors.whiteOpacity05.swiftUIColor
    public static let whiteOpacity10 = DesignSystemAsset.Colors.whiteOpacity10.swiftUIColor
    public static let whiteOpacity20 = DesignSystemAsset.Colors.whiteOpacity20.swiftUIColor
    public static let whiteOpacity30 = DesignSystemAsset.Colors.whiteOpacity30.swiftUIColor
    public static let whiteOpacity50 = DesignSystemAsset.Colors.whiteOpacity50.swiftUIColor
    public static let whiteOpacity60 = DesignSystemAsset.Colors.whiteOpacity60.swiftUIColor
    public static let whiteOpacity80 = DesignSystemAsset.Colors.whiteOpacity80.swiftUIColor
    public static let whiteOpacity90 = DesignSystemAsset.Colors.whiteOpacity90.swiftUIColor
}
