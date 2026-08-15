import DesignSystem
import SwiftUI

struct FortuneHeaderView: View {
    let title: String
    let isDark: Bool
    let action: () -> Void

    init(title: String, isDark: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isDark = isDark
        self.action = action
    }

    var body: some View {
        HStack {
            Button(action: action) {
                DSIcon(.chevronLeftNarrow, width: 24, height: 24)
                    .foregroundStyle(isDark ? Color.ds.white : Color.ds.gray975)
                    .frame(width: 44, height: 44)
            }
            .dsIconButtonStyle(.chevronLeftNarrow, width: 24, height: 24)

            Spacer()

            Text(title)
                .dsBody2SemiBold
                .foregroundStyle(isDark ? Color.ds.white : Color.ds.gray975)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 10)
        .frame(height: 52)
    }
}

struct FortuneErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.ds.red500)

            Text(message)
                .dsBody3Medium
                .foregroundStyle(Color.ds.red500)

            Spacer()
        }
        .padding(12)
        .background(Color.ds.red500.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
