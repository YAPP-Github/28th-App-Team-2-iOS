import ComposableArchitecture

extension MyPageFeature {
    // 알림 화면의 모든 사용자 이벤트를 한 곳에서 상태 전이시키기 위해 단일 switch로 관리한다.
    // swiftlint:disable:next cyclomatic_complexity
    func reduceNotificationSettings(
        _ state: inout State,
        action: Action
    ) -> Effect<Action>? {
        switch action {
        case let .menuItemTapped(.notificationSettings):
            state.notificationSettings = NotificationSettingsState()
            return .none

        case .notificationSettingsTask:
            guard state.notificationSettings?.settings == nil else { return .none }
            return .run { send in
                await send(
                    .notificationSettingsResponse(
                        Result { try await myPageClient.loadNotificationSettings() }
                            .mapError(MyPageClientError.init)
                    )
                )
            }

        case let .notificationSettingsResponse(.success(settings)):
            state.notificationSettings?.settings = settings
            state.notificationSettings?.pickerHour = settings.morningReportTime.hour
            state.notificationSettings?.pickerMinute = settings.morningReportTime.minute
            state.notificationSettings?.error = nil
            return .none

        case let .notificationSettingsResponse(.failure(error)):
            state.notificationSettings?.error = error
            return .none

        case .notificationSettingsDismissButtonTapped:
            state.notificationSettings = nil
            return .none

        case let .notificationSettingToggleChanged(toggle, enabled):
            guard let settings = state.notificationSettings?.settings else { return .none }

            if !enabled {
                return updateNotificationSettingsEffect(settings.updating(toggle, enabled: false))
            }

            return .run { send in
                await send(
                    .notificationToggleAuthorizationStatus(
                        toggle,
                        await notificationSettingsAuthorizationClient.authorizationStatus()
                    )
                )
            }

        case let .notificationToggleAuthorizationStatus(toggle, authorizationStatus):
            switch authorizationStatus {
            case .authorized:
                guard let settings = state.notificationSettings?.settings else { return .none }
                return syncOSPushPermissionAndUpdateEffect(settings.updating(toggle, enabled: true))

            case .notDetermined:
                return .run { send in
                    await send(
                        .notificationToggleAuthorizationRequest(
                            toggle,
                            await notificationSettingsAuthorizationClient.requestAuthorization()
                        )
                    )
                }

            case .denied:
                state.notificationSettings?.isPermissionAlertPresented = true
                return syncOSPushPermissionEffect(granted: false)
            }

        case let .notificationToggleAuthorizationRequest(toggle, authorizationStatus):
            switch authorizationStatus {
            case .authorized:
                guard let settings = state.notificationSettings?.settings else { return .none }
                return syncOSPushPermissionAndUpdateEffect(settings.updating(toggle, enabled: true))
            case .notDetermined, .denied:
                state.notificationSettings?.isPermissionAlertPresented = true
                return syncOSPushPermissionEffect(granted: false)
            }

        case let .notificationSettingsUpdateResponse(.success(settings)):
            state.notificationSettings?.settings = settings
            state.notificationSettings?.pickerHour = settings.morningReportTime.hour
            state.notificationSettings?.pickerMinute = settings.morningReportTime.minute
            state.notificationSettings?.error = nil
            return .none

        case let .notificationSettingsUpdateResponse(.failure(error)):
            state.notificationSettings?.error = error
            return .none

        case .notificationSettingsTimeButtonTapped:
            guard let settings = state.notificationSettings?.settings,
                  settings.morningReportEnabled else { return .none }
            state.notificationSettings?.pickerHour = settings.morningReportTime.hour
            state.notificationSettings?.pickerMinute = settings.morningReportTime.minute
            state.notificationSettings?.isTimePickerPresented = true
            return .none

        case let .notificationSettingsTimePickerPresented(isPresented):
            state.notificationSettings?.isTimePickerPresented = isPresented
            return .none

        case let .notificationSettingsPickerHourChanged(hour):
            state.notificationSettings?.pickerHour = min(max(hour, 0), 23)
            return .none

        case let .notificationSettingsPickerMinuteChanged(minute):
            state.notificationSettings?.pickerMinute = minute == 30 ? 30 : 0
            return .none

        case .notificationSettingsTimeSaveButtonTapped:
            guard let settings = state.notificationSettings?.settings,
                  let notificationSettings = state.notificationSettings else { return .none }
            state.notificationSettings?.isTimePickerPresented = false
            var updatedSettings = settings
            updatedSettings.morningReportTime = NotificationTime(
                hour: notificationSettings.pickerHour,
                minute: notificationSettings.pickerMinute
            )
            return updateNotificationSettingsEffect(updatedSettings)

        case let .notificationPermissionAlertPresented(isPresented):
            state.notificationSettings?.isPermissionAlertPresented = isPresented
            return .none

        default:
            return nil
        }
    }

    private func updateNotificationSettingsEffect(_ settings: NotificationSettings) -> Effect<Action> {
        .run { send in
            await send(
                .notificationSettingsUpdateResponse(
                    Result { try await myPageClient.updateNotificationSettings(settings) }
                        .mapError(MyPageClientError.init)
                )
            )
        }
    }

    private func syncOSPushPermissionAndUpdateEffect(_ settings: NotificationSettings) -> Effect<Action> {
        .run { send in
            _ = try? await myPageClient.syncOSPushPermission(true)
            await send(
                .notificationSettingsUpdateResponse(
                    Result { try await myPageClient.updateNotificationSettings(settings) }
                        .mapError(MyPageClientError.init)
                )
            )
        }
    }

    private func syncOSPushPermissionEffect(granted: Bool) -> Effect<Action> {
        .run { _ in
            _ = try? await myPageClient.syncOSPushPermission(granted)
        }
    }
}

private extension NotificationSettings {
    func updating(_ toggle: NotificationSettingToggle, enabled: Bool) -> Self {
        var settings = self
        settings.set(toggle, enabled: enabled)
        return settings
    }
}
