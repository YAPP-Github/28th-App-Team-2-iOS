import SwiftUI
import DesignSystem

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
                // 1. Black Opacity: 밝은 모드 배경 대조군 제공 (Base: gray50)
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
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 0) {
                ForEach(list, id: \.0) { item in
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.0)
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(textColor)
                            Text(item.2)
                                .font(.caption2)
                                .foregroundColor(textColor.opacity(0.6))
                        }
                        
                        Spacer()
                        
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
