import ComposableArchitecture
import DesignSystem
import SwiftUI

// 리포트 섹션은 플로팅 툴팁 노출에 사용하는 스크롤 임계 상태를 공유한다.
// swiftlint:disable file_length type_body_length

struct FortuneReportView: View {
    @Bindable var store: StoreOf<FortuneReportFeature>
    let backAction: () -> Void

    @State private var didReachCategorySection = false
    @State private var showInfoTooltip = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.fortuneSpaceBase.ignoresSafeArea()

            backgroundImage

            content

            if case .loaded = store.viewState {
                todakFloatingButton
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await store.send(.task).finish()
        }
        .sheet(
            item: $store.scope(state: \.categoryDetail, action: \.categoryDetail)
        ) { categoryStore in
            FortuneCategoryDetailView(store: categoryStore)
                .presentationDetents([.fraction(0.8)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(28)
        }
    }

    private var backgroundImage: some View {
        GeometryReader { proxy in
            FortuneSpaceBackground()
                .frame(height: proxy.size.width / (393.0 / 850.0))
        }
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private var content: some View {
        switch store.viewState {
        case .loading:
            FortuneLoadingView()

        case let .failed(message):
            FortuneFailureView(
                message: message,
                retryAction: { store.send(.retryTapped) }
            )

        case let .loaded(detail):
            ZStack(alignment: .top) {
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 52)
                        reportBody(detail)
                    }
                    .containerRelativeFrame(.horizontal)
                }
                .scrollIndicators(.hidden)

                reportHeader
            }
        }
    }

    private var reportHeader: some View {
        HStack {
            Button(action: backAction) {
                DSIcon(.chevronLeftNarrow, width: 24, height: 24)
                    .foregroundStyle(Color.ds.white)
                    .frame(width: 44, height: 44)
            }
            .dsIconButtonStyle(.chevronLeftNarrow, width: 24, height: 24)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 10)
        .frame(height: 52)
    }

    private func reportBody(_ detail: FortuneDetailContent) -> some View {
        VStack(spacing: 24) {
            scoreSection(detail)
            summarySection(detail)
            categorySection(detail)
            itemSection(
                title: "오늘의 행운 아이템",
                items: detail.luckyItems,
                imageName: "img_clover",
                badgeColor: Color.ds.primary300
            )
            itemSection(
                title: "오늘의 주의 아이템",
                items: detail.cautionaryItems,
                imageName: "img_warning",
                badgeColor: Color.ds.pink300
            )

            Color.clear.frame(height: 76)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private func scoreSection(_ detail: FortuneDetailContent) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 4) {
                Text("오늘의 운세")
                    .dsBody2Medium
                    .foregroundStyle(Color.ds.primary300)

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showInfoTooltip.toggle()
                    }
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color.ds.whiteOpacity60)
                }
            }
            .overlay(alignment: .top) {
                if showInfoTooltip {
                    VStack(alignment: .center, spacing: 0) {
                        TopTailShape()
                            .fill(Color.ds.white.opacity(0.9))
                            .frame(width: 12, height: 8)
                            .padding(.leading, 80)

                        Text("오늘의 운세 점수는\n사주 데이터 분석을 바탕으로 나온\n상세운 5가지의 평균 점수예요")
                            .dsBody3Medium
                            .foregroundStyle(Color.ds.gray900)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.ds.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .fixedSize()
                    .offset(y: 28)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                }
            }
            .zIndex(1)

            Text(detail.title)
                .multilineTextAlignment(.center)
                .dsHeading4Bold
                .foregroundStyle(Color.ds.white)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            Text("\(detail.score)점")
                .dsHeading1ExtraBold
                .foregroundStyle(Color.ds.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(Color.ds.whiteOpacity20)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }

    private func summarySection(_ detail: FortuneDetailContent) -> some View {
        VStack(spacing: -80) {
            FortuneMoodCharacterImage(
                moodLevel: FortuneMoodLevel(score: Double(detail.score))
            )
            .frame(width: 193, height: 181)
            .accessibilityHidden(true)
            .zIndex(1)

            Text(detail.content)
                .dsBody1Medium
                .foregroundStyle(Color.ds.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .padding(.top, 60) // 추가 패딩으로 이미지 겹치는 부분 아래로 텍스트 밀어냄
                .background(Color.ds.whiteOpacity10)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func categorySection(_ detail: FortuneDetailContent) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("상세운")
                    .dsBody1Bold
                    .foregroundStyle(Color.ds.white)

                Text("사주 데이터 분석을 바탕으로 점수를 제공해요")
                    .dsBody3Regular
                    .foregroundStyle(Color.ds.whiteOpacity80)
            }

            VStack(spacing: 20) {
                ForEach(detail.categoryScores, id: \.category) { item in
                    Button {
                        store.send(.categoryTapped(item))
                    } label: {
                        VStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Text(item.category.title)
                                    .dsBody3Medium
                                    .foregroundStyle(Color.ds.white)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.ds.whiteOpacity80)

                                Spacer()

                                Text("\(item.score)점")
                                    .dsBody3SemiBold
                                    .foregroundStyle(Color.ds.white)
                            }

                            GeometryReader { proxy in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.ds.whiteOpacity10)
                                    Capsule()
                                        .fill(Color.ds.primary500)
                                        .frame(width: proxy.size.width * CGFloat(max(0, min(item.score, 100))) / 100)
                                }
                            }
                            .frame(height: 10)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                store.send(.luckyActionTapped)
            } label: {
                Text("행운 액션 확인하기")
                    .dsBody2Medium
                    .foregroundStyle(Color.ds.primary100)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.ds.primary300, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color.ds.whiteOpacity10)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onGeometryChange(for: Bool.self) { proxy in
            proxy.frame(in: .global).minY <= 140
        } action: { reached in
            guard reached, !didReachCategorySection else { return }
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                didReachCategorySection = true
            }
        }
    }

    private func itemSection(title: String, items: [String], imageName: String, badgeColor: Color) -> some View {
        VStack(alignment: .center, spacing: 16) {
            Image(imageName, bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            Text(title)
                .dsBody3Medium
                .foregroundStyle(Color.ds.white)

            FlowLayout(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .dsBody2Regular
                        .foregroundStyle(badgeColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.ds.whiteOpacity10)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(Color.ds.whiteOpacity10)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var todakFloatingButton: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if didReachCategorySection {
                Text("오늘 이 사람과 어디를 갈까?")
                    .dsBody3Medium
                    .foregroundStyle(Color.ds.gray900)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                    .background(Color.ds.white.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(.bottom, 12)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(0)
            }

            VStack(spacing: 4) {
                Text("AI 토닥이")
                    .dsCaption2SemiBold
                    .foregroundStyle(Color.ds.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 193/255, green: 180/255, blue: 246/255))
                    )
                    .overlay(alignment: .bottom) {
                        BottomTailShape()
                            .fill(Color(red: 193/255, green: 180/255, blue: 246/255))
                            .frame(width: 8, height: 5)
                            .offset(y: 5)
                    }
                    .padding(.bottom, 4)

                Button {
                    store.send(.todakTapped)
                } label: {
                    Image("img_fab_todak", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.ds.primary300, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.3), radius: 10, y: 4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("토닥이에게 물어보기")
            }
            .zIndex(1)
        }
    }
}

// swiftlint:enable type_body_length

private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let width = proposal.width ?? 0
        var horizontalOffset: CGFloat = 0
        var verticalOffset: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if horizontalOffset > 0, horizontalOffset + size.width > width {
                horizontalOffset = 0
                verticalOffset += rowHeight + spacing
                rowHeight = 0
            }
            horizontalOffset += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: verticalOffset + rowHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var rows: [[LayoutSubview]] = []
        var currentRow: [LayoutSubview] = []
        var currentRowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if !currentRow.isEmpty, currentRowWidth + spacing + size.width > bounds.width {
                rows.append(currentRow)
                currentRow = [subview]
                currentRowWidth = size.width
            } else {
                currentRow.append(subview)
                currentRowWidth += (currentRow.count == 1 ? 0 : spacing) + size.width
            }
        }
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        var verticalOffset = bounds.minY
        for row in rows {
            let rowWidth = row.reduce(0) { $0 + $1.sizeThatFits(.unspecified).width } + spacing * CGFloat(row.count - 1)
            var horizontalOffset = bounds.minX + (bounds.width - rowWidth) / 2
            var rowHeight: CGFloat = 0

            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(
                    at: CGPoint(x: horizontalOffset, y: verticalOffset),
                    proposal: ProposedViewSize(size)
                )
                horizontalOffset += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
            verticalOffset += rowHeight + spacing
        }
    }
}

struct BottomTailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct TopTailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width / 2, y: 0))
        path.closeSubpath()
        return path
    }
}
