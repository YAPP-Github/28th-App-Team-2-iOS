#if DEBUG
import SwiftUI

enum DSLayoutInspectorRefreshIdentity {
    static func reportedRegions(
        _ regions: [DSLayoutRegion],
        displayScale: CGFloat
    ) -> String {
        // Preference에서 올라온 영역의 ID만 비교하면 내용은 같고 프레임만 바뀐
        // 회전·동적 레이아웃 변화를 놓친다. ID와 프레임을 함께 task identity에 넣어
        // 현재 화면 기준으로 자동 수집 결과를 갱신한다.
        regions.map { region in
            let frame = [region.frame.minX, region.frame.minY, region.frame.width, region.frame.height]
                .map { quantized($0, displayScale: displayScale) }
                .joined(separator: ":")
            return "\(region.regionID):\(frame)"
        }
        .sorted()
        .joined(separator: "|")
    }

    static func make(
        reportedRegionIdentity: String,
        layoutSize: CGSize,
        safeAreaInsets: EdgeInsets,
        displayScale: CGFloat
    ) -> String {
        // safe area까지 포함해야 회전, 시트·키보드 등으로 사용 가능 영역이 달라질 때
        // 플로팅 제어 패널과 수집 프레임이 이전 화면 좌표에 남지 않는다.
        let layoutValues = [
            layoutSize.width, layoutSize.height,
            safeAreaInsets.top, safeAreaInsets.leading,
            safeAreaInsets.bottom, safeAreaInsets.trailing
        ]
        let layout = layoutValues
            .map { quantized($0, displayScale: displayScale) }
            .joined(separator: ":")
        return "\(reportedRegionIdentity)|\(layout)"
    }

    private static func quantized(_ value: CGFloat, displayScale: CGFloat) -> String {
        // 소수점 미세 오차만으로 task가 반복 실행되지 않도록 실제 화면의 pixel 단위로
        // 반올림한다. 검사기가 표현하는 좌표 정밀도와도 일치한다.
        String(Int((value * displayScale).rounded()))
    }
}

enum DSLayoutInspectorControl {
    static func button(
        title: String,
        systemImage: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 34, height: 34)
                .foregroundStyle(isActive ? .black : .white)
                .background(
                    isActive ? Color.yellow : Color.black.opacity(0.82),
                    in: RoundedRectangle(cornerRadius: 9)
                )
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(title)
        .accessibilityIdentifier(
            "\(DSLayoutInspectorConstants.accessibilityPrefix).\(title)"
        )
    }

    static func outlineColor(for source: DSLayoutRegionSource) -> Color {
        switch source {
        case .view: .orange
        case .accessibility: .cyan
        case .designSystem: .purple
        case .designSystemDetail: .mint
        }
    }
}
#endif
