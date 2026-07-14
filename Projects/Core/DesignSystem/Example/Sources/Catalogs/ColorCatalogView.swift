import SwiftUI
import DesignSystem

// MARK: - Color Catalog
struct ColorCatalogView: View {
    private let grayScale: [DesignSystemColors] = [
        DesignSystemAsset.Colors.gray25, DesignSystemAsset.Colors.gray50, DesignSystemAsset.Colors.gray100,
        DesignSystemAsset.Colors.gray200, DesignSystemAsset.Colors.gray300, DesignSystemAsset.Colors.gray400,
        DesignSystemAsset.Colors.gray500, DesignSystemAsset.Colors.gray600, DesignSystemAsset.Colors.gray700,
        DesignSystemAsset.Colors.gray800, DesignSystemAsset.Colors.gray900, DesignSystemAsset.Colors.gray925,
        DesignSystemAsset.Colors.gray950, DesignSystemAsset.Colors.gray975
    ]

    private let primaryScale: [DesignSystemColors] = [
        DesignSystemAsset.Colors.primary50, DesignSystemAsset.Colors.primary100, DesignSystemAsset.Colors.primary200,
        DesignSystemAsset.Colors.primary300, DesignSystemAsset.Colors.primary400, DesignSystemAsset.Colors.primary500,
        DesignSystemAsset.Colors.primary600, DesignSystemAsset.Colors.primary700, DesignSystemAsset.Colors.primary800,
        DesignSystemAsset.Colors.primary900
    ]

    private let coolGrayScale: [DesignSystemColors] = [
        DesignSystemAsset.Colors.coolGray50,
        DesignSystemAsset.Colors.coolGray100,
        DesignSystemAsset.Colors.coolGray200,
        DesignSystemAsset.Colors.coolGray300,
        DesignSystemAsset.Colors.coolGray400,
        DesignSystemAsset.Colors.coolGray500,
        DesignSystemAsset.Colors.coolGray600,
        DesignSystemAsset.Colors.coolGray700,
        DesignSystemAsset.Colors.coolGray800,
        DesignSystemAsset.Colors.coolGray900
    ]

    private let skyScale: [DesignSystemColors] = [
        DesignSystemAsset.Colors.sky50, DesignSystemAsset.Colors.sky100, DesignSystemAsset.Colors.sky200,
        DesignSystemAsset.Colors.sky300, DesignSystemAsset.Colors.sky400, DesignSystemAsset.Colors.sky500,
        DesignSystemAsset.Colors.sky600, DesignSystemAsset.Colors.sky700, DesignSystemAsset.Colors.sky800,
        DesignSystemAsset.Colors.sky900
    ]

    private let pinkScale: [DesignSystemColors] = [
        DesignSystemAsset.Colors.pink50, DesignSystemAsset.Colors.pink100, DesignSystemAsset.Colors.pink200,
        DesignSystemAsset.Colors.pink300, DesignSystemAsset.Colors.pink400, DesignSystemAsset.Colors.pink500,
        DesignSystemAsset.Colors.pink600, DesignSystemAsset.Colors.pink700, DesignSystemAsset.Colors.pink800,
        DesignSystemAsset.Colors.pink900
    ]

    private let redScale: [DesignSystemColors] = [
        DesignSystemAsset.Colors.red50, DesignSystemAsset.Colors.red100, DesignSystemAsset.Colors.red200,
        DesignSystemAsset.Colors.red300, DesignSystemAsset.Colors.red400, DesignSystemAsset.Colors.red500,
        DesignSystemAsset.Colors.red600, DesignSystemAsset.Colors.red700, DesignSystemAsset.Colors.red800,
        DesignSystemAsset.Colors.red900
    ]

    private let orangeScale: [DesignSystemColors] = [
        DesignSystemAsset.Colors.orange50, DesignSystemAsset.Colors.orange100, DesignSystemAsset.Colors.orange200,
        DesignSystemAsset.Colors.orange300, DesignSystemAsset.Colors.orange400, DesignSystemAsset.Colors.orange500,
        DesignSystemAsset.Colors.orange600, DesignSystemAsset.Colors.orange700, DesignSystemAsset.Colors.orange800,
        DesignSystemAsset.Colors.orange900
    ]

    private let tealScale: [DesignSystemColors] = [
        DesignSystemAsset.Colors.teal50, DesignSystemAsset.Colors.teal100, DesignSystemAsset.Colors.teal200,
        DesignSystemAsset.Colors.teal300, DesignSystemAsset.Colors.teal400, DesignSystemAsset.Colors.teal500,
        DesignSystemAsset.Colors.teal600, DesignSystemAsset.Colors.teal700, DesignSystemAsset.Colors.teal800,
        DesignSystemAsset.Colors.teal900
    ]

    private let blackOpacities: [(DesignSystemColors, String)] = [
        (DesignSystemAsset.Colors.opacity05, "States/Hover (light)"),
        (DesignSystemAsset.Colors.opacity10, "States/Pressed (light)"),
        (DesignSystemAsset.Colors.opacity20, "Scrim light"),
        (DesignSystemAsset.Colors.opacity30, "Scrim"),
        (DesignSystemAsset.Colors.opacity50, "Modal backdrop"),
        (DesignSystemAsset.Colors.opacity60, "Strong scrim"),
        (DesignSystemAsset.Colors.opacity80, "Heavy scrim")
    ]

    private let whiteOpacities: [(DesignSystemColors, String)] = [
        (DesignSystemAsset.Colors.whiteOpacity05, "다크 배경 위 최연한 레이어"),
        (DesignSystemAsset.Colors.whiteOpacity10, "Hover (dark)"),
        (DesignSystemAsset.Colors.whiteOpacity20, "Pressed (dark) · Border Inverse"),
        (DesignSystemAsset.Colors.whiteOpacity30, "다크 배경 구분"),
        (DesignSystemAsset.Colors.whiteOpacity50, "Inverse Tertiary Text"),
        (DesignSystemAsset.Colors.whiteOpacity60, "Inverse Secondary Text"),
        (DesignSystemAsset.Colors.whiteOpacity80, "다크 배경 위 강한 텍스트"),
        (DesignSystemAsset.Colors.whiteOpacity90, "다크 배경 거의 불투명")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Common Colors").font(.headline)
                    HStack {
                        colorBlock(asset: DesignSystemAsset.Colors.white)
                        colorBlock(asset: DesignSystemAsset.Colors.black)
                    }
                }

                colorSection(title: "Gray Scale", scale: grayScale)
                colorSection(title: "Primary Scale", scale: primaryScale)
                colorSection(title: "CoolGray Scale", scale: coolGrayScale)
                colorSection(title: "Sky Scale", scale: skyScale)
                colorSection(title: "Pink Scale", scale: pinkScale)
                colorSection(title: "Red Scale", scale: redScale)
                colorSection(title: "Orange Scale", scale: orangeScale)
                colorSection(title: "Teal Scale", scale: tealScale)

                opacitySection(
                    title: "Black Alpha Opacity (Base: #1B1B1B)",
                    description: "주로 밝은 모드 배경 위에 얹혀 어두운 위계(Hover/Pressed/Scrim)를 표현합니다.",
                    list: blackOpacities,
                    backgroundColor: Color.ds.gray50,
                    textColor: Color.ds.gray950
                )

                opacitySection(
                    title: "White Alpha Opacity (Base: #FFFFFF)",
                    description: "어두운 밤하늘/다크 배경 위에 얹혀 뽀얗고 세련된 반투명 요소를 표현합니다.",
                    list: whiteOpacities,
                    backgroundColor: Color.ds.gray950,
                    textColor: Color.ds.white
                )
            }
            .padding()
        }
    }

    private func colorSection(title: String, scale: [DesignSystemColors]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(scale, id: \.name) { item in
                        colorBlock(asset: item)
                    }
                }
            }
        }
    }

    private func colorBlock(asset: DesignSystemColors) -> some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(asset.swiftUIColor)
                .frame(width: 115, height: 115)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            Text(asset.displayName)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(1)
            Text(asset.color.hexString)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(width: 115)
    }

    private func opacitySection(
        title: String,
        description: String,
        list: [(DesignSystemColors, String)],
        backgroundColor: Color,
        textColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(list, id: \.0.name) { item in
                    let asset = item.0
                    let desc = item.1

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(asset.displayName)
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(textColor)
                            Text(desc)
                                .font(.caption2)
                                .foregroundColor(textColor.opacity(0.6))
                        }

                        Spacer()

                        RoundedRectangle(cornerRadius: 8)
                            .fill(asset.swiftUIColor)
                            .frame(width: 100, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding()
                    if asset.name != list.last?.0.name {
                        Divider()
                            .background(Color.gray.opacity(0.15))
                    }
                }
            }
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
