import DesignSystem
import SwiftUI

struct MyPageSajuDetailView: View {
    let dashboard: MyPageDashboard
    @Binding var helpSheet: MyPageFeature.HelpSheet?
    let onBack: () -> Void
    let onHelp: (MyPageFeature.HelpSheet) -> Void

    var body: some View {
        VStack(spacing: 0) {
            DSHeaderSub(
                title: "만세력",
                leftItem: DSHeaderActionItem(
                    identifier: "back",
                    icon: .chevronLeftNarrow,
                    action: onBack
                )
            )

            ScrollView {
                VStack(spacing: 32) {
                    MyPageSajuProfileSummary(profile: dashboard.profile)

                    VStack(alignment: .leading, spacing: 16) {
                        MyPageSajuSectionTitle("사주원국") {
                            onHelp(.sajuOriginal)
                        }
                        MyPageSajuOriginalCard(pillars: dashboard.chart.displayPillars)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        MyPageSajuSectionTitle("오행") {
                            onHelp(.ohaeng)
                        }
                        MyPageOhaengCard(ohaengs: dashboard.chart.ohaengs)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .background(Color.ds.white)
        .sheet(item: $helpSheet) { sheet in
            MyPageSajuHelpSheet(sheet: sheet) {
                helpSheet = nil
            }
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
            .presentationBackground(Color.ds.white)
            .presentationDetents([.height(sheet.detentHeight)])
        }
    }
}

private struct MyPageSajuProfileSummary: View {
    let profile: MyPageProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(profile.name)・\(profile.genderText)")
                .dsBody2SemiBold
            HStack(spacing: 8) {
                Text(profile.birthDateCalendarText)
                if let birthTimeText = profile.birthTimeText {
                    Text("・")
                    Text(birthTimeText)
                }
            }
            .dsBody3Regular
        }
        .foregroundStyle(Color.ds.gray975)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.ds.coolGray50, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct MyPageSajuSectionTitle: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .dsBody1Bold
                .foregroundStyle(Color.ds.black)

            Button(action: action) {
                DSIcon(.circleInfoLine, width: 20, height: 20)
            }
            .buttonStyle(.plain)
        }
    }
}

struct MyPageSajuOriginalCard: View {
    let pillars: [MyPagePillar]

    var body: some View {
        VStack(spacing: 8) {
            headerRow
            textRow(title: "십성", values: pillars.map(\.stemSipseong))
            cardRow(title: "천간", isHeavenly: true)
            cardRow(title: "지지", isHeavenly: false)
            textRow(title: "십성", values: pillars.map(\.branchSipseong))
            textRow(title: "지장간", values: pillars.map { $0.hiddenStems.joined() })
            textRow(title: "12운성", values: pillars.map(\.twelveLifeStage))
            textRow(title: "12신살", values: pillars.map(\.twelveSpirit))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.ds.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.ds.gray100, lineWidth: 1)
        }
    }

    private var headerRow: some View {
        HStack(spacing: 8) {
            Color.clear.frame(width: 48, height: 30)
            HStack(spacing: 24) {
                ForEach(pillars) { pillar in
                    VStack(spacing: 4) {
                        Text(pillar.type.title)
                            .dsCaption3Medium
                            .foregroundStyle(Color.ds.gray975)
                        Text(pillar.type.lifeStage)
                            .dsCaption3Regular
                            .foregroundStyle(Color.ds.gray700)
                    }

                    .frame(width: 48)
                }
            }
        }
    }

    private func cardRow(title: String, isHeavenly: Bool) -> some View {
        HStack(spacing: 8) {
            rowTitle(title)
            HStack(spacing: 24) {
                ForEach(pillars) { pillar in
                    MyPageSajuPillarCell(
                        hanja: isHeavenly ? pillar.heavenlyStem : pillar.earthlyBranch,
                        reading: isHeavenly ? pillar.heavenlyReading : pillar.earthlyReading,
                        element: isHeavenly ? pillar.heavenlyElement : pillar.earthlyElement
                    )
                }
            }
        }
    }

    private func textRow(title: String, values: [String?]) -> some View {
        HStack(spacing: 8) {
            rowTitle(title)
            HStack(spacing: 24) {
                ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                    Text(value ?? "-")
                        .dsCaption1Regular
                        .foregroundStyle(Color.ds.gray975)
                        .frame(width: 48)
                }
            }
        }
    }

    private func textRow(title: String, values: [String]) -> some View {
        textRow(title: title, values: values.map(Optional.some))
    }

    private func rowTitle(_ title: String) -> some View {
        Text(title)
            .dsCaption3Regular
            .foregroundStyle(Color.ds.gray500)
            .frame(width: 48, alignment: .leading)
    }
}

private struct MyPageSajuPillarCell: View {
    let hanja: String
    let reading: String
    let element: MyPageElement

    var body: some View {
        VStack(spacing: 1) {
            Text(hanja)
                .font(.system(size: 18, weight: .bold))
            Text("-\(reading)")
                .dsCaption3Regular
        }
        .foregroundStyle(Color.ds.gray975)
        .frame(width: 48, height: 48)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 12))
    }

    private var backgroundColor: Color {
        switch element {
        case .wood: .ds.teal200
        case .fire: .ds.red200
        case .earth: .ds.orange200
        case .metal: .ds.coolGray300
        case .water: .ds.sky200
        case .unknown: .ds.gray100
        }
    }
}

private struct MyPageOhaengCard: View {
    let ohaengs: [MyPageOhaeng]

    var body: some View {
        VStack(spacing: 21) {
            ForEach(ohaengs) { ohaeng in
                MyPageOhaengRow(ohaeng: ohaeng)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.ds.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.ds.gray100, lineWidth: 1)
        }
    }
}

private struct MyPageOhaengRow: View {
    let ohaeng: MyPageOhaeng

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Text("\(ohaeng.element.label) \(ohaeng.element.hanja)")
                    .dsBody2Medium
                Text("\(ohaeng.count)")
                    .dsCaption2SemiBold
                    .foregroundStyle(Color.ds.coolGray500)
                    .frame(width: 20, height: 20)
                    .background(Color.ds.coolGray100, in: RoundedRectangle(cornerRadius: 6))
            }
            .frame(width: 58, alignment: .leading)

            GeometryReader { proxy in
                Capsule()
                    .fill(Color.ds.gray100)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(barColor)
                            .frame(width: proxy.size.width * min(max(ohaeng.percentage / 100, 0), 1))
                    }
            }
            .frame(height: 12)

            DSBadge(status.title, variant: status.badgeVariant)
        }
        .frame(height: 24)
    }

    private var barColor: Color {
        switch ohaeng.element {
        case .wood: .ds.teal300
        case .fire: .ds.red300
        case .earth: .ds.orange300
        case .metal: .ds.coolGray400
        case .water: .ds.sky300
        case .unknown: .ds.gray200
        }
    }

    private var status: MyPageOhaengStatus {
        switch ohaeng.count {
        case ...1: .insufficient
        case 2: .balanced
        default: .developed
        }
    }
}

private enum MyPageOhaengStatus {
    case insufficient
    case balanced
    case developed

    var title: String {
        switch self {
        case .insufficient: "부족"
        case .balanced: "적정"
        case .developed: "발달"
        }
    }

    var badgeVariant: DSBadgeVariant {
        switch self {
        case .insufficient: .gray
        case .balanced: .green
        case .developed: .purple
        }
    }
}

private extension String {
    var title: String {
        switch self {
        case "DAY": "일주"
        case "HOUR": "시주"
        case "MONTH": "월주"
        case "YEAR": "년주"
        default: "-"
        }
    }

    var lifeStage: String {
        switch self {
        case "DAY": "장년운"
        case "HOUR": "말년운"
        case "MONTH": "청년운"
        case "YEAR": "초년운"
        default: ""
        }
    }
}
