import ComposableArchitecture
import DesignSystem
import Model
import SwiftUI

struct FortuneInformationView: View {
    @Bindable private var store: StoreOf<OnboardingFeature>

    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            DSProgressBar(progress: 0.5) {
                store.send(.onboardingBackButtonTapped)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    Text(fortuneInformationTitle)
                        .dsHeading2SemiBold

                    DSSajuBasicFieldsView(
                        gender: genderBinding,
                        calendarType: birthDateCalendarBinding,
                        birthDate: birthDateBinding,
                        birthTime: birthTimePeriodBinding,
                        isBirthTimeUnknown: birthTimeUnknownBinding,
                        birthDateValidationMessage: store.birthDateAgeValidationMessage,
                        unknownTimeInfoText: "정확한 시간을 모르면 정오 기준으로 운세가 계산돼요.",
                        spacing: 32
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 64)
                .padding(.bottom, 24)
            }

            DSPrimaryLargeButton("다음") {
                store.send(.fortuneInformationNextButtonTapped)
            }
            .disabled(!store.isFortuneInformationValid)
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
    }
}

private extension FortuneInformationView {
    var fortuneInformationTitle: AttributedString {
        var title = AttributedString("정확한 운세를 위해,\n태어난 정보가 필요해요.")
        title.font = .ds.font(.heading2SemiBold)
        title.foregroundColor = Color.ds.gray975

        if let birthInformationRange = title.range(of: "태어난 정보") {
            title[birthInformationRange].font = .ds.font(.heading2Bold)
            title[birthInformationRange].foregroundColor = Color.ds.primary700
        }

        return title
    }

    var genderBinding: Binding<Gender?> {
        Binding(
            get: { store.gender },
            set: { store.send(.genderChanged($0)) }
        )
    }

    var birthDateCalendarBinding: Binding<BirthDateCalendar?> {
        Binding(
            get: { store.birthDateCalendar },
            set: { store.send(.birthDateCalendarChanged($0)) }
        )
    }

    var birthDateBinding: Binding<BirthDate?> {
        Binding(
            get: { store.birthDate },
            set: { store.send(.birthDateChanged($0)) }
        )
    }

    var birthTimePeriodBinding: Binding<BirthTimePeriod?> {
        Binding(
            get: { store.birthTimePeriod },
            set: { store.send(.birthTimePeriodChanged($0)) }
        )
    }

    var birthTimeUnknownBinding: Binding<Bool> {
        Binding(
            get: { store.isBirthTimeUnknown },
            set: { store.send(.birthTimeUnknownChanged($0)) }
        )
    }
}
