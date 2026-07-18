#if DEBUG
import SwiftUI

struct DSLayoutInspectorActivationHandle: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "ruler")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.yellow)
                .frame(width: 30, height: 48)
                .background(
                    .black.opacity(0.82),
                    in: RoundedRectangle(cornerRadius: 10)
                )
                .shadow(color: .black.opacity(0.18), radius: 3, y: 1)
                .frame(width: 44, height: 48)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("레이아웃 검사기 열기")
        .accessibilityHint("위아래로 드래그해 위치를 옮길 수 있습니다.")
        .accessibilityIdentifier(
            "\(DSLayoutInspectorConstants.accessibilityPrefix).activationHandle"
        )
    }
}
#endif
