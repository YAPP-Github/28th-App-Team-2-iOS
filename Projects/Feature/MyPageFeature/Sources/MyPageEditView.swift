import ComposableArchitecture
import DesignSystem
import Model
import SwiftUI

struct MyPageEditView: View {
    @Bindable private var store: StoreOf<MyPageFeature>
    @State private var isBirthDatePickerPresented = false
    @State private var isBirthTimePickerPresented = false
    @State private var pickerYear = 1999
    @State private var pickerMonth = 1
    @State private var pickerDay = 1
    @State private var pickerBirthTimeRawValue = BirthTimePeriod.inTime.rawValue

    private let calendar = Calendar(identifier: .gregorian)

    init(store: StoreOf<MyPageFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            DSHeaderSub(
                title: "내 정보 수정",
                leftItem: DSHeaderActionItem(
                    identifier: "back",
                    icon: .chevronLeftPlain,
                    action: { store.send(.editDismissButtonTapped) }
                )
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    DSSelectGender(selection: genderBinding)
                    DSSelectLunarOrSolarCalendar(selection: calendarBinding)
                    DSEnterDateOfBirth(
                        selection: birthDateBinding,
                        isFocused: isBirthDatePickerPresented
                    ) {
                        prepareBirthDatePicker()
                        isBirthDatePickerPresented = true
                    }
                    DSEnterTimeOfBirth(
                        selection: birthTimeBinding,
                        isFocused: isBirthTimePickerPresented,
                        isTimeUnknown: birthTimeUnknownBinding
                    ) {
                        prepareBirthTimePicker()
                        isBirthTimePickerPresented = true
                    }
                    currentStatusField
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 24)
            }

            if let error = store.edit?.error {
                Text(error.message)
                    .dsCaption1Regular
                    .foregroundStyle(Color.ds.red500)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }

            DSPrimaryLargeButton(store.edit?.isSaving == true ? "저장 중…" : "저장하기") {
                store.send(.editSaveButtonTapped)
            }
            .disabled(store.edit?.isValid != true || store.edit?.isSaving == true)
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
        .background(Color.ds.white)
        .dsWheelPickerSheet(
            isPresented: $isBirthDatePickerPresented,
            layout: .date,
            title: "생년월일 입력",
            onSave: saveBirthDate
        ) {
            DSMultiWheelPicker(
                layout: .date,
                columns: [
                    DSWheelPickerColumn(items: birthYearItems, selection: $pickerYear, accessibilityLabel: "연도"),
                    DSWheelPickerColumn(
                        items: birthMonthItems,
                        selection: $pickerMonth,
                        accessibilityLabel: "월",
                        isCircular: true
                    ),
                    DSWheelPickerColumn(items: birthDayItems, selection: $pickerDay, accessibilityLabel: "일")
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
                items: BirthTimePeriod.allCases.map {
                    DSWheelPickerItem(value: $0.rawValue, title: DSEnterTimeOfBirth.pickerTitle(for: $0))
                },
                selection: $pickerBirthTimeRawValue,
                accessibilityLabel: "태어난 시각"
            )
        }
        .sheet(isPresented: isStatusSheetPresented) {
            MyPageCurrentStatusSheet(store: store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
        .onChange(of: pickerYear) { _, _ in normalizeBirthDatePicker() }
        .onChange(of: pickerMonth) { _, _ in normalizeBirthDatePicker() }
    }

    private var currentStatusField: some View {
        DSSelectField(
            selection: Binding(
                get: { currentStatusText },
                set: { _ in }
            ),
            placeholder: "현재 상황 선택",
            action: { store.send(.editStatusSheetPresented(true)) }
        )
        .overlay(alignment: .topLeading) {
            Text("현재 상황")
                .dsBody1Bold
                .foregroundStyle(Color.ds.black)
                .offset(y: -42)
        }
        .padding(.top, 42)
    }

    private var currentStatusText: String? {
        guard let edit = store.edit, let job = edit.job, let relationship = edit.relationshipStatus else { return nil }
        return "\(job.title) ∙ \(relationship.title)"
    }

    private var genderBinding: Binding<Gender?> {
        Binding(get: { store.edit?.gender }, set: { store.send(.editGenderChanged($0)) })
    }

    private var calendarBinding: Binding<BirthDateCalendar?> {
        Binding(get: { store.edit?.calendar }, set: { store.send(.editCalendarChanged($0)) })
    }

    private var birthDateBinding: Binding<BirthDate?> {
        Binding(get: { store.edit?.birthDate }, set: { store.send(.editBirthDateChanged($0)) })
    }

    private var birthTimeBinding: Binding<BirthTimePeriod?> {
        Binding(get: { store.edit?.birthTime }, set: { store.send(.editBirthTimeChanged($0)) })
    }

    private var birthTimeUnknownBinding: Binding<Bool> {
        Binding(get: { store.edit?.isBirthTimeUnknown ?? false }, set: { store.send(.editBirthTimeUnknownChanged($0)) })
    }

    private var isStatusSheetPresented: Binding<Bool> {
        Binding(
            get: { store.edit?.isStatusSheetPresented ?? false },
            set: { store.send(.editStatusSheetPresented($0)) }
        )
    }

    private var currentDateComponents: DateComponents {
        calendar.dateComponents([.year, .month, .day], from: Date())
    }

    private var birthYearItems: [DSWheelPickerItem] {
        (1900...(currentDateComponents.year ?? 1900)).map { DSWheelPickerItem(value: $0, title: "\($0)년") }
    }

    private var birthMonthItems: [DSWheelPickerItem] {
        let maximum = pickerYear == currentDateComponents.year ? currentDateComponents.month ?? 12 : 12
        return (1...maximum).map { DSWheelPickerItem(value: $0, title: "\($0)월") }
    }

    private var birthDayItems: [DSWheelPickerItem] {
        let date = calendar.date(from: DateComponents(year: pickerYear, month: pickerMonth)) ?? Date()
        let monthDays = calendar.range(of: .day, in: .month, for: date)?.count ?? 28
        let maximum = pickerYear == currentDateComponents.year && pickerMonth == currentDateComponents.month
            ? min(monthDays, currentDateComponents.day ?? monthDays) : monthDays
        return (1...maximum).map { DSWheelPickerItem(value: $0, title: "\($0)일") }
    }

    private func prepareBirthDatePicker() {
        pickerYear = store.edit?.birthDate?.year ?? 1999
        pickerMonth = store.edit?.birthDate?.month ?? 1
        pickerDay = store.edit?.birthDate?.day ?? 1
        normalizeBirthDatePicker()
    }

    private func prepareBirthTimePicker() {
        pickerBirthTimeRawValue = (store.edit?.birthTime ?? .inTime).rawValue
    }

    private func saveBirthDate() {
        store.send(.editBirthDateChanged(BirthDate(year: pickerYear, month: pickerMonth, day: pickerDay)))
        isBirthDatePickerPresented = false
    }

    private func saveBirthTime() {
        store.send(.editBirthTimeChanged(BirthTimePeriod(rawValue: pickerBirthTimeRawValue)))
        isBirthTimePickerPresented = false
    }

    private func normalizeBirthDatePicker() {
        pickerMonth = min(max(pickerMonth, 1), birthMonthItems.last?.value ?? 12)
        pickerDay = min(max(pickerDay, 1), birthDayItems.last?.value ?? 28)
    }
}

private struct MyPageCurrentStatusSheet: View {
    @Bindable private var store: StoreOf<MyPageFeature>

    init(store: StoreOf<MyPageFeature>) { self.store = store }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("당신의 현재 상황에 대해\n알려주세요.")
                .dsHeading3Bold
                .foregroundStyle(Color.ds.gray975)

            optionSection("Q1", "주로 어떤 일상을 보내고 계신가요?", MyPageJob.allCases, store.edit?.job) {
                store.send(.editJobChanged($0))
            }
            optionSection("Q2", "현재 연애 상태를 알려주세요.", MyPageRelationshipStatus.allCases, store.edit?.relationshipStatus) {
                store.send(.editRelationshipStatusChanged($0))
            }

            Spacer(minLength: 0)
            DSPrimaryLargeButton("저장하기") { store.send(.editStatusSheetPresented(false)) }
                .disabled(store.edit?.job == nil || store.edit?.relationshipStatus == nil)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 14)
    }

    private func optionSection<Option: Hashable>(
        _ number: String,
        _ question: String,
        _ options: [Option],
        _ selected: Option?,
        action: @escaping (Option) -> Void
    ) -> some View where Option: MyPageStatusOption {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Text(number).dsBody1Bold.foregroundStyle(Color.ds.primary600)
                Text(question).dsBody1Bold.foregroundStyle(Color.ds.gray975)
            }
            MyPageFlowLayout(horizontalSpacing: 12, verticalSpacing: 12) {
                ForEach(options, id: \.self) { option in
                    DSChip(option.title, isSelected: selected == option) { action(option) }
                }
            }
        }
    }
}

private protocol MyPageStatusOption { var title: String { get } }
extension MyPageJob: MyPageStatusOption {}
extension MyPageRelationshipStatus: MyPageStatusOption {}

private struct MyPageFlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout Void) -> CGSize {
        let width = proposal.width ?? subviews.reduce(0) { $0 + $1.sizeThatFits(.unspecified).width }
        return layoutSize(width: width, subviews: subviews)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout Void) {
        var horizontalPosition = bounds.minX
        var verticalPosition = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if horizontalPosition > bounds.minX && horizontalPosition + size.width > bounds.maxX {
                horizontalPosition = bounds.minX
                verticalPosition += rowHeight + verticalSpacing
                rowHeight = 0
            }
            subview.place(
                at: CGPoint(x: horizontalPosition, y: verticalPosition),
                anchor: .topLeading,
                proposal: ProposedViewSize(size)
            )
            horizontalPosition += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }

    private func layoutSize(width: CGFloat, subviews: Subviews) -> CGSize {
        var horizontalPosition: CGFloat = 0
        var verticalPosition: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if horizontalPosition > 0 && horizontalPosition + size.width > width {
                horizontalPosition = 0
                verticalPosition += rowHeight + verticalSpacing
                rowHeight = 0
            }
            horizontalPosition += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: verticalPosition + rowHeight)
    }
}

private extension MyPageClientError {
    var message: String { "내 정보 수정에 실패했어요. 다시 시도해주세요." }
}
