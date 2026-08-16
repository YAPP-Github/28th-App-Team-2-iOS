// swiftlint:disable file_length
import ComposableArchitecture
import DesignSystem
import Model
import SwiftUI

struct CompatibilityView: View {
    @Bindable var store: StoreOf<CompatibilityFeature>
    let backAction: () -> Void

    @State private var selectedPartnerIndex: Int = 0

    init(store: StoreOf<CompatibilityFeature>, backAction: @escaping () -> Void) {
        self.store = store
        self.backAction = backAction
    }

    var body: some View {
        ZStack {
            switch store.viewState {
            case .loading:
                ZStack {
                    Color.ds.white.ignoresSafeArea()
                    FortuneLoadingView()
                }

            case let .failed(message):
                ZStack {
                    Color.ds.white.ignoresSafeArea()
                    FortuneFailureView(message: message) {
                        store.send(.retryTapped)
                    }
                }

            case .loaded:
                if store.result != nil {
                    CompatibilityResultContent(store: store)
                } else if store.isRegistrationPresented {
                    PartnerRegistrationView(store: store)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                } else {
                    CompatibilityMainContent(store: store, backAction: backAction)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.isRegistrationPresented)
        .animation(.easeInOut(duration: 0.25), value: store.result != nil)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            store.send(.task)
        }
        .dsWheelPickerSheet(
            isPresented: $store.isPartnerPickerPresented.sending(\.partnerPickerPresented),
            layout: .single,
            title: "상대방 선택",
            actionTitle: "추가",
            onSave: {
                store.send(.partnerPickerPresented(false))
                store.send(.registrationPresented(true))
            },
            content: {
                DSSingleWheelPicker(
                    items: partnerWheelItems,
                    selection: $selectedPartnerIndex,
                    accessibilityLabel: "궁합 상대"
                )
            }
        )
        .onAppear {
            syncSelectedPartnerIndex()
        }
        .onChange(of: store.isPartnerPickerPresented) { wasPresented, isPresented in
            if isPresented {
                syncSelectedPartnerIndex()
            } else if wasPresented {
                if store.partners.indices.contains(selectedPartnerIndex) {
                    let partner = store.partners[selectedPartnerIndex]
                    if partner.id != store.selectedPartnerID {
                        store.send(.partnerSelected(partner.id))
                    }
                }
            }
        }
        .onChange(of: store.selectedPartnerID) { _, _ in
            syncSelectedPartnerIndex()
        }
    }

    private var partnerWheelItems: [DSWheelPickerItem] {
        guard !store.partners.isEmpty else {
            return [DSWheelPickerItem(value: 0, title: "등록된 상대 없음")]
        }
        return store.partners.enumerated().map { index, partner in
            DSWheelPickerItem(
                value: index,
                title: "\(partner.name) (\(partner.relationship.title))"
            )
        }
    }

    private func syncSelectedPartnerIndex() {
        if let selectedID = store.selectedPartnerID,
           let index = store.partners.firstIndex(where: { $0.id == selectedID }) {
            selectedPartnerIndex = index
        } else {
            selectedPartnerIndex = 0
        }
    }
}

// MARK: - 메인 화면

private struct CompatibilityMainContent: View {
    @Bindable var store: StoreOf<CompatibilityFeature>
    let backAction: () -> Void

    var body: some View {
        ZStack {
            Color.ds.white.ignoresSafeArea()

            VStack(spacing: 0) {
                DSHeaderSub(
                    title: "상대방 궁합",
                    leftItem: DSHeaderActionItem(
                        identifier: "back",
                        icon: .chevronLeftNarrow,
                        action: backAction
                    )
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        mySajuSection

                        partnerSection

                        if let errorMessage = store.errorMessage {
                            FortuneErrorBanner(message: errorMessage)
                        }

                        submitButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
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
    }

    @ViewBuilder
    private var mySajuSection: some View {
        if let mySaju = store.mySaju {
            VStack(alignment: .leading, spacing: 12) {
                Text("내 정보")
                    .dsHeading3Bold
                    .foregroundStyle(Color.ds.gray975)

                SajuChartCard(
                    chart: mySaju,
                    fallbackName: "토닥이",
                    relationshipTitle: nil,
                    onEditTapped: {
                        store.send(.myInfoEditTapped)
                    }
                )
            }
        }
    }

    private var partnerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("상대방 정보")
                .dsHeading3Bold
                .foregroundStyle(Color.ds.gray975)

            if let partner = store.selectedPartner {
                selectedPartnerCard(partner: partner)
            } else {
                emptyPartnerCard
            }
        }
    }

    private func selectedPartnerCard(partner: FortunePartner) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let chart = store.selectedPartnerSaju {
                SajuChartCard(
                    chart: chart,
                    fallbackName: partner.name,
                    relationshipTitle: partner.relationship.title,
                    onEditTapped: {
                        store.send(.partnerPickerPresented(true))
                    }
                )
            } else {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("\(partner.name)님의 사주 정보를 불러오고 있어요.")
                        .dsBody3Regular
                        .foregroundStyle(Color.ds.gray700)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(Color.ds.gray50)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var emptyPartnerCard: some View {
        Button {
            if store.partners.isEmpty {
                store.send(.registrationPresented(true))
            } else {
                store.send(.partnerPickerPresented(true))
            }
        } label: {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.ds.gray200)
                        .frame(width: 48, height: 48)

                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.ds.gray600)
                }

                Text("궁합 볼 상대방의 정보를 입력해 주세요.")
                    .dsBody3Regular
                    .foregroundStyle(Color.ds.gray800)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .background(Color.ds.gray50)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var submitButton: some View {
        DSPrimaryLargeButton("무료로 궁합 보기") {
            store.send(.compatibilityTapped)
        }
        .disabled(store.selectedPartnerID == nil || store.isSubmitting)
    }
}

// MARK: - 상대방 등록 화면 (Push Screen)

private struct PartnerRegistrationView: View {
    @Bindable var store: StoreOf<CompatibilityFeature>

    var body: some View {
        ZStack {
            Color.ds.white.ignoresSafeArea()

            VStack(spacing: 0) {
                DSHeaderSub(
                    title: "상대방 정보 입력",
                    leftItem: DSHeaderActionItem(
                        identifier: "back",
                        icon: .chevronLeftNarrow,
                        action: { store.send(.registrationPresented(false)) }
                    )
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        DSEnterName(
                            text: $store.name.sending(\.nameChanged),
                            validationState: nameValidationState
                        )

                        DSSajuBasicFieldsView(
                            gender: $store.gender.sending(\.genderChanged),
                            calendarType: $store.calendarType.sending(\.calendarTypeChanged),
                            birthDate: $store.birthDate.sending(\.birthDateChanged),
                            birthTime: $store.birthTime.sending(\.birthTimeChanged),
                            isBirthTimeUnknown: $store.isBirthTimeUnknown.sending(\.birthTimeUnknownChanged),
                            birthDateValidationMessage: BirthDatePolicy.validateNotInFuture(
                                for: store.birthDate,
                                asOf: Date()
                            ),
                            spacing: 32
                        )

                        DSSelectRelationship(
                            selection: $store.relationship.sending(\.relationshipChanged)
                        )

                        if let errorMessage = store.errorMessage {
                            FortuneErrorBanner(message: errorMessage)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
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
                DSPrimaryLargeButton("저장하기") {
                    store.send(.registerTapped)
                }
                .disabled(!store.canRegister)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 12)
            }
            .background(Color.clear)
        }
    }

    private var nameValidationState: DSTextFieldValidationState {
        if let message = store.nameValidationMessage {
            return .error(message: message)
        }
        return .none
    }
}

// MARK: - 결과 화면

private struct CompatibilityResultContent: View {
    @Bindable var store: StoreOf<CompatibilityFeature>

    var body: some View {
        if let result = store.result {
            ZStack(alignment: .top) {
                resultBackgroundImage

                VStack(spacing: 0) {
                    resultHeader

                    ScrollView {
                        VStack(spacing: 20) {
                            resultHeaderSection(result: result)

                            scoreAndSummaryCard(result: result)

                            sajuStructureCard

                            elementsCard(elements: result.elements)

                            totalAnalysisCard(result: result)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .background(Color.fortuneSpaceBase)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                FortuneTodakInquiryBar(tooltip: "오늘 이 사람과 어디를 갈까?") {
                    store.send(.todakTapped)
                }
            }
        }
    }

    private var resultHeader: some View {
        HStack {
            Button {
                store.send(.resultBackTapped)
            } label: {
                DSIcon(.chevronLeftNarrow, width: 24, height: 24)
                    .foregroundStyle(Color.ds.white)
                    .frame(width: 44, height: 44)
            }
            .dsIconButtonStyle(.chevronLeftNarrow, width: 24, height: 24)

            Spacer()

            Text("상대방 궁합 결과")
                .dsBody2SemiBold
                .foregroundStyle(Color.ds.white)

            Spacer()

            Button {
                store.send(.shareTapped)
            } label: {
                shareIconAsset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.ds.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("공유하기")
        }
        .padding(.horizontal, 10)
        .frame(height: 52)
    }

    private func resultHeaderSection(result: CompatibilityResult) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Text(result.relationship.title)
                    .dsCaption1Medium
                    .foregroundStyle(Color.ds.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.ds.primary600)
                    .clipShape(Capsule())

                Text("\(result.partnerName)님과 나의")
                    .dsBody2Regular
                    .foregroundStyle(Color.ds.whiteOpacity80)
            }

            Text(result.headline)
                .dsHeading1Bold
                .foregroundStyle(Color.ds.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func scoreAndSummaryCard(result: CompatibilityResult) -> some View {
        VStack(spacing: 24) {
            FortuneResultScoreRing(score: result.score, caption: "궁합 점수")

            VStack(alignment: .leading, spacing: 12) {
                Text(result.subheadline)
                    .dsHeading2Bold
                    .foregroundStyle(Color.ds.white)

                Text(result.summary)
                    .dsBody3Regular
                    .foregroundStyle(Color.ds.whiteOpacity80)
                    .lineSpacing(6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.ds.whiteOpacity10)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    @ViewBuilder
    private var sajuStructureCard: some View {
        if let mySaju = store.mySaju, let partnerSaju = store.selectedPartnerSaju {
            VStack(alignment: .leading, spacing: 16) {
                Text("사주 구조")
                    .dsBody1Bold
                    .foregroundStyle(Color.ds.white)

                Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 12) {
                    GridRow {
                        Color.clear
                            .frame(height: 1)
                            .gridColumnAlignment(.leading)

                        ForEach(["시", "일", "월", "년"], id: \.self) { title in
                            Text(title)
                                .dsCaption1Regular
                                .foregroundStyle(Color.ds.whiteOpacity60)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    sajuGridRow(
                        title: "나",
                        pillars: mySaju.pillars,
                        symbolKeyPath: \.heavenlyStem
                    )

                    sajuGridRow(
                        title: store.result?.partnerName ?? (store.selectedPartner?.name ?? "상대방"),
                        pillars: partnerSaju.pillars,
                        symbolKeyPath: \.earthlyBranch
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.ds.whiteOpacity10)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    @ViewBuilder
    private func sajuGridRow(
        title: String,
        pillars: [SajuPillar],
        symbolKeyPath: KeyPath<SajuPillar, SajuSymbol>
    ) -> some View {
        GridRow {
            Text(title)
                .dsBody2SemiBold
                .foregroundStyle(Color.ds.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .gridColumnAlignment(.leading)

            ForEach([SajuPillarType.hour, .day, .month, .year], id: \.self) { type in
                if let pillar = pillars.first(where: { $0.type == type }) {
                    let symbol = pillar[keyPath: symbolKeyPath]
                    DSSajuPillarCell(
                        hanja: symbol.hanja,
                        reading: symbol.reading,
                        element: DSSajuElement.from(hanja: symbol.hanja)
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    DSSajuPillarCell(
                        hanja: "-",
                        reading: "-",
                        element: .unknown
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func elementsCard(elements: [FortuneElementScore]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("오행 시각화")
                .dsBody1Bold
                .foregroundStyle(Color.ds.white)

            VStack(spacing: 12) {
                ForEach(elements) { elemScore in
                    HStack(spacing: 12) {
                        Text(elemScore.element.titleWithHanja)
                            .dsBody3Medium
                            .foregroundStyle(Color.ds.white)
                            .frame(width: 38, alignment: .leading)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.ds.whiteOpacity10)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.ds.primary300, Color.ds.primary400],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(0, geo.size.width * CGFloat(elemScore.percentage) / 100.0))
                            }
                        }
                        .frame(height: 8)

                        Text("\(elemScore.percentage)%")
                            .dsCaption1Medium
                            .foregroundStyle(Color.ds.whiteOpacity80)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }

            Text("서로의 기운이 조화롭게 보완되는 균형 상태입니다.")
                .dsBody3Regular
                .foregroundStyle(Color.ds.whiteOpacity80)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.ds.whiteOpacity10)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func totalAnalysisCard(result: CompatibilityResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("궁합 총운 분석")
                .dsBody1Bold
                .foregroundStyle(Color.ds.white)

            Text(result.totalAnalysis)
                .dsBody3Regular
                .foregroundStyle(Color.ds.whiteOpacity80)
                .lineSpacing(6)

            if !result.analysisBasis.isEmpty {
                Divider()
                    .background(Color.ds.whiteOpacity10)
                    .padding(.vertical, 4)

                Text(result.analysisBasis)
                    .dsCaption1Regular
                    .foregroundStyle(Color.ds.whiteOpacity60)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.ds.whiteOpacity10)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var resultBackgroundImage: some View {
        GeometryReader { proxy in
            FortuneSpaceBackground()
                .frame(height: proxy.size.width / (393.0 / 850.0))
        }
        .ignoresSafeArea(edges: .top)
    }

    private var shareIconAsset: Image {
        FortuneFeatureAsset.fortuneShare.swiftUIImage
    }
}

// MARK: - 공용 도우미

private extension FortuneElement {
    var titleWithHanja: String {
        switch self {
        case .wood: "목 木"
        case .fire: "화 火"
        case .earth: "토 土"
        case .metal: "금 金"
        case .water: "수 水"
        }
    }
}

private struct SajuChartCard: View {
    let chart: SajuChartDetail
    let fallbackName: String
    let relationshipTitle: String?
    var onEditTapped: (() -> Void)?

    private var sortedPillars: [SajuPillar] {
        chart.pillars.sorted { $0.type.sortOrder < $1.type.sortOrder }
    }

    private var titleText: String {
        let name = chart.name?.nonEmpty ?? fallbackName
        if let gender = chart.gender {
            return "\(name) · \(gender.title)"
        }
        return name
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(titleText)
                            .dsBody1Bold
                            .foregroundStyle(Color.ds.gray975)

                        if let relationshipTitle {
                            Text(relationshipTitle)
                                .dsCaption1Medium
                                .foregroundStyle(Color.ds.primary600)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.ds.primary50)
                                .clipShape(Capsule())
                        }
                    }

                    Text(birthInformation)
                        .dsBody3Regular
                        .foregroundStyle(Color.ds.gray800)
                }

                Spacer()

                if let onEditTapped {
                    Button(action: onEditTapped) {
                        Text("변경")
                            .dsCaption1SemiBold
                            .foregroundStyle(Color.ds.primary600)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.ds.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.ds.primary300, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()
                .foregroundStyle(Color.ds.gray200)

            HStack(alignment: .top, spacing: 12) {
                ForEach(sortedPillars) { pillar in
                    SajuPillarColumn(pillar: pillar, isDark: false)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(Color.ds.gray50)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var birthInformation: String {
        let date = Self.dateFormatter.string(from: chart.birthDate)
        let calendar = chart.calendarType.map { $0.title } ?? "양력"
        let time: String
        if chart.isBirthTimeUnknown {
            time = "태어난 시각 모름"
        } else if let birthTime = chart.birthTime {
            time = birthTime.displayText
        } else {
            time = ""
        }
        return [date + " " + calendar, time].filter { !$0.isEmpty }.joined(separator: " · ")
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
}

private struct SajuPillarColumn: View {
    let pillar: SajuPillar
    let isDark: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(pillar.type.title)
                .dsCaption3Medium
                .foregroundStyle(isDark ? Color.ds.whiteOpacity60 : Color.ds.gray600)

            Text(pillar.type == .day ? (pillar.stemTenGod ?? "일원") : (pillar.stemTenGod ?? "-"))
                .dsCaption3Regular
                .foregroundStyle(isDark ? Color.ds.whiteOpacity80 : Color.ds.gray975)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            DSSajuPillarCell(
                hanja: pillar.heavenlyStem.hanja,
                reading: pillar.heavenlyStem.reading,
                element: DSSajuElement.from(hanja: pillar.heavenlyStem.hanja)
            )
            .frame(maxWidth: .infinity)

            DSSajuPillarCell(
                hanja: pillar.earthlyBranch.hanja,
                reading: pillar.earthlyBranch.reading,
                element: DSSajuElement.from(hanja: pillar.earthlyBranch.hanja)
            )
            .frame(maxWidth: .infinity)

            Text(pillar.branchTenGod)
                .dsCaption3Regular
                .foregroundStyle(isDark ? Color.ds.whiteOpacity80 : Color.ds.gray975)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)

            if let twelveLifeStage = pillar.twelveLifeStage {
                Text(twelveLifeStage)
                    .dsCaption3Regular
                    .foregroundStyle(isDark ? Color.ds.whiteOpacity60 : Color.ds.gray700)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
            }
        }
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
