import SwiftUI
import DesignSystem

// MARK: - Font Catalog
struct FontCatalogView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                fontSection(title: "Headings") {
                    Text(sampleText("Heading 1 ExtraBold", style: .heading1ExtraBold)).dsHeading1ExtraBold
                    Text(sampleText("Heading 1 Bold", style: .heading1Bold)).dsHeading1Bold
                    Text(sampleText("Heading 1 SemiBold", style: .heading1SemiBold)).dsHeading1SemiBold

                    Text(sampleText("Heading 2 ExtraBold", style: .heading2ExtraBold)).dsHeading2ExtraBold
                    Text(sampleText("Heading 2 Bold", style: .heading2Bold)).dsHeading2Bold
                    Text(sampleText("Heading 2 SemiBold", style: .heading2SemiBold)).dsHeading2SemiBold

                    Text(sampleText("Heading 3 Bold", style: .heading3Bold)).dsHeading3Bold
                    Text(sampleText("Heading 3 Medium", style: .heading3Medium)).dsHeading3Medium
                    Text(sampleText("Heading 3 Regular", style: .heading3Regular)).dsHeading3Regular

                    Text(sampleText("Heading 4 Bold", style: .heading4Bold)).dsHeading4Bold
                    Text(sampleText("Heading 4 Medium", style: .heading4Medium)).dsHeading4Medium
                    Text(sampleText("Heading 4 Regular", style: .heading4Regular)).dsHeading4Regular
                }

                fontSection(title: "Bodies") {
                    Text(sampleText("Body 1 Bold", style: .body1Bold)).dsBody1Bold
                    Text(sampleText("Body 1 Medium", style: .body1Medium)).dsBody1Medium
                    Text(sampleText("Body 1 Regular", style: .body1Regular)).dsBody1Regular

                    Text(sampleText("Body 2 SemiBold", style: .body2SemiBold)).dsBody2SemiBold
                    Text(sampleText("Body 2 Medium", style: .body2Medium)).dsBody2Medium
                    Text(sampleText("Body 2 Regular", style: .body2Regular)).dsBody2Regular

                    Text(sampleText("Body 3 SemiBold", style: .body3SemiBold)).dsBody3SemiBold
                    Text(sampleText("Body 3 Medium", style: .body3Medium)).dsBody3Medium
                    Text(sampleText("Body 3 Regular", style: .body3Regular)).dsBody3Regular
                }

                fontSection(title: "Captions") {
                    Text(sampleText("Caption 1 SemiBold", style: .caption1SemiBold)).dsCaption1SemiBold
                    Text(sampleText("Caption 1 Medium", style: .caption1Medium)).dsCaption1Medium
                    Text(sampleText("Caption 1 Regular", style: .caption1Regular)).dsCaption1Regular

                    Text(sampleText("Caption 2 SemiBold", style: .caption2SemiBold)).dsCaption2SemiBold
                    Text(sampleText("Caption 2 Medium", style: .caption2Medium)).dsCaption2Medium
                    Text(sampleText("Caption 2 Regular", style: .caption2Regular)).dsCaption2Regular

                    Text(sampleText("Caption 3 SemiBold", style: .caption3SemiBold)).dsCaption3SemiBold
                    Text(sampleText("Caption 3 Medium", style: .caption3Medium)).dsCaption3Medium
                    Text(sampleText("Caption 3 Regular", style: .caption3Regular)).dsCaption3Regular
                }
            }
            .padding()
        }
    }

    private func sampleText(_ name: String, style: FontStyle) -> String {
        "\(name)\n크기 \(style.size.ptDescription) · 행간 \(style.lineHeight.ptDescription)\n고정 행간 적용 확인 텍스트입니다."
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
