import SwiftUI
import DesignSystem

public struct DSPlaygroundPreviewCard<Content: View>: View {
    let title: String
    let height: CGFloat
    @Binding var isDarkBackground: Bool
    @ViewBuilder let content: () -> Content
    
    public init(
        title: String,
        height: CGFloat = 220,
        isDarkBackground: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.height = height
        self._isDarkBackground = isDarkBackground
        self.content = content
    }
    
    public var body: some View {
        VStack {
            Spacer()
            
            Text(title)
                .font(.system(.caption2, design: .monospaced))
                .bold()
                .foregroundColor(Color.ds.primary700)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.ds.primary50)
                .cornerRadius(6)
                .padding(.bottom, 12)
            
            content()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(isDarkBackground ? Color.ds.coolGray900 : Color.ds.gray25)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            Button {
                isDarkBackground.toggle()
            } label: {
                Image(systemName: isDarkBackground ? "sun.max.fill" : "moon.fill")
                    .foregroundColor(isDarkBackground ? .yellow : .gray)
                    .padding(16)
            }
        }
        .padding()
    }
}
