#if DEBUG
import SwiftUI

struct DSLayoutInspectorInformationPanel: View {
    let mode: DSLayoutInspectorOverlay.Mode
    let selectedRegionCount: Int
    let selectedRegion: DSLayoutRegion?
    let rulerPointCount: Int
    let currentScreenName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Capsule()
                .fill(.white.opacity(0.45))
                .frame(width: 28, height: 3)
                .frame(maxWidth: .infinity)

            Text(instructionText)
                .font(.system(size: 12, weight: .semibold))

            Text("현재 화면: \(currentScreenName)")
                .lineLimit(1)

            if let selectedRegion {
                Text("선택 영역: \(selectedRegion.name)")
                    .lineLimit(1)
                Text(frameDescription(selectedRegion.frame))
                    .monospacedDigit()
            }
        }
        .font(.system(size: 11))
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.black.opacity(0.82), in: RoundedRectangle(cornerRadius: 10))
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("\(DSLayoutInspectorConstants.accessibilityPrefix).information")
    }

    private var instructionText: String {
        switch mode {
        case .inspection:
            selectedRegionCount == 0
                ? "영역을 눌러 속성을 확인하세요."
                : "다른 영역을 누르면 선택이 교체됩니다."
        case .spacing:
            selectedRegionCount < 2
                ? "두 영역을 차례로 눌러 간격을 측정하세요."
                : "다른 영역을 누르면 새 측정을 시작합니다."
        case .ruler:
            rulerPointCount == 1
                ? "끝 지점을 누르거나 새 구간을 드래그하세요."
                : "두 지점을 차례로 누르거나 드래그해 측정하세요."
        }
    }

    private func frameDescription(_ frame: CGRect) -> String {
        String(
            format: "x %.1f · y %.1f · 너비 %.1f · 높이 %.1f",
            frame.minX,
            frame.minY,
            frame.width,
            frame.height
        )
    }
}

struct DSLayoutInspectorInformationHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
#endif
