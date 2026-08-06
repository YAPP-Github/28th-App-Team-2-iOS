import SwiftUI
import DesignSystem
import Model

struct EnterDateOfBirthPlaygroundView: View {
    @State private var selection: BirthDate?
    @State private var isSheetPresented = false
    @State private var isDarkBackground = false
    @State private var year = 1999
    @State private var month = 2
    @State private var day = 13

    private let calendar = Calendar(identifier: .gregorian)

    private var specification: DSEnterDateOfBirth.Specification {
        DSEnterDateOfBirth.specification()
    }

    private var currentDateComponents: DateComponents {
        calendar.dateComponents([.year, .month, .day], from: Date())
    }

    private var yearItems: [DSWheelPickerItem] {
        (1900...(currentDateComponents.year ?? 1900)).map {
            DSWheelPickerItem(value: $0, title: "\($0)년")
        }
    }

    private var monthItems: [DSWheelPickerItem] {
        let maximumMonth = year == currentDateComponents.year
            ? currentDateComponents.month ?? 12
            : 12
        return (1...maximumMonth).map {
            DSWheelPickerItem(value: $0, title: "\($0)월")
        }
    }

    private var dayItems: [DSWheelPickerItem] {
        let components = DateComponents(year: year, month: month)
        let date = calendar.date(from: components) ?? Date()
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 28
        let maximumDay = year == currentDateComponents.year
            && month == currentDateComponents.month
            ? min(daysInMonth, currentDateComponents.day ?? daysInMonth)
            : daysInMonth

        return (1...maximumDay).map {
            DSWheelPickerItem(value: $0, title: "\($0)일")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSEnterDateOfBirth.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSEnterDateOfBirth(
                    selection: $selection,
                    isFocused: isSheetPresented
                ) {
                    isSheetPresented = true
                }
            }

            Form {
                Section(header: Text("Content & State")) {
                    DSSpecificationRow(
                        title: "Selection",
                        value: DSEnterDateOfBirth.displayTitle(for: selection) ?? "None"
                    )
                    Button("Open Date WheelPicker") {
                        isSheetPresented = true
                    }
                    Button("Clear Selection") {
                        selection = nil
                    }
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(
                        title: "Content Spacing",
                        value: specification.contentSpacing.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Label Typography",
                        value: specification.labelFontStyle.specName
                    )
                    DSSpecificationRow(
                        title: "Label Color",
                        value: specification.labelForegroundAsset.specDescription
                    )
                }
            }
        }
        .dsWheelPickerSheet(
            isPresented: $isSheetPresented,
            layout: .date,
            title: "생년월일 입력",
            onSave: saveSelection
        ) {
            DSMultiWheelPicker(
                layout: .date,
                columns: [
                    DSWheelPickerColumn(
                        items: yearItems,
                        selection: $year,
                        accessibilityLabel: "연도"
                    ),
                    DSWheelPickerColumn(
                        items: monthItems,
                        selection: $month,
                        accessibilityLabel: "월",
                        isCircular: true
                    ),
                    DSWheelPickerColumn(
                        items: dayItems,
                        selection: $day,
                        accessibilityLabel: "일"
                    )
                ]
            )
        }
        .onChange(of: year) { _, _ in
            normalizeSelection()
        }
        .onChange(of: month) { _, _ in
            normalizeSelection()
        }
        .navigationTitle("DSEnterDateOfBirth")
        .navigationBarTitleDisplayMode(.inline)
        .dsWheelPickerDismissKeyboardOnTap()
    }

    private func saveSelection() {
        selection = BirthDate(year: year, month: month, day: day)
        isSheetPresented = false
    }

    private func normalizeSelection() {
        if let maximumMonth = monthItems.last?.value {
            month = min(max(month, 1), maximumMonth)
        }
        if let maximumDay = dayItems.last?.value {
            day = min(max(day, 1), maximumDay)
        }
    }
}

#Preview {
    NavigationStack {
        EnterDateOfBirthPlaygroundView()
    }
}
