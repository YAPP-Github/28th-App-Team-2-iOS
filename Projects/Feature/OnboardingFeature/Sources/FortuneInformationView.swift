import ComposableArchitecture
import DesignSystem
import Model
import SwiftUI

struct FortuneInformationView: View {
    @Bindable private var store: StoreOf<OnboardingFeature>
    @State private var isBirthDatePickerPresented = false
    @State private var isBirthTimePickerPresented = false
    @State private var pickerYear = 1999
    @State private var pickerMonth = 1
    @State private var pickerDay = 1
    @State private var pickerBirthTimeRawValue = BirthTimePeriod.inTime.rawValue

    private let calendar = Calendar(identifier: .gregorian)

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

                    DSSelectGender(selection: genderBinding)
                    DSSelectLunarOrSolarCalendar(selection: birthDateCalendarBinding)
                    VStack(alignment: .leading, spacing: 8) {
                        DSEnterDateOfBirth(
                            selection: birthDateBinding,
                            isFocused: isBirthDatePickerPresented
                        ) {
                            prepareBirthDatePicker()
                            isBirthDatePickerPresented = true
                        }

                        if let message = store.birthDateAgeValidationMessage {
                            Text(message)
                                .dsCaption1Regular
                                .foregroundStyle(Color.ds.red500)
                                .padding(.horizontal, 4)
                        }
                    }
                    DSEnterTimeOfBirth(
                        selection: birthTimePeriodBinding,
                        isFocused: isBirthTimePickerPresented,
                        isTimeUnknown: birthTimeUnknownBinding
                    ) {
                        prepareBirthTimePicker()
                        isBirthTimePickerPresented = true
                    }

                    if store.isBirthTimeUnknown {
                        Text("정확한 시간을 모르면 정오 기준으로 운세가 계산돼요.")
                            .dsCaption1Regular
                            .foregroundStyle(Color.ds.sky600)
                    }
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
        .dsWheelPickerSheet(
            isPresented: $isBirthDatePickerPresented,
            layout: .date,
            title: "생년월일 입력",
            onSave: saveBirthDate
        ) {
            DSMultiWheelPicker(
                layout: .date,
                columns: [
                    DSWheelPickerColumn(
                        items: birthYearItems,
                        selection: $pickerYear,
                        accessibilityLabel: "연도"
                    ),
                    DSWheelPickerColumn(
                        items: birthMonthItems,
                        selection: $pickerMonth,
                        accessibilityLabel: "월",
                        isCircular: true
                    ),
                    DSWheelPickerColumn(
                        items: birthDayItems,
                        selection: $pickerDay,
                        accessibilityLabel: "일"
                    )
                ]
            )
        }
        .dsWheelPickerSheet(
            isPresented: $isBirthTimePickerPresented,
            layout: .single,
            title: "태어난 시각 선택",
            onSave: saveBirthTime
        ) {
            DSSingleWheelPicker(
                items: birthTimeItems,
                selection: $pickerBirthTimeRawValue,
                accessibilityLabel: "태어난 시각"
            )
        }
        .onChange(of: pickerYear) { _, _ in
            normalizeBirthDatePicker()
        }
        .onChange(of: pickerMonth) { _, _ in
            normalizeBirthDatePicker()
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

    var currentDateComponents: DateComponents {
        calendar.dateComponents([.year, .month, .day], from: Date())
    }

    var birthYearItems: [DSWheelPickerItem] {
        (1900...(currentDateComponents.year ?? 1900)).map {
            DSWheelPickerItem(value: $0, title: "\($0)년")
        }
    }

    var birthMonthItems: [DSWheelPickerItem] {
        let maximumMonth = pickerYear == currentDateComponents.year
            ? currentDateComponents.month ?? 12
            : 12

        return (1...maximumMonth).map {
            DSWheelPickerItem(value: $0, title: "\($0)월")
        }
    }

    var birthDayItems: [DSWheelPickerItem] {
        let date = calendar.date(from: DateComponents(year: pickerYear, month: pickerMonth)) ?? Date()
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 28
        let maximumDay = pickerYear == currentDateComponents.year
            && pickerMonth == currentDateComponents.month
            ? min(daysInMonth, currentDateComponents.day ?? daysInMonth)
            : daysInMonth

        return (1...maximumDay).map {
            DSWheelPickerItem(value: $0, title: "\($0)일")
        }
    }

    var birthTimeItems: [DSWheelPickerItem] {
        BirthTimePeriod.allCases.map { period in
            DSWheelPickerItem(
                value: period.rawValue,
                title: DSEnterTimeOfBirth.pickerTitle(for: period)
            )
        }
    }

    func prepareBirthDatePicker() {
        let selected = store.birthDate
        pickerYear = selected?.year ?? 1999
        pickerMonth = selected?.month ?? 1
        pickerDay = selected?.day ?? 1
        normalizeBirthDatePicker()
    }

    func prepareBirthTimePicker() {
        pickerBirthTimeRawValue = (store.birthTimePeriod ?? .inTime).rawValue
    }

    func saveBirthDate() {
        store.send(.birthDateChanged(BirthDate(year: pickerYear, month: pickerMonth, day: pickerDay)))
        isBirthDatePickerPresented = false
    }

    func saveBirthTime() {
        store.send(.birthTimePeriodChanged(BirthTimePeriod(rawValue: pickerBirthTimeRawValue)))
        isBirthTimePickerPresented = false
    }

    func normalizeBirthDatePicker() {
        if let maximumMonth = birthMonthItems.last?.value {
            pickerMonth = min(max(pickerMonth, 1), maximumMonth)
        }

        if let maximumDay = birthDayItems.last?.value {
            pickerDay = min(max(pickerDay, 1), maximumDay)
        }
    }
}
