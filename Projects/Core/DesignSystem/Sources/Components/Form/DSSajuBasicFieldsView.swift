import SwiftUI
import Model

public struct DSSajuBasicFieldsView: View {
    @Binding private var gender: Gender?
    @Binding private var calendarType: BirthDateCalendar?
    @Binding private var birthDate: BirthDate?
    @Binding private var birthTime: BirthTimePeriod?
    @Binding private var isBirthTimeUnknown: Bool

    private let birthDateValidationMessage: String?
    private let unknownTimeInfoText: String?
    private let spacing: CGFloat

    @State private var isDatePickerPresented = false
    @State private var isTimePickerPresented = false
    @State private var pickerYear: Int = 1999
    @State private var pickerMonth: Int = 1
    @State private var pickerDay: Int = 1
    @State private var pickerBirthTimeRawValue: Int = BirthTimePeriod.inTime.rawValue

    private let calendar = Calendar(identifier: .gregorian)

    public init(
        gender: Binding<Gender?>,
        calendarType: Binding<BirthDateCalendar?>,
        birthDate: Binding<BirthDate?>,
        birthTime: Binding<BirthTimePeriod?>,
        isBirthTimeUnknown: Binding<Bool>,
        birthDateValidationMessage: String? = nil,
        unknownTimeInfoText: String? = nil,
        spacing: CGFloat = 32
    ) {
        self._gender = gender
        self._calendarType = calendarType
        self._birthDate = birthDate
        self._birthTime = birthTime
        self._isBirthTimeUnknown = isBirthTimeUnknown
        self.birthDateValidationMessage = birthDateValidationMessage
        self.unknownTimeInfoText = unknownTimeInfoText
        self.spacing = spacing
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            DSSelectGender(selection: $gender)

            DSSelectLunarOrSolarCalendar(selection: $calendarType)

            VStack(alignment: .leading, spacing: 8) {
                DSEnterDateOfBirth(
                    selection: $birthDate,
                    isFocused: isDatePickerPresented
                ) {
                    prepareBirthDatePicker()
                    isDatePickerPresented = true
                }

                if let message = birthDateValidationMessage {
                    Text(message)
                        .dsCaption1Regular
                        .foregroundStyle(Color.ds.red500)
                        .padding(.horizontal, 4)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                DSEnterTimeOfBirth(
                    selection: $birthTime,
                    isFocused: isTimePickerPresented,
                    isTimeUnknown: $isBirthTimeUnknown
                ) {
                    prepareBirthTimePicker()
                    isTimePickerPresented = true
                }

                if isBirthTimeUnknown, let info = unknownTimeInfoText {
                    Text(info)
                        .dsCaption1Regular
                        .foregroundStyle(Color.ds.sky600)
                        .padding(.horizontal, 4)
                }
            }
        }
        .dsWheelPickerSheet(
            isPresented: $isDatePickerPresented,
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
            isPresented: $isTimePickerPresented,
            layout: .single,
            title: "태어난 시간 선택",
            onSave: saveBirthTime
        ) {
            DSSingleWheelPicker(
                items: BirthTimePeriod.allCases.map {
                    DSWheelPickerItem(
                        value: $0.rawValue,
                        title: DSEnterTimeOfBirth.pickerTitle(for: $0)
                    )
                },
                selection: $pickerBirthTimeRawValue,
                accessibilityLabel: "태어난 시간"
            )
        }
        .onChange(of: pickerYear) { _, _ in normalizeBirthDatePicker() }
        .onChange(of: pickerMonth) { _, _ in normalizeBirthDatePicker() }
    }

    private var birthYearItems: [DSWheelPickerItem] {
        let range = BirthDatePolicy.yearRange(asOf: Date(), calendar: calendar)
        return range.map { DSWheelPickerItem(value: $0, title: "\($0)년") }
    }

    private var birthMonthItems: [DSWheelPickerItem] {
        let maxMonth = BirthDatePolicy.maximumMonth(forYear: pickerYear, asOf: Date(), calendar: calendar)
        return (1...maxMonth).map { DSWheelPickerItem(value: $0, title: "\($0)월") }
    }

    private var birthDayItems: [DSWheelPickerItem] {
        let maxDay = BirthDatePolicy.maximumDay(
            forYear: pickerYear,
            month: pickerMonth,
            asOf: Date(),
            calendar: calendar
        )
        return (1...maxDay).map { DSWheelPickerItem(value: $0, title: "\($0)일") }
    }

    private func prepareBirthDatePicker() {
        pickerYear = birthDate?.year ?? 1999
        pickerMonth = birthDate?.month ?? 1
        pickerDay = birthDate?.day ?? 1
        normalizeBirthDatePicker()
    }

    private func prepareBirthTimePicker() {
        pickerBirthTimeRawValue = (birthTime ?? .inTime).rawValue
    }

    private func saveBirthDate() {
        birthDate = BirthDate(year: pickerYear, month: pickerMonth, day: pickerDay)
        isDatePickerPresented = false
    }

    private func saveBirthTime() {
        birthTime = BirthTimePeriod(rawValue: pickerBirthTimeRawValue)
        isTimePickerPresented = false
    }

    private func normalizeBirthDatePicker() {
        let (normalizedMonth, normalizedDay) = BirthDatePolicy.normalize(
            year: pickerYear,
            month: pickerMonth,
            day: pickerDay,
            asOf: Date(),
            calendar: calendar
        )
        pickerMonth = normalizedMonth
        pickerDay = normalizedDay
    }
}
