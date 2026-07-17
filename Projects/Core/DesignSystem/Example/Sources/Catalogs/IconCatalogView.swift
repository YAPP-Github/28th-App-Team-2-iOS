import SwiftUI
import DesignSystem

struct IconCatalogView: View {
    @State private var isDarkBackground = false

    private let icons: [DesignSystemImages] = [
        DesignSystemAsset.Icons.checkLine,
        DesignSystemAsset.Icons.edit
    ]

    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]

    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                Button {
                    isDarkBackground.toggle()
                } label: {
                    Image(systemName: isDarkBackground ? "sun.max.fill" : "moon.fill")
                        .foregroundColor(isDarkBackground ? .yellow : .gray)
                        .padding()
                        .background(isDarkBackground ? Color.ds.gray900 : Color.ds.gray100)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(icons, id: \.name) { icon in
                    VStack {
                        icon.swiftUIImage
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(isDarkBackground ? Color.ds.white : Color.ds.gray900)
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(isDarkBackground ? Color.ds.coolGray900 : Color.ds.gray50)
                            .cornerRadius(12)

                        Text(icon.displayName)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(isDarkBackground ? Color.ds.gray300 : Color.ds.gray600)
                    }
                }
            }
            .padding()
        }
        .background(isDarkBackground ? Color.ds.black : Color.ds.white)
    }
}
