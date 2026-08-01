import SwiftUI
import DesignSystem

struct HeaderPlaygroundView: View {
    private enum HeaderKind: String, CaseIterable {
        case main = "Main"
        case sub = "Sub"
    }

    @State private var headerKind: HeaderKind = .main
    @State private var mainTitle = "Title"
    @State private var mainSubtitle = "subtext"
    @State private var subTitle = "택일 운세"
    @State private var showsSubtitle = true
    @State private var showsLeftAction = true
    @State private var showsRightAction = true
    @State private var lastTappedButton = "아직 눌린 버튼이 없습니다."
    @State private var isDarkBackground = false

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: headerKind == .main
                    ? String(describing: DSHeaderMain.self)
                    : String(describing: DSHeaderSub.self),
                isDarkBackground: $isDarkBackground
            ) {
                switch headerKind {
                case .main:
                    DSHeaderMain(
                        title: mainTitle,
                        subtitle: showsSubtitle ? mainSubtitle : nil,
                        rightItem: showsRightAction ? mainRightItem : nil
                    )
                case .sub:
                    DSHeaderSub(
                        title: subTitle,
                        leftItem: showsLeftAction ? subLeftItem : nil,
                        rightItem: showsRightAction ? subRightItem : nil
                    )
                }
            }

            Form {
                Section(header: Text("Variant")) {
                    Picker("Header", selection: $headerKind) {
                        ForEach(HeaderKind.allCases, id: \.self) { kind in
                            Text(kind.rawValue).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Content")) {
                    switch headerKind {
                    case .main:
                        TextField("Title", text: $mainTitle)
                        TextField("Subtitle", text: $mainSubtitle)
                    case .sub:
                        TextField("Title", text: $subTitle)
                    }
                }

                Section(header: Text("Interactive State")) {
                    if headerKind == .main {
                        Toggle("Subtitle", isOn: $showsSubtitle)
                    } else {
                        Toggle("Left Action", isOn: $showsLeftAction)
                    }
                    Toggle("Right Action", isOn: $showsRightAction)

                    Text(lastTappedButton)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Figma Specification Check")) {
                    specificationRows
                }
            }
        }
        .navigationTitle(headerKind == .main ? "DSHeaderMain" : "DSHeaderSub")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var specificationRows: some View {
        switch headerKind {
        case .main:
            let spec = DSHeaderMain.specification()
            DSSpecificationRow(title: "Background", value: spec.backgroundAsset.specDescription)
            DSSpecificationRow(title: "Content Height", value: spec.contentHeight.ptDescription)
            DSSpecificationRow(title: "Horizontal Padding", value: spec.horizontalPadding.ptDescription)
            DSSpecificationRow(title: "Title Group Gap", value: spec.titleGroupGap.ptDescription)
            DSSpecificationRow(title: "Title Font", value: spec.titleFontStyle.specName)
            DSSpecificationRow(title: "Title Text", value: spec.titleTextAsset.specDescription)
            DSSpecificationRow(title: "Subtitle Font", value: spec.subtitleFontStyle.specName)
            DSSpecificationRow(title: "Subtitle Text", value: spec.subtitleTextAsset.specDescription)
            DSSpecificationRow(title: "Action Icon Size", value: spec.actionIconSize.ptDescription)
            DSSpecificationRow(title: "Action Icon Tint", value: spec.actionIconTintAsset.specDescription)
        case .sub:
            let spec = DSHeaderSub.specification()
            DSSpecificationRow(title: "Background", value: spec.backgroundAsset.specDescription)
            DSSpecificationRow(title: "Content Height", value: spec.contentHeight.ptDescription)
            DSSpecificationRow(title: "Horizontal Padding", value: spec.horizontalPadding.ptDescription)
            DSSpecificationRow(title: "Title Font", value: spec.titleFontStyle.specName)
            DSSpecificationRow(title: "Title Text", value: spec.titleTextAsset.specDescription)
            DSSpecificationRow(title: "Action Icon Size", value: spec.actionIconSize.ptDescription)
            DSSpecificationRow(title: "Action Icon Tint", value: spec.actionIconTintAsset.specDescription)
        }
    }

    private var mainRightItem: DSHeaderActionItem {
        DSHeaderActionItem(identifier: "notification", icon: .bell) {
            lastTappedButton = "Main 우측 알림 버튼"
        }
    }

    private var subLeftItem: DSHeaderActionItem {
        DSHeaderActionItem(identifier: "back", icon: .chevronLeftNarrow) {
            lastTappedButton = "Sub 좌측 뒤로가기 버튼"
        }
    }

    private var subRightItem: DSHeaderActionItem {
        DSHeaderActionItem(identifier: "close", icon: .deleteLine) {
            lastTappedButton = "Sub 우측 닫기 버튼"
        }
    }
}

#Preview {
    NavigationStack {
        HeaderPlaygroundView()
    }
}
