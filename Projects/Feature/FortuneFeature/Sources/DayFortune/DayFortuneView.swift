// swiftlint:disable file_length
import ComposableArchitecture
import DesignSystem
import SwiftUI

struct DayFortuneView: View {
    @Bindable var store: StoreOf<DayFortuneFeature>
    let backAction: () -> Void

    init(store: StoreOf<DayFortuneFeature>, backAction: @escaping () -> Void) {
        self.store = store
        self.backAction = backAction
    }

    var body: some View {
        Group {
            if store.results.isEmpty {
                DayFortuneFormContent(store: store, backAction: backAction)
            } else {
                DayFortuneResultContent(store: store)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(
            isPresented: $store.isCalendarPresented.sending(\.calendarPresented)
        ) {
            DayFortuneCalendarSheet(store: store)
                .presentationDetents([.fraction(0.92), .large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(28)
        }
        .sheet(item: calendarEventDraftBinding) { draft in
            CalendarEventEditor(draft: draft) { result in
                store.send(.calendarEventEditorCompleted(result))
            }
        }
    }

    private var calendarEventDraftBinding: Binding<CalendarEventDraft?> {
        Binding(
            get: { store.calendarEventDraft },
            set: { draft in
                guard draft == nil else { return }
                store.send(.calendarEventEditorCompleted(.cancelled))
            }
        )
    }
}

// MARK: - 입력 화면

private struct DayFortuneFormContent: View {
    @Bindable var store: StoreOf<DayFortuneFeature>
    let backAction: () -> Void

    var body: some View {
        ZStack {
            Color.ds.white.ignoresSafeArea()

            VStack(spacing: 0) {
                FortuneHeaderView(title: "택일 운세", isDark: false, action: backAction)

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        formHeader

                        purposeSection

                        dateSelectionSection

                        if let errorMessage = store.errorMessage, !store.isCalendarPresented {
                            FortuneErrorBanner(message: errorMessage)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 100)
                }
                .scrollIndicators(.hidden)
            }

            if store.isSubmitting {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    FortuneLoadingView()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                DSButton("무료로 택일 보기") {
                    store.send(.createTapped)
                }
                .disabled(!store.canSubmit)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 12)
            }
            .background(Color.clear)
        }
    }

    private var formHeader: some View {
        Text("무슨 날을 정하시나요?")
            .dsHeading3Bold
            .foregroundStyle(Color.ds.gray975)
    }

    private var purposeSection: some View {
        DayFortuneFlowLayout(spacing: 12) {
            ForEach(DayFortunePurpose.allCases, id: \.self) { purpose in
                let isSelected = store.purpose == purpose
                Button {
                    store.send(.purposeSelected(purpose))
                } label: {
                    Text(purpose.title)
                        .dsBody2SemiBold
                        .foregroundStyle(isSelected ? Color.ds.white : Color.ds.gray700)
                        .padding(.horizontal, 20)
                        .frame(height: 48)
                        .background(isSelected ? Color.ds.primary500 : Color.ds.gray100)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("후보 날짜")
                    .dsHeading3Bold
                    .foregroundStyle(Color.ds.gray975)

                Text("(5개까지 가능)")
                    .dsBody3Regular
                    .foregroundStyle(Color.ds.gray600)

                Spacer()
            }

            Button {
                store.send(.calendarPresented(true))
            } label: {
                HStack {
                    if store.selectedDates.isEmpty {
                        Text("후보 날짜 선택")
                            .dsBody2Regular
                            .foregroundStyle(Color.ds.gray500)
                    } else {
                        Text(formattedDatesSummary)
                            .dsBody2Medium
                            .foregroundStyle(Color.ds.gray975)
                            .lineLimit(1)
                    }

                    Spacer()

                    DSIcon(.chevronSmallBottom, width: 20, height: 20)
                        .foregroundStyle(Color.ds.gray600)
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.ds.gray50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            if !store.selectedDates.isEmpty {
                DayFortuneFlowLayout(spacing: 6) {
                    ForEach(store.selectedDates, id: \.self) { date in
                        HStack(spacing: 6) {
                            Text(DayFortuneDateFormatter.shortDate(date))
                                .dsBody3Medium
                                .foregroundStyle(Color.ds.primary700)

                            Button {
                                store.send(.dateTapped(date))
                            } label: {
                                DSIcon(.closeLine, width: 12, height: 12)
                                    .foregroundStyle(Color.ds.primary700)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.ds.primary50)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var formattedDatesSummary: String {
        store.selectedDates.map { DayFortuneDateFormatter.shortDate($0) }.joined(separator: ", ")
    }
}

// MARK: - 달력 시트

private struct DayFortuneCalendarSheet: View {
    @Bindable var store: StoreOf<DayFortuneFeature>

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Drag Handle
                Capsule()
                    .fill(Color.ds.gray300)
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 12)

                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("후보 날짜 선택")
                            .dsBody1Bold
                            .foregroundStyle(Color.ds.gray975)

                        Text("5개까지 날짜 선택 가능해요")
                            .dsCaption1Regular
                            .foregroundStyle(Color.ds.gray600)
                    }

                    Spacer()

                    Button {
                        store.send(.calendarPresented(false))
                    } label: {
                        DSIcon(.closeLine, width: 24, height: 24)
                            .foregroundStyle(Color.ds.gray800)
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Scrollable Multi-Month Calendar
                ScrollView(showsIndicators: false) {
                    CalendarPickerView(
                        selectedDates: store.selectedDates,
                        onDateTapped: { date in
                            store.send(.dateTapped(date))
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }

            // Bottom Action Bar
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Button {
                        store.send(.resetDatesTapped)
                    } label: {
                        Text("초기화")
                            .dsBody2SemiBold
                            .foregroundStyle(store.selectedDates.isEmpty ? Color.ds.gray400 : Color.ds.primary600)
                            .frame(width: 96, height: 52)
                            .background(store.selectedDates.isEmpty ? Color.ds.gray100 : Color.ds.primary50)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(store.selectedDates.isEmpty)

                    DSButton("선택 완료") {
                        store.send(.datesConfirmed)
                    }
                    .disabled(store.selectedDates.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
            .background(Color.ds.white)

            if store.showLimitToast {
                DSToast(compact: "후보 날짜는 5개까지만 선택 가능합니다.")
                    .padding(.bottom, 84)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.showLimitToast)
    }
}

// MARK: - 결과 화면

private struct DayFortuneResultContent: View {
    @Bindable var store: StoreOf<DayFortuneFeature>

    var body: some View {
        ZStack(alignment: .top) {
            Color.fortuneSpaceBase.ignoresSafeArea()

            resultBackgroundImage

            VStack(spacing: 0) {
                resultHeader

                ScrollView(.vertical) {
                    VStack(spacing: 20) {
                        resultIntroduction

                        if store.results.count > 1 {
                            candidateSelectorTabs
                        }

                        if let selectedResult = store.selectedResult {
                            resultCard(selectedResult)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                    .containerRelativeFrame(.horizontal)
                }
                .scrollIndicators(.hidden)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            FortuneTodakInquiryBar(tooltip: "시간대는 언제가 좋아?") {
                store.send(.todakTapped)
            }
        }
        .overlay(alignment: .bottom) {
            if store.isCalendarExportSuccessToastPresented {
                DSToast(compact: "캘린더에 일정을 추가했어요.")
                    .padding(.bottom, 84)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.isCalendarExportSuccessToastPresented)
    }

    private var resultHeader: some View {
        HStack(spacing: 4) {
            Button {
                store.send(.resultBackTapped)
            } label: {
                DSIcon(.chevronLeftNarrow, width: 24, height: 24)
                    .foregroundStyle(Color.ds.white)
                    .frame(width: 44, height: 44)
            }
            .dsIconButtonStyle(.chevronLeftNarrow, width: 24, height: 24)

            Spacer()

            Text("택일 운세 결과")
                .dsBody2SemiBold
                .foregroundStyle(Color.ds.white)

            Spacer()

            Button {
                store.send(.calendarExportTapped)
            } label: {
                calendarExportIconAsset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.ds.white)
                    .frame(width: 36, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("캘린더 내보내기")

        }
        .padding(.horizontal, 10)
        .frame(height: 52)
    }

    @ViewBuilder
    private var resultIntroduction: some View {
        if let selectedResult = store.selectedResult {
            VStack(spacing: 14) {
                Text(selectedResult.purpose.title)
                    .dsBody3Medium
                    .foregroundStyle(Color.ds.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.ds.primary600)
                    .clipShape(Capsule())

                Text("선택하신 후보 일자 중\n최고의 기운을 찾아봤어요")
                    .dsHeading2Bold
                    .foregroundStyle(Color.ds.white)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var candidateSelectorTabs: some View {
        HStack(spacing: 8) {
            ForEach(store.results) { result in
                let isSelected = result.id == store.selectedResultID
                Button {
                    store.send(.resultSelected(result.id))
                } label: {
                    Text(DayFortuneDateFormatter.tabDate(result.targetDate))
                        .dsBody2Medium
                        .foregroundStyle(isSelected ? Color.ds.white : Color.ds.whiteOpacity80)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(isSelected ? Color.ds.primary600 : Color.ds.whiteOpacity05)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isSelected ? Color.ds.primary300 : Color.ds.whiteOpacity30,
                                    lineWidth: 1
                                )
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func resultCard(_ result: DayFortuneResult) -> some View {
        VStack(spacing: 16) {
            mainScoreCard(result)

            summaryAnalysisCard(result)
        }
    }

    private func mainScoreCard(_ result: DayFortuneResult) -> some View {
        VStack(spacing: 24) {
            FortuneResultScoreRing(score: result.score, caption: "운세 점수")

            Text(result.title)
                .dsHeading2Bold
                .foregroundStyle(Color.ds.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !result.categories.isEmpty {
                categoryStarsRow(result.categories)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(Color.ds.whiteOpacity10)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func categoryStarsRow(_ categories: [FortuneCategoryStar]) -> some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(categories.prefix(3)) { catStar in
                VStack(spacing: 6) {
                    Text(catStar.category.title)
                        .dsCaption1Regular
                        .foregroundStyle(Color.ds.whiteOpacity60)

                    HStack(spacing: 4) {
                        let normalized = catStar.star > 3 ? Int(round(Double(catStar.star) * 3.0 / 5.0)) : catStar.star
                        let filledCount = min(3, max(1, normalized))
                        ForEach(1...3, id: \.self) { starIndex in
                            let isFilled = starIndex <= filledCount
                            if isFilled {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.ds.primary300)
                            } else {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.ds.whiteOpacity05)
                                    .overlay {
                                        Image(systemName: "star")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color.ds.whiteOpacity30)
                                    }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
    }

    private func summaryAnalysisCard(_ result: DayFortuneResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("요약 분석")
                .dsBody1Bold
                .foregroundStyle(Color.ds.white)

            Text(result.content)
                .dsBody3Regular
                .foregroundStyle(Color.ds.whiteOpacity80)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.ds.whiteOpacity10)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var resultBackgroundImage: some View {
        GeometryReader { proxy in
            FortuneSpaceBackground()
                .frame(height: proxy.size.width / (393.0 / 850.0))
        }
        .ignoresSafeArea(edges: .top)
    }

    private var calendarExportIconAsset: Image {
        FortuneFeatureAsset.fortuneCalendarExport.swiftUIImage
    }
}

private enum DayFortuneDateFormatter {
    static func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }

    static func tabDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M.d(E)"
        return formatter.string(from: date)
    }
}

private struct CalendarPickerView: View {
    let selectedDates: [Date]
    let onDateTapped: (Date) -> Void

    private let calendar = Calendar.current
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    private var months: [Date] {
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        return (0..<12).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: startOfCurrentMonth)
        }
    }

    var body: some View {
        LazyVStack(spacing: 36) {
            ForEach(months, id: \.self) { month in
                monthSection(for: month)
            }
        }
    }

    private func monthSection(for month: Date) -> some View {
        VStack(spacing: 16) {
            Text(monthTitle(for: month))
                .dsBody1Bold
                .foregroundStyle(Color.ds.gray975)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .dsCaption1Medium
                        .foregroundStyle(Color.ds.gray500)
                        .frame(maxWidth: .infinity)
                }
            }

            let days = daysInMonth(for: month)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<days.count, id: \.self) { index in
                    if let date = days[index] {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 38)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let isSelected = selectedDates.contains { calendar.isDate($0, inSameDayAs: date) }
        let isToday = calendar.isDateInToday(date)
        let isPast = calendar.startOfDay(for: date) < calendar.startOfDay(for: Date())

        Button {
            onDateTapped(date)
        } label: {
            VStack(spacing: 1) {
                Text("\(calendar.component(.day, from: date))")
                    .dsBody2Medium
                    .foregroundStyle(
                        cellTextColor(isSelected: isSelected, isPast: isPast, isToday: isToday)
                    )

                if isToday {
                    Text("오늘")
                        .dsCaption3Medium
                        .foregroundStyle(isSelected ? Color.ds.white : Color.ds.primary600)
                }
            }
            .frame(width: 38, height: 38)
            .background(
                isSelected ? Color.ds.primary600 : Color.clear
            )
            .clipShape(Circle())
        }
        .disabled(isPast)
        .buttonStyle(.plain)
    }

    private func cellTextColor(isSelected: Bool, isPast: Bool, isToday: Bool) -> Color {
        if isSelected { return Color.ds.white }
        if isPast { return Color.ds.gray300 }
        if isToday { return Color.ds.primary600 }
        return Color.ds.gray975
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM"
        return formatter.string(from: date)
    }

    private func daysInMonth(for month: Date) -> [Date?] {
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        let numberOfDays = calendar.range(of: .day, in: .month, for: month)?.count ?? 0

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
}

private struct DayFortuneFlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let width = proposal.width ?? 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX > 0, currentX + size.width > width {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: currentY + rowHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX > bounds.minX, currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
