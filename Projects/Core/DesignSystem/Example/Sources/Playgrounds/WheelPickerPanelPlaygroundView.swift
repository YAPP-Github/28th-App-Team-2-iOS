import SwiftUI
import DesignSystem

struct WheelPickerPanelPlaygroundView: View {
    private enum PreviewLayout: String, CaseIterable, Identifiable {
        case single = "Single"
        case time = "Time"
        case date = "Date"

        // swiftlint:disable:next identifier_name
        var id: Self { self }

        var panelLayout: DSWheelPickerPanelLayout {
            switch self {
            case .single: .single
            case .time: .time
            case .date: .date
            }
        }

        var title: String {
            switch self {
            case .single: "태어난 시각 선택"
            case .time: "받을 시간 입력"
            case .date: "생년월일 입력"
            }
        }
    }

    @State private var previewLayout = PreviewLayout.date
    @State private var isSheetPresented = false
    @State private var singleSelection = 0
    @State private var hour = 8
    @State private var minute = 0
    @State private var year = 1999
    @State private var month = 2
    @State private var day = 13
    @State private var savedDescription = "저장 전"
    @State private var isDarkBackground = false

    private let calendar = Calendar(identifier: .gregorian)

    private var specification: DSWheelPickerPanel.Specification {
        DSWheelPickerPanel.specification(layout: previewLayout.panelLayout)
    }

    private var singleItems: [DSWheelPickerItem] {
        WheelPickerExampleData.fortuneTimeItems
    }

    private var yearItems: [DSWheelPickerItem] {
        let currentYear = calendar.component(.year, from: Date())
        return (1900...currentYear).map {
            DSWheelPickerItem(value: $0, title: "\($0)년")
        }
    }

    private var monthItems: [DSWheelPickerItem] {
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        let maximumMonth = year == currentYear ? currentMonth : 12

        return (1...maximumMonth).map {
            DSWheelPickerItem(value: $0, title: "\($0)월")
        }
    }

    private var dayItems: [DSWheelPickerItem] {
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        let currentDay = calendar.component(.day, from: Date())
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

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSWheelPickerPanel.self),
                height: specification.containerHeight + 100,
                isDarkBackground: $isDarkBackground
            ) {
                panel
            }

            Form {
                Section(header: Text("Layout & Presentation")) {
                    Picker("Layout", selection: $previewLayout) {
                        ForEach(PreviewLayout.allCases) { layout in
                            Text(layout.rawValue)
                                .tag(layout)
                        }
                    }
                    .pickerStyle(.segmented)

                    Button("Custom Sheet로 보기") {
                        isSheetPresented = true
                    }

                    Text("Saved: \(savedDescription)")
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(
                        title: "Container",
                        value: [
                            specification.containerWidth.ptDescription,
                            specification.containerHeight.ptDescription
                        ].joined(separator: " × ")
                    )
                    DSSpecificationRow(
                        title: "Drag Indicator",
                        value: [
                            specification.dragIndicatorWidth.ptDescription,
                            specification.dragIndicatorHeight.ptDescription
                        ].joined(separator: " × ")
                    )
                    DSSpecificationRow(
                        title: "Header",
                        value: specification.headerHeight.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Shape",
                        value: specification.containerShape.specName
                    )
                    DSSpecificationRow(
                        title: "Background",
                        value: specification.backgroundAsset.specDescription
                    )
                    DSSpecificationRow(
                        title: "Shadow",
                        value: [
                            specification.shadowColorAsset.specDescription,
                            "X \(specification.shadowOffsetX.ptDescription)",
                            "Y \(specification.shadowOffsetY.ptDescription)",
                            "Blur \(specification.shadowRadius.ptDescription)",
                            "\(Int(specification.shadowOpacity * 100))%"
                        ].joined(separator: ", ")
                    )
                }
            }
        }
        .dsWheelPickerSheet(
            isPresented: $isSheetPresented,
            layout: previewLayout.panelLayout,
            title: previewLayout.title,
            onSave: saveSelection
        ) {
            picker
        }
        .dsWheelPickerDismissKeyboardOnTap()
        .onChange(of: year) { _, _ in
            normalizeDateSelection()
        }
        .onChange(of: month) { _, _ in
            normalizeDateSelection()
        }
        .navigationTitle("DSWheelPickerPanel")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var panel: some View {
        DSWheelPickerPanel(
            layout: previewLayout.panelLayout,
            title: previewLayout.title,
            onSave: saveSelection
        ) {
            picker
        }
    }

    @ViewBuilder
    private var picker: some View {
        switch previewLayout {
        case .single:
            DSSingleWheelPicker(
                items: singleItems,
                selection: $singleSelection,
                accessibilityLabel: "태어난 시각"
            )
        case .time:
            DSMultiWheelPicker(
                layout: .time,
                columns: [
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
            )
        case .date:
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
    }

    private func saveSelection() {
        switch previewLayout {
        case .single:
            savedDescription = singleItems.first {
                $0.value == singleSelection
            }?.title ?? "-"
        case .time:
            savedDescription = String(format: "%02d:%02d", hour, minute)
        case .date:
            savedDescription = "\(year)년 \(month)월 \(day)일"
        }

        isSheetPresented = false
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
        WheelPickerPanelPlaygroundView()
    }
}
