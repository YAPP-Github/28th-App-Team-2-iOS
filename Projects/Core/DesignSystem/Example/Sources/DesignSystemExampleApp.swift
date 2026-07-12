import SwiftUI
import DesignSystem

@main
struct DesignSystemExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                ColorCatalogView()
                    .tabItem {
                        Label("Colors", systemImage: "paintpalette")
                    }
                    .tag(0)
                
                FontCatalogView()
                    .tabItem {
                        Label("Fonts", systemImage: "textformat")
                    }
                    .tag(1)
                
                OpacityCatalogView()
                    .tabItem {
                        Label("Opacities", systemImage: "square.stack.3d.down.right")
                    }
                    .tag(2)
            }
            .navigationTitle(navigationTitle(for: selectedTab))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func navigationTitle(for tab: Int) -> String {
        switch tab {
        case 0: return "Color Palette"
        case 1: return "Typography"
        case 2: return "Opacity"
        default: return "Catalog"
        }
    }
}

// MARK: - Color Catalog
struct ColorCatalogView: View {
    private let grayScale: [(String, Color)] = [
        ("Gray25", .ds.gray25), ("Gray50", .ds.gray50), ("Gray100", .ds.gray100),
        ("Gray200", .ds.gray200), ("Gray300", .ds.gray300), ("Gray400", .ds.gray400),
        ("Gray500", .ds.gray500), ("Gray600", .ds.gray600), ("Gray700", .ds.gray700),
        ("Gray800", .ds.gray800), ("Gray900", .ds.gray900), ("Gray925", .ds.gray925),
        ("Gray950", .ds.gray950), ("Gray975", .ds.gray975)
    ]
    
    private let primaryScale: [(String, Color)] = [
        ("Primary50", .ds.primary50), ("Primary100", .ds.primary100), ("Primary200", .ds.primary200),
        ("Primary300", .ds.primary300), ("Primary400", .ds.primary400), ("Primary500", .ds.primary500),
        ("Primary600", .ds.primary600), ("Primary700", .ds.primary700), ("Primary800", .ds.primary800),
        ("Primary900", .ds.primary900)
    ]
    
    private let coolGrayScale: [(String, Color)] = [
        ("CoolGray50", .ds.coolGray50), ("CoolGray100", .ds.coolGray100), ("CoolGray200", .ds.coolGray200),
        ("CoolGray300", .ds.coolGray300), ("CoolGray400", .ds.coolGray400), ("CoolGray500", .ds.coolGray500),
        ("CoolGray600", .ds.coolGray600), ("CoolGray700", .ds.coolGray700), ("CoolGray800", .ds.coolGray800),
        ("CoolGray900", .ds.coolGray900)
    ]
    
    private let skyScale: [(String, Color)] = [
        ("Sky50", .ds.sky50), ("Sky100", .ds.sky100), ("Sky200", .ds.sky200),
        ("Sky300", .ds.sky300), ("Sky400", .ds.sky400), ("Sky500", .ds.sky500),
        ("Sky600", .ds.sky600), ("Sky700", .ds.sky700), ("Sky800", .ds.sky800),
        ("Sky900", .ds.sky900)
    ]
    
    private let pinkScale: [(String, Color)] = [
        ("Pink50", .ds.pink50), ("Pink100", .ds.pink100), ("Pink200", .ds.pink200),
        ("Pink300", .ds.pink300), ("Pink400", .ds.pink400), ("Pink500", .ds.pink500),
        ("Pink600", .ds.pink600), ("Pink700", .ds.pink700), ("Pink800", .ds.pink800),
        ("Pink900", .ds.pink900)
    ]

    private let redScale: [(String, Color)] = [
        ("Red50", .ds.red50), ("Red100", .ds.red100), ("Red200", .ds.red200),
        ("Red300", .ds.red300), ("Red400", .ds.red400), ("Red500", .ds.red500),
        ("Red600", .ds.red600), ("Red700", .ds.red700), ("Red800", .ds.red800),
        ("Red900", .ds.red900)
    ]

    private let orangeScale: [(String, Color)] = [
        ("Orange50", .ds.orange50), ("Orange100", .ds.orange100), ("Orange200", .ds.orange200),
        ("Orange300", .ds.orange300), ("Orange400", .ds.orange400), ("Orange500", .ds.orange500),
        ("Orange600", .ds.orange600), ("Orange700", .ds.orange700), ("Orange800", .ds.orange800),
        ("Orange900", .ds.orange900)
    ]

    private let tealScale: [(String, Color)] = [
        ("Teal50", .ds.teal50), ("Teal100", .ds.teal100), ("Teal200", .ds.teal200),
        ("Teal300", .ds.teal300), ("Teal400", .ds.teal400), ("Teal500", .ds.teal500),
        ("Teal600", .ds.teal600), ("Teal700", .ds.teal700), ("Teal800", .ds.teal800),
        ("Teal900", .ds.teal900)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Common Colors").font(.headline)
                    HStack {
                        colorBlock(name: "White", color: .ds.white)
                        colorBlock(name: "Black", color: .ds.black)
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
            }
            .padding()
        }
    }
    
    private func colorSection(title: String, scale: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(scale, id: \.0) { item in
                        colorBlock(name: item.0, color: item.1)
                    }
                }
            }
        }
    }
    
    private func colorBlock(name: String, color: Color) -> some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 80, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            Text(name)
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(width: 80)
    }
}

// MARK: - Font Catalog
struct FontCatalogView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                fontSection(title: "Headings") {
                    Text("Heading 1 ExtraBold - 32pt").dsHeading1ExtraBold
                    Text("Heading 1 Bold - 32pt").dsHeading1Bold
                    Text("Heading 1 SemiBold - 32pt").dsHeading1SemiBold
                    
                    Text("Heading 2 ExtraBold - 28pt").dsHeading2ExtraBold
                    Text("Heading 2 Bold - 28pt").dsHeading2Bold
                    Text("Heading 2 SemiBold - 28pt").dsHeading2SemiBold
                    
                    Text("Heading 3 Bold - 24pt").dsHeading3Bold
                    Text("Heading 3 Medium - 24pt").dsHeading3Medium
                    Text("Heading 3 Regular - 24pt").dsHeading3Regular
                    
                    Text("Heading 4 Bold - 22pt").dsHeading4Bold
                    Text("Heading 4 Medium - 22pt").dsHeading4Medium
                    Text("Heading 4 Regular - 22pt").dsHeading4Regular
                }
                
                fontSection(title: "Bodies") {
                    Text("Body 1 Bold - 18pt\nLineHeight 130% 적용 확인 줄바꿈 데모 텍스트입니다.").dsBody1Bold
                    Text("Body 1 Medium - 18pt\nLineHeight 130% 적용 확인 줄바꿈 데모 텍스트입니다.").dsBody1Medium
                    Text("Body 1 Regular - 18pt\nLineHeight 130% 적용 확인 줄바꿈 데모 텍스트입니다.").dsBody1Regular
                    
                    Text("Body 2 SemiBold - 16pt\nLineHeight 130% 적용 확인 줄바꿈 데모 텍스트입니다.").dsBody2SemiBold
                    Text("Body 2 Medium - 16pt\nLineHeight 130% 적용 확인 줄바꿈 데모 텍스트입니다.").dsBody2Medium
                    Text("Body 2 Regular - 16pt\nLineHeight 130% 적용 확인 줄바꿈 데모 텍스트입니다.").dsBody2Regular
                    
                    Text("Body 3 SemiBold - 14pt\nLineHeight 130% 적용 확인 줄바꿈 데모 텍스트입니다.").dsBody3SemiBold
                    Text("Body 3 Medium - 14pt\nLineHeight 130% 적용 확인 줄바꿈 데모 텍스트입니다.").dsBody3Medium
                    Text("Body 3 Regular - 14pt\nLineHeight 130% 적용 확인 줄바꿈 데모 텍스트입니다.").dsBody3Regular
                }
                
                fontSection(title: "Captions") {
                    Text("Caption 1 SemiBold - 12pt").dsCaption1SemiBold
                    Text("Caption 1 Medium - 12pt").dsCaption1Medium
                    Text("Caption 1 Regular - 12pt").dsCaption1Regular
                    
                    Text("Caption 2 SemiBold - 11pt").dsCaption2SemiBold
                    Text("Caption 2 Medium - 11pt").dsCaption2Medium
                    Text("Caption 2 Regular - 11pt").dsCaption2Regular
                    
                    Text("Caption 3 SemiBold - 10pt").dsCaption3SemiBold
                    Text("Caption 3 Medium - 10pt").dsCaption3Medium
                    Text("Caption 3 Regular - 10pt").dsCaption3Regular
                }
            }
            .padding()
        }
    }
    
    private func fontSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Divider()
            VStack(alignment: .leading, spacing: 16) {
                content()
            }
        }
    }
}

// MARK: - Opacity Catalog
struct OpacityCatalogView: View {
    private let blackOpacities: [(String, Color, String)] = [
        ("Opacity 05", .ds.opacity05, "States/Hover (light)"),
        ("Opacity 10", .ds.opacity10, "States/Pressed (light)"),
        ("Opacity 20", .ds.opacity20, "Scrim light"),
        ("Opacity 30", .ds.opacity30, "Scrim"),
        ("Opacity 50", .ds.opacity50, "Modal backdrop"),
        ("Opacity 60", .ds.opacity60, "Strong scrim"),
        ("Opacity 80", .ds.opacity80, "Heavy scrim")
    ]
    
    private let whiteOpacities: [(String, Color, String)] = [
        ("White Opacity 05", .ds.whiteOpacity05, "다크 배경 위 최연한 레이어"),
        ("White Opacity 10", .ds.whiteOpacity10, "Hover (dark)"),
        ("White Opacity 20", .ds.whiteOpacity20, "Pressed (dark) · Border Inverse"),
        ("White Opacity 30", .ds.whiteOpacity30, "다크 배경 구분"),
        ("White Opacity 50", .ds.whiteOpacity50, "Inverse Tertiary Text"),
        ("White Opacity 60", .ds.whiteOpacity60, "Inverse Secondary Text"),
        ("White Opacity 80", .ds.whiteOpacity80, "다크 배경 위 강한 텍스트"),
        ("White Opacity 90", .ds.whiteOpacity90, "다크 배경 거의 불투명")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // 1. Black Opacity: 밝은 모드 배경 대조군 제공 (Base: gray100)
                opacitySection(
                    title: "Black Alpha Opacity (Base: #1B1B1B)",
                    description: "주로 밝은 모드 배경 위에 얹혀 어두운 위계(Hover/Pressed/Scrim)를 표현합니다.",
                    list: blackOpacities,
                    backgroundColor: Color.ds.gray50,
                    textColor: Color.ds.gray950
                )
                
                // 2. White Opacity: 다크 모드 배경 대조군 제공 (Base: gray950)
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
    
    private func opacitySection(
        title: String,
        description: String,
        list: [(String, Color, String)],
        backgroundColor: Color,
        textColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary) // 💡 바깥 기본 배경 테마에 맞춰 안전하게 항상 보이는 색상 적용
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary) // 💡 설명 텍스트도 시스템 보조 컬러로 안전하게 노출
            }
            
            // 대비를 한 눈에 파악할 수 있도록 하나의 큰 카드 형태로 배치
            VStack(spacing: 0) {
                ForEach(list, id: \.0) { item in
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.0)
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(textColor) // 💡 카드 배경 대비 텍스트 색상 적용
                            Text(item.2)
                                .font(.caption2)
                                .foregroundColor(textColor.opacity(0.6)) // 💡 카드 배경 대비 캡션 투명도 조절
                        }
                        
                        Spacer()
                        
                        // 우측 오파시티 실제 렌더링 컬러 칩
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.1)
                            .frame(width: 100, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding()
                    if item.0 != list.last?.0 {
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
