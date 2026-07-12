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
                
                ComponentsCatalogView()
                    .tabItem {
                        Label("Components", systemImage: "square.grid.2x2")
                    }
                    .tag(3)
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
        case 3: return "Components"
        default: return "Catalog"
        }
    }
}

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
        DesignSystemAsset.Colors.coolGray50, DesignSystemAsset.Colors.coolGray100, DesignSystemAsset.Colors.coolGray200,
        DesignSystemAsset.Colors.coolGray300, DesignSystemAsset.Colors.coolGray400, DesignSystemAsset.Colors.coolGray500,
        DesignSystemAsset.Colors.coolGray600, DesignSystemAsset.Colors.coolGray700, DesignSystemAsset.Colors.coolGray800,
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

// MARK: - Components Catalog List
struct ComponentsCatalogView: View {
    var body: some View {
        List {
            NavigationLink(destination: ButtonPlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.and.hand.point.up.left.fill")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Button")
                            .font(.headline)
                        Text("Primary, Secondary / Large, Medium, Small 규격 버튼")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }
            
            // 향후 컴포넌트 추가 대기선
            HStack(spacing: 12) {
                Image(systemName: "tag.fill")
                    .foregroundColor(.ds.gray400)
                    .imageScale(.large)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chip & Badge (대기)")
                        .font(.headline)
                        .foregroundColor(.ds.gray400)
                    Text("카테고리 태그 및 상태 정보 표시 요소")
                        .font(.caption)
                        .foregroundColor(.ds.gray400)
                }
            }
            .padding(.vertical, 4)
            .opacity(0.5)
        }
    }
}

// MARK: - Button Playground Sandbox
struct ButtonPlaygroundView: View {
    @State private var buttonText: String = "다음 단계"
    @State private var selectedVariant: DSButtonVariant = .primary
    @State private var selectedSize: DSButtonSize = .large
    @State private var isEnabled: Bool = true
    @State private var showLeftIcon: Bool = false
    @State private var showRightIcon: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 🔍 1. 상단 실시간 프리뷰 영역
            VStack {
                Spacer()
                
                let currentButton = makeButton(title: buttonText)
                
                Text(String(describing: type(of: currentButton)))
                    .font(.system(.caption2, design: .monospaced))
                    .bold()
                    .foregroundColor(Color.ds.primary700)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.ds.primary50)
                    .cornerRadius(6)
                    .padding(.bottom, 12)
                
                if let buttonView = currentButton as? any View {
                    AnyView(buttonView)
                        .disabled(!isEnabled)
                        .id("\(selectedVariant)-\(selectedSize)-\(isEnabled)-\(showLeftIcon)-\(showRightIcon)-\(buttonText)") // SwiftUI 렌더링 강제 리프레시 팁
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(Color.ds.gray25)
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            
            // 🛠️ 2. 하단 컨트롤러 영역
            Form {
                Section(header: Text("Button Text")) {
                    TextField("Enter button text...", text: $buttonText)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("Style Properties")) {
                    Picker("Variant", selection: $selectedVariant) {
                        Text("Primary").tag(DSButtonVariant.primary)
                        Text("Secondary").tag(DSButtonVariant.secondary)
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Size", selection: $selectedSize) {
                        Text("Large").tag(DSButtonSize.large)
                        Text("Medium").tag(DSButtonSize.medium)
                        Text("Small").tag(DSButtonSize.small)
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Interactive State")) {
                    Toggle("Is Enabled (활성 상태)", isOn: $isEnabled)
                    Toggle("Show Left Icon (왼쪽 아이콘)", isOn: $showLeftIcon)
                    Toggle("Show Right Icon (오른쪽 아이콘)", isOn: $showRightIcon)
                }
                
                Section(header: Text("Figma Specification Check")) {
                    specificationRow(title: "Height", value: "\(Int(selectedSize.height))pt")
                    specificationRow(title: "Corner Radius", value: "\(Int(DSButtonStyle.cornerRadius))pt")
                    specificationRow(title: "Typography", value: fontDescription)
                    specificationRow(title: "Icon Size", value: iconSizeDescription)
                    specificationRow(title: "Bg Color", value: bgColorDescription)
                    specificationRow(title: "Text Color", value: textColorDescription)
                }
            }
        }
        .navigationTitle("Button Playground")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func specificationRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
        }
        .font(.footnote)
    }
    
    private func makeButton(title: String) -> Any {
        let left = showLeftIcon ? Image(systemName: "pencil") : nil
        let right = showRightIcon ? Image(systemName: "arrow.right") : nil
        
        switch (selectedVariant, selectedSize) {
        case (.primary, .large):
            return DSPrimaryLargeButton(title, leftIcon: left, rightIcon: right) {}
        case (.primary, .medium):
            return DSPrimaryMediumButton(title, leftIcon: left, rightIcon: right) {}
        case (.primary, .small):
            return DSPrimarySmallButton(title, leftIcon: left, rightIcon: right) {}
        case (.secondary, .large):
            return DSSecondaryLargeButton(title, leftIcon: left, rightIcon: right) {}
        case (.secondary, .medium):
            return DSSecondaryMediumButton(title, leftIcon: left, rightIcon: right) {}
        case (.secondary, .small):
            return DSSecondarySmallButton(title, leftIcon: left, rightIcon: right) {}
        }
    }
    
    private var iconSizeDescription: String {
        guard showLeftIcon || showRightIcon else { return "None" }
        let sizeInt = Int(selectedSize.iconSize)
        return "\(sizeInt)x\(sizeInt)pt"
    }
    
    private var fontDescription: String {
        selectedSize.specFontName(isEnabled: isEnabled)
    }
    
    private var bgColorDescription: String {
        selectedVariant.specBgColorName(isEnabled: isEnabled)
    }
    
    private var textColorDescription: String {
        selectedVariant.specTextColorName(isEnabled: isEnabled)
    }
}

// MARK: - 디자인 QA용 예제 앱 전용 디버그 확장 (프로덕션 SDK 오염 방지 격리 수용)
import UIKit

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
