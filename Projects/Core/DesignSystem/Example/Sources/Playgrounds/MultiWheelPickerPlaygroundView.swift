import SwiftUI
import DesignSystem

struct MultiWheelPickerPlaygroundView: View {
    private enum PreviewLayout: String, CaseIterable, Identifiable {
        case time = "Time"
        case date = "Date"

        // swiftlint:disable:next identifier_name
        var id: Self { self }

        var designSystemLayout: DSMultiWheelPickerLayout {
            switch self {
            case .time: .time
            case .date: .date
            }
        }
    }

    @State private var previewLayout = PreviewLayout.date
    @State private var hour = 8
    @State private var minute = 0
    @State private var year = 1999
    @State private var month = 2
    @State private var day = 13
    @State private var isDarkBackground = false

    private let calendar = Calendar(identifier: .gregorian)

    private var currentYear: Int {
        calendar.component(.year, from: Date())
    }

    private var currentMonth: Int {
        calendar.component(.month, from: Date())
    }

    private var currentDay: Int {
        calendar.component(.day, from: Date())
    }

    private var yearItems: [DSWheelPickerItem] {
        (1900...currentYear).map {
            DSWheelPickerItem(value: $0, title: "\($0)년")
        }
    }

    private var monthItems: [DSWheelPickerItem] {
        let maximumMonth = year == currentYear ? currentMonth : 12
        return (1...maximumMonth).map {
            DSWheelPickerItem(value: $0, title: "\($0)월")
        }
    }

    private var dayItems: [DSWheelPickerItem] {
        let components = DateComponents(year: year, month: month)
        let date = calendar.date(from: components) ?? Date()
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 28
        let maximumDay = year == currentYear && month == currentMonth
            ? min(daysInMonth, currentDay)
            : daysInMonth

        return (1...maximumDay).map {
            DSWheelPickerItem(value: $0, title: "\($0)일")
        }
    }

    private var timeColumns: [DSWheelPickerColumn] {
        [
            DSWheelPickerColumn(
                items: (0..<24).map {
                    DSWheelPickerItem(
                        value: $0,
                        title: String(format: "%02d", $0)
                    )
                },
                selection: $hour,
                accessibilityLabel: "시"
            ),
            DSWheelPickerColumn(
                items: [0, 30].map {
                    DSWheelPickerItem(
                        value: $0,
                        title: String(format: "%02d", $0)
                    )
                },
                selection: $minute,
                accessibilityLabel: "분"
            )
        ]
    }

    private var dateColumns: [DSWheelPickerColumn] {
        [
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
    }

    private var specification: DSMultiWheelPicker.Specification {
        DSMultiWheelPicker.specification(layout: previewLayout.designSystemLayout)
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSMultiWheelPicker.self),
                height: 260,
                isDarkBackground: $isDarkBackground
            ) {
                DSMultiWheelPicker(
                    layout: previewLayout.designSystemLayout,
                    columns: previewLayout == .time ? timeColumns : dateColumns
                )
            }

            Form {
                Section(header: Text("Layout & State")) {
                    Picker("Layout", selection: $previewLayout) {
                        ForEach(PreviewLayout.allCases) { layout in
                            Text(layout.rawValue)
                                .tag(layout)
                        }
                    }
                    .pickerStyle(.segmented)

                    if previewLayout == .time {
                        let formattedHour = hour.formatted(
                            .number.precision(.integerLength(2))
                        )
                        let formattedMinute = minute.formatted(
                            .number.precision(.integerLength(2))
                        )

                        Text("Selected: \(formattedHour):\(formattedMinute)")
                    } else {
                        Text("Selected: \(year)년 \(month)월 \(day)일")
                        Text("선택된 셀을 누르면 숫자로 직접 입력할 수 있습니다.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(
                        title: "Container",
                        value: [
                            specification.containerWidth.ptDescription,
                            specification.viewportHeight.ptDescription
                        ].joined(separator: " × ")
                    )
                    DSSpecificationRow(
                        title: "Row Height",
                        value: specification.rowHeight.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Selection Height",
                        value: specification.selectionHeight.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Column Widths",
                        value: specification.columnWidths
                            .map(\.ptDescription)
                            .joined(separator: ", ")
                    )
                    DSSpecificationRow(
                        title: "Column Gap",
                        value: specification.columnGap.ptDescription
                    )
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(
                        title: "Selection Background",
                        value: specification.selectionBackgroundAsset.specDescription
                    )
                }
            }
        }
        .onChange(of: year) { _, _ in
            normalizeDateSelection()
        }
        .onChange(of: month) { _, _ in
            normalizeDateSelection()
        }
        .navigationTitle("DSMultiWheelPicker")
        .navigationBarTitleDisplayMode(.inline)
        .dsWheelPickerDismissKeyboardOnTap()
    }

    private func normalizeDateSelection() {
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
        MultiWheelPickerPlaygroundView()
    }
}
