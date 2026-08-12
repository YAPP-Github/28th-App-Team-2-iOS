import DesignSystem
import SwiftUI
import ComposableArchitecture

public struct MyPageView: View {
    @Bindable private var store: StoreOf<MyPageFeature>
    @Environment(\.openURL) private var openURL
    @State private var isSupportMailAlertPresented = false

    public init(store: StoreOf<MyPageFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            if store.withdrawal?.isAgreementPresented == true {
                MyPageWithdrawalAgreementView(store: store)
            } else if store.withdrawal != nil {
                MyPageWithdrawalReasonView(store: store)
            } else if store.appSettings != nil {
                MyPageAppSettingsView(store: store)
            } else if store.notificationSettings != nil {
                MyPageNotificationSettingsView(store: store)
            } else if store.edit != nil {
                MyPageEditView(store: store)
            } else if store.sajuDetail != nil, let dashboard = store.dashboard {
                MyPageSajuDetailView(
                    dashboard: dashboard,
                    helpSheet: Binding(
                        get: { store.sajuDetail?.helpSheet },
                        set: { _ in store.send(.sajuDetailHelpSheetDismissed) }
                    ),
                    onBack: { store.send(.sajuDetailDismissButtonTapped) },
                    onHelp: { store.send(.sajuDetailHelpButtonTapped($0)) }
                )
            } else {
                mainPage
            }

            if store.isLogoutConfirmationPresented {
                logoutConfirmationOverlay
            }
        }
        .alert(
            "로그아웃하지 못했어요",
            isPresented: Binding(
                get: { store.logoutError != nil },
                set: { _ in store.send(.accountSettings(.dismissLogoutError)) }
            )
        ) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("로그아웃에 실패했어요. 다시 시도해주세요.")
        }
        .alert("문의 메일을 열 수 없어요", isPresented: $isSupportMailAlertPresented) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("잠시 후 다시 시도해 주세요.")
        }
    }

    private var mainPage: some View {
        ZStack(alignment: .top) {
            Color.ds.white
                .ignoresSafeArea()

            LinearGradient(
                colors: [Color.ds.primary50, Color.ds.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 408)
            .ignoresSafeArea(.container, edges: .top)

            VStack(spacing: 0) {
                HStack {
                    Text("My Page")
                        .dsHeading4Bold
                        .foregroundStyle(Color.ds.gray975)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .frame(height: 60)

                content
            }
        }
        .task { store.send(.task) }
    }

    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(spacing: 32) {
                if let dashboard = store.dashboard {
                    MyPageProfileCard(
                        dashboard: dashboard,
                        onEdit: { store.send(.editButtonTapped) },
                        onCalendar: { store.send(.calendarButtonTapped) }
                    )
                } else if case .failed = store.phase {
                    MyPageProfileCardFailure {
                        store.send(.retryButtonTapped)
                    }
                } else {
                    MyPageProfileCardSkeleton()
                }

                Rectangle()
                    .fill(Color.ds.gray25)
                    .frame(height: 10)
                    .frame(maxWidth: .infinity)

                MyPageMenuList { item in
                    if item == .inquiry {
                        openSupportMail()
                    } else {
                        store.send(.menuItemTapped(item))
                    }
                }
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 28)
    }

    private var logoutConfirmationOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                DSDialog(
                    title: "로그아웃하시겠어요?",
                    message: "언제든 다시 로그인할 수 있어요.",
                    primaryAction: DSDialog.Action("확인") {
                        store.send(.accountSettings(.confirmLogout))
                    },
                    secondaryAction: DSDialog.Action("취소") {
                        store.send(.accountSettings(.logoutConfirmationPresented(false)))
                    }
                )
            }
    }

    private func openSupportMail() {
        guard let url = URL(string: "mailto:support@todakun.com") else {
            isSupportMailAlertPresented = true
            return
        }
        openURL(url) { accepted in
            if !accepted {
                isSupportMailAlertPresented = true
            }
        }
    }
}

private struct MyPageProfileCardSkeleton: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    placeholder(width: 132, height: 28)
                    placeholder(width: 198, height: 20)
                }

                Spacer(minLength: 12)
                placeholder(width: 60, height: 32)
            }

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ds.coolGray50)
                .frame(height: 156)

            placeholder(width: nil, height: 44)
        }
        .padding(20)
        .background(Color.ds.white, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 5, y: 4)
        .padding(.horizontal, 20)
        .redacted(reason: .placeholder)
    }

    @ViewBuilder
    private func placeholder(width: CGFloat?, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.ds.gray100)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
    }
}

private struct MyPageProfileCardFailure: View {
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("마이페이지를 불러오지 못했어요")
                .dsBody2Medium
                .foregroundStyle(Color.ds.gray975)
            Button("다시 시도", action: retry)
                .dsBody3Medium
                .foregroundStyle(Color.ds.primary600)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .padding(20)
        .background(Color.ds.white, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 5, y: 4)
        .padding(.horizontal, 20)
    }
}

private struct MyPageProfileCard: View {
    let dashboard: MyPageDashboard
    let onEdit: () -> Void
    let onCalendar: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(dashboard.profile.name)
                            .dsHeading3Bold
                            .foregroundStyle(Color.ds.gray975)
                        Text("·")
                            .dsBody2Regular
                            .foregroundStyle(Color.ds.coolGray700)
                        Text(dashboard.profile.genderText)
                            .dsBody2Regular
                            .foregroundStyle(Color.ds.coolGray700)
                    }
                    ProfileBirthInformation(profile: dashboard.profile)
                }

                Spacer(minLength: 12)

                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Text("수정")
                    }
                    .dsCaption1SemiBold
                    .foregroundStyle(Color.ds.primary600)
                }
                    .frame(width: 60, height: 32)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.ds.primary500, lineWidth: 1)
                    }
            }

            MyPagePillarsGrid(pillars: dashboard.chart.displayPillars)

            DSButton("만세력 보기", size: .medium, action: onCalendar)
                .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color.ds.white, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 5, y: 4)
        .padding(.horizontal, 20)
    }
}

private struct ProfileBirthInformation: View {
    let profile: MyPageProfile

    var body: some View {
        ViewThatFits(in: .horizontal) {
            informationLine

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.birthDateCalendarText)
                if let birthTimeText = profile.birthTimeText {
                    HStack(spacing: 8) {
                        Text("·")
                        Text(birthTimeText)
                    }
                }
            }
        }
        .dsBody3Medium
        .foregroundStyle(Color.ds.coolGray700)
    }

    @ViewBuilder
    private var informationLine: some View {
        HStack(spacing: 8) {
            Text(profile.birthDateCalendarText)
            if let birthTimeText = profile.birthTimeText {
                Text("·")
                Text(birthTimeText)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

private struct MyPagePillarsGrid: View {
    let pillars: [MyPagePillar]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 24), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(pillars) { pillar in
                PillarCell(
                    hanja: pillar.heavenlyStem,
                    reading: pillar.heavenlyReading,
                    element: pillar.heavenlyElement
                )
                PillarCell(
                    hanja: pillar.earthlyBranch,
                    reading: pillar.earthlyReading,
                    element: pillar.earthlyElement
                )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.ds.coolGray50, in: RoundedRectangle(cornerRadius: 12))
    }

}

private struct PillarCell: View {
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
