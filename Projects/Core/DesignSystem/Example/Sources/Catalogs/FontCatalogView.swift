import SwiftUI
import DesignSystem

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
