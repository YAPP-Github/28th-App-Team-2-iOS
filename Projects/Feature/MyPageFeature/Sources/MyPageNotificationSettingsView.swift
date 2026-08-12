import ComposableArchitecture
import DesignSystem
import SwiftUI
import UIKit

struct MyPageNotificationSettingsView: View {
    @Bindable var store: StoreOf<MyPageFeature>

    var body: some View {
        ZStack {
            Color.ds.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                DSHeaderSub(
                    title: "알림 설정",
                    leftItem: DSHeaderActionItem(
                        identifier: "notification-settings-back",
                        icon: .chevronLeftNarrow,
                        action: { store.send(.notificationSettingsDismissButtonTapped) }
                    )
                )

                content
            }
        }
        .task { store.send(.notificationSettingsTask) }
        .dsWheelPickerSheet(
            isPresented: Binding(
                get: { store.notificationSettings?.isTimePickerPresented ?? false },
                set: { store.send(.notificationSettingsTimePickerPresented($0)) }
            ),
            layout: .time,
            title: "받을 시간 입력",
            onSave: { store.send(.notificationSettingsTimeSaveButtonTapped) },
            content: {
                DSMultiWheelPicker(
                    layout: .time,
                    columns: [
                        DSWheelPickerColumn(
                            items: (0..<24).map {
                                DSWheelPickerItem(value: $0, title: String(format: "%02d", $0))
                            },
                            selection: Binding(
                                get: { store.notificationSettings?.pickerHour ?? 8 },
                                set: { store.send(.notificationSettingsPickerHourChanged($0)) }
                            ),
                            accessibilityLabel: "시"
                        ),
                        DSWheelPickerColumn(
                            items: [0, 30].map {
                                DSWheelPickerItem(value: $0, title: String(format: "%02d", $0))
                            },
                            selection: Binding(
                                get: { store.notificationSettings?.pickerMinute ?? 0 },
                                set: { store.send(.notificationSettingsPickerMinuteChanged($0)) }
                            ),
                            accessibilityLabel: "분"
                        )
                    ]
                )
            }
        )
        .alert(
            "알림 권한이 필요해요",
            isPresented: Binding(
                get: { store.notificationSettings?.isPermissionAlertPresented ?? false },
                set: { store.send(.notificationPermissionAlertPresented($0)) }
            )
        ) {
            Button("설정으로 이동") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("iPhone 설정에서 토닥운의 알림을 허용해주세요.")
        }
    }

    @ViewBuilder
    private var content: some View {
        if let notificationSettings = store.notificationSettings,
           let settings = notificationSettings.settings {
            ScrollView {
                VStack(spacing: 16) {
                    morningReportCard(settings)
                    toggleCard(
                        title: "토닥이 알림",
                        subtitle: "토닥이 답변 완료 시 알림",
                        isOn: settings.todakiEnabled,
                        toggle: .todaki
                    )
                    toggleCard(
                        title: "행운 액션 리마인드",
                        subtitle: "실천 타이밍 알림",
                        isOn: settings.luckyActionReminderEnabled,
                        toggle: .luckyActionReminder
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 28)
            }
        } else if store.notificationSettings?.error != nil {
            ContentUnavailableView(
                "알림 설정을 불러오지 못했어요",
                systemImage: "bell.slash"
            )
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func morningReportCard(_ settings: NotificationSettings) -> some View {
        VStack(spacing: 16) {
            settingRow(
                title: "아침 운 리포트",
                subtitle: "매일 아침 오늘의 운세",
                isOn: settings.morningReportEnabled,
                toggle: .morningReport
            )

            Button {
                store.send(.notificationSettingsTimeButtonTapped)
            } label: {
                HStack {
                    Text("받을 시간")
                        .dsBody3Medium
                        .foregroundStyle(Color.ds.gray500)
                    Spacer(minLength: 16)
                    Text(settings.morningReportTime.displayText)
                        .dsBody3Medium
                        .foregroundStyle(Color.ds.gray975)
                    DSIcon(.chevronSmallRight, width: 20, height: 20)
                        .foregroundStyle(Color.ds.gray500)
                }
                .frame(height: 20)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!settings.morningReportEnabled)
            .opacity(settings.morningReportEnabled ? 1 : 0.45)
        }
        .padding(20)
        .notificationSettingsCardStyle()
    }

    private func toggleCard(
        title: String,
        subtitle: String,
        isOn: Bool,
        toggle: NotificationSettingToggle
    ) -> some View {
        settingRow(title: title, subtitle: subtitle, isOn: isOn, toggle: toggle)
            .padding(20)
            .notificationSettingsCardStyle()
    }

    private func settingRow(
        title: String,
        subtitle: String,
        isOn: Bool,
        toggle: NotificationSettingToggle
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .dsBody2Medium
                    .foregroundStyle(Color.ds.gray975)
                Text(subtitle)
                    .dsBody3Medium
                    .foregroundStyle(Color.ds.gray500)
            }

            Spacer(minLength: 8)

            DSToggle(
                isOn: Binding(
                    get: { isOn },
                    set: { store.send(.notificationSettingToggleChanged(toggle, $0)) }
                )
            )
        }
        .frame(minHeight: 52, alignment: .top)
    }
}

private extension View {
    func notificationSettingsCardStyle() -> some View {
        background(Color.ds.white, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.ds.gray200, lineWidth: 1)
            }
    }
}
