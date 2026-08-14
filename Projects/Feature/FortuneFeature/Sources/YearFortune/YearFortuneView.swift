import ComposableArchitecture
import DesignSystem
import SwiftUI

struct YearFortuneView: View {
    @Bindable var store: StoreOf<YearFortuneFeature>
    let backAction: () -> Void

    init(store: StoreOf<YearFortuneFeature>, backAction: @escaping () -> Void) {
        self.store = store
        self.backAction = backAction
    }

    var body: some View {
        ZStack {
            if let result = store.result {
                YearFortuneResultContent(store: store, result: result)
            } else {
                YearFortuneFormContent(store: store, backAction: backAction)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - 입력 화면

private struct YearFortuneFormContent: View {
    @Bindable var store: StoreOf<YearFortuneFeature>
    let backAction: () -> Void

    var body: some View {
        ZStack {
            Color.ds.white.ignoresSafeArea()

            VStack(spacing: 0) {
                YearFortuneHeaderView(title: "연도별 운세", isDark: false, action: backAction)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        formHeader

                        yearSelectionSection

                        if let errorMessage = store.errorMessage {
                            YearFortuneErrorBanner(message: errorMessage)
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

    private var formHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("운세를 확인할 연도를 선택해 주세요")
                .dsHeading3Bold
                .foregroundStyle(Color.ds.gray975)

            Text("신년 운세와 한 해 동안의 종합적인 기운을 미리 살펴보세요.")
                .dsBody3Regular
                .foregroundStyle(Color.ds.gray700)
        }
    }

    private var yearSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("연도 선택")
                .dsBody2SemiBold
                .foregroundStyle(Color.ds.gray975)

            let currentYear = Calendar.current.component(.year, from: Date())
            let candidateYears = Array((currentYear - 5)...(currentYear + 5))

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 10
            ) {
                ForEach(candidateYears, id: \.self) { year in
                    let isSelected = store.selectedYear == year
                    Button {
                        store.send(.yearSelected(year))
                    } label: {
                        Text("\(String(year))년")
                            .dsBody3Medium
                            .foregroundStyle(isSelected ? Color.ds.white : Color.ds.gray800)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isSelected ? Color.ds.primary600 : Color.ds.gray100)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.ds.primary300, lineWidth: 1)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var submitButton: some View {
        DSButton("운세 확인하기") {
            store.send(.createTapped)
        }
        .disabled(store.isSubmitting)
        .opacity(store.isSubmitting ? 0.4 : 1.0)
        .padding(.top, 12)
    }
}

// MARK: - 결과 화면

private struct YearFortuneResultContent: View {
    @Bindable var store: StoreOf<YearFortuneFeature>
    let result: YearFortuneResult

    var body: some View {
        ZStack(alignment: .top) {
            Color.fortuneSpaceBase.ignoresSafeArea()

            resultBackgroundImage

            VStack(spacing: 0) {
                resultHeader

                ScrollView {
                    VStack(spacing: 24) {
                        resultCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            FortuneTodakInquiryBar(tooltip: "시간대는 언제가 좋아?") {
                store.send(.todakTapped)
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

            Text("연도별 운세 결과")
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

    private var resultCard: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("\(String(result.year))년 운세")
                    .dsBody3Medium
                    .foregroundStyle(Color.ds.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.ds.primary600)
                    .clipShape(Capsule())

                Text("\(String(result.year))년의 운세")
                    .dsHeading2Bold
                    .foregroundStyle(Color.ds.white)
            }

            VStack(spacing: 12) {
                FortuneResultScoreRing(score: result.score, caption: "연간 종합 점수")

                Text(result.title)
                    .dsBody1Bold
                    .foregroundStyle(Color.ds.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                if !result.categories.isEmpty {
                    categoryHighlights
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(Color.ds.whiteOpacity10)
            .clipShape(RoundedRectangle(cornerRadius: 24))

            summaryCard
        }
    }

    private var categoryHighlights: some View {
        HStack(alignment: .top, spacing: 12) {
            ForEach(result.categories.prefix(3)) { category in
                VStack(spacing: 6) {
                    Text(category.category.title)
                        .dsCaption1Regular
                        .foregroundStyle(Color.ds.whiteOpacity60)

                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { starIndex in
                            Image(systemName: starIndex <= category.star ? "star.fill" : "star")
                                .font(.system(size: 11))
                                .foregroundStyle(
                                    starIndex <= category.star
                                        ? Color.ds.primary300
                                        : Color.ds.whiteOpacity20
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 12)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("종합 총평")
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

// MARK: - 공용 뷰

private struct YearFortuneHeaderView: View {
    let title: String
    let isDark: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                DSIcon(.chevronLeftNarrow, width: 24, height: 24)
                    .foregroundStyle(isDark ? Color.ds.white : Color.ds.gray975)
                    .frame(width: 44, height: 44)
            }
            .dsIconButtonStyle(.chevronLeftNarrow, width: 24, height: 24)

            Spacer()

            Text(title)
                .dsBody2SemiBold
                .foregroundStyle(isDark ? Color.ds.white : Color.ds.gray975)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 10)
        .frame(height: 52)
    }
}

private struct YearFortuneErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.ds.red500)

            Text(message)
                .dsBody3Medium
                .foregroundStyle(Color.ds.red500)

            Spacer()
        }
        .padding(12)
        .background(Color.ds.red500.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
