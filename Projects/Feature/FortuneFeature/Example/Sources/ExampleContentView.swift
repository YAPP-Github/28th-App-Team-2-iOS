import ComposableArchitecture
import FortuneFeature
import SwiftUI

struct ExampleContentView: View {
    @State private var selectedScenario = MoodScenario.level03

    private let store = Store(
        initialState: FortuneFeature.State(
            viewState: .loaded(.example(score: MoodScenario.level03.score))
        )
    ) {
        FortuneFeature()
    } withDependencies: {
        $0.fortuneClient.fetchDetail = { _ in
            try await Task.sleep(for: .seconds(0.5))
            return .example(score: 65)
        }
        $0.fortuneClient.fetchLuckAction = { _ in
            try await Task.sleep(for: .seconds(0.5))
            return LuckActionDetail(
                id: UUID(),
                category: .relationship,
                score: 85,
                title: "따뜻한 차 마시기",
                content: "따뜻한 차를 마시면 마음이 안정되고 행운이 깃들 거예요.",
                isAchieved: false
            )
        }
        $0.fortuneClient.fetchMySaju = {
            try await Task.sleep(for: .seconds(0.5))
            return SajuChartDetail(
                id: UUID(),
                name: "나의 성향",
                gender: .female,
                birthDate: Date(),
                calendarType: .solar,
                birthTime: nil,
                isBirthTimeUnknown: true,
                pillars: [
                    SajuPillar(type: .year, heavenlyStem: SajuSymbol(hanja: "甲", reading: "갑", elementLabel: "큰 나무", elementHanja: "목"), earthlyBranch: SajuSymbol(hanja: "辰", reading: "진", elementLabel: "용", elementHanja: "토"), stemTenGod: "비견", branchTenGod: "편재"),
                    SajuPillar(type: .month, heavenlyStem: SajuSymbol(hanja: "丙", reading: "병", elementLabel: "태양", elementHanja: "화"), earthlyBranch: SajuSymbol(hanja: "寅", reading: "인", elementLabel: "호랑이", elementHanja: "목"), stemTenGod: "식신", branchTenGod: "비견"),
                    SajuPillar(type: .day, heavenlyStem: SajuSymbol(hanja: "戊", reading: "무", elementLabel: "큰 산", elementHanja: "토"), earthlyBranch: SajuSymbol(hanja: "申", reading: "신", elementLabel: "원숭이", elementHanja: "금"), stemTenGod: nil, branchTenGod: "식신")
                ]
            )
        }
        $0.fortuneClient.fetchPartners = {
            try await Task.sleep(for: .seconds(0.5))
            return [
                FortunePartner(id: UUID(), name: "토닥이", relationship: .friend)
            ]
        }
        $0.fortuneClient.fetchPartnerSaju = { _ in
            try await Task.sleep(for: .seconds(0.5))
            return SajuChartDetail(
                id: UUID(),
                name: "상대방 성향",
                gender: .male,
                birthDate: Date(),
                calendarType: .solar,
                birthTime: nil,
                isBirthTimeUnknown: true,
                pillars: [
                    SajuPillar(type: .year, heavenlyStem: SajuSymbol(hanja: "丁", reading: "정", elementLabel: "등불", elementHanja: "화"), earthlyBranch: SajuSymbol(hanja: "卯", reading: "묘", elementLabel: "토끼", elementHanja: "목"), stemTenGod: "정인", branchTenGod: "정관"),
                    SajuPillar(type: .month, heavenlyStem: SajuSymbol(hanja: "己", reading: "기", elementLabel: "작은 흙", elementHanja: "토"), earthlyBranch: SajuSymbol(hanja: "酉", reading: "유", elementLabel: "닭", elementHanja: "금"), stemTenGod: "겁재", branchTenGod: "상관")
                ]
            )
        }
        $0.fortuneClient.registerPartner = { _ in UUID() }
        $0.fortuneClient.createCompatibility = { _, _ in 
            CompatibilityResult(
                id: UUID(),
                partnerName: "토닥이",
                relationship: .friend,
                score: 95,
                headline: "최고의 궁합",
                subheadline: "서로에게 큰 힘이 됩니다",
                summary: "두 분의 기운이 조화롭게 어우러져 서로의 부족한 점을 채워주는 훌륭한 관계입니다.",
                totalAnalysis: "전체적인 사주의 흐름이 서로를 지탱하며 시너지를 만들어냅니다.",
                analysisBasis: "목(木)과 화(火)의 기운이 상생하여 발전적인 방향으로 나아갑니다.",
                elements: [
                    FortuneElementScore(element: .wood, percentage: 40),
                    FortuneElementScore(element: .fire, percentage: 30),
                    FortuneElementScore(element: .earth, percentage: 20),
                    FortuneElementScore(element: .metal, percentage: 10)
                ]
            )
        }
        $0.fortuneClient.createDayFortunes = { purpose, dates in
            try await Task.sleep(for: .seconds(1))
            return Array(
                dates.enumerated().map { index, date in
                    DayFortuneResult(
                        id: UUID(),
                        purpose: purpose,
                        targetDate: date,
                        score: 90 - (index * 5),
                        title: index == 0 ? "최적의 날짜입니다!" : "무난한 날짜입니다.",
                        content: "이 날은 기운이 매우 긍정적으로 작용하여 원하시는 바를 순조롭게 이룰 수 있습니다.",
                        categories: [
                            FortuneCategoryStar(category: .achievement, star: 5),
                            FortuneCategoryStar(category: .money, star: 4),
                            FortuneCategoryStar(category: .health, star: 3)
                        ]
                    )
                }
                .sorted { $0.score > $1.score }
                .prefix(3)
            )
        }
        $0.fortuneClient.createYearFortune = { _ in 
            try await Task.sleep(for: .seconds(1))
            return YearFortuneResult(
                id: UUID(),
                year: 2026,
                score: 90,
                title: "새로운 기회가 찾아오는 희망찬 한 해",
                content: "그동안 준비했던 일들이 결실을 맺으며, 특히 하반기에 큰 성취를 이룰 수 있습니다.",
                categories: [
                    FortuneCategoryStar(category: .money, star: 5),
                    FortuneCategoryStar(category: .achievement, star: 4),
                    FortuneCategoryStar(category: .relationship, star: 4)
                ]
            ) 
        }
    }

    var body: some View {
        FortuneView(store: store)
            .overlay(alignment: .bottomTrailing) {
                if store.path.isEmpty && store.categoryDetail == nil {
                    Menu {
                        Picker("Mood Level", selection: $selectedScenario) {
                            ForEach(MoodScenario.allCases, id: \.self) { scenario in
                                Text(scenario.title)
                                    .tag(scenario)
                            }
                        }
                    } label: {
                        Label(selectedScenario.title, systemImage: "face.smiling")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 14)
                            .frame(height: 40)
                            .background(.regularMaterial, in: Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(.secondary.opacity(0.3), lineWidth: 1)
                            }
                            .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                }
            }
            .onChange(of: selectedScenario) { _, scenario in
                store.send(
                    .todayFortuneResponse(
                        .success(.example(score: scenario.score))
                    )
                )
            }
    }
}

private enum MoodScenario: String, CaseIterable {
    case level01
    case level02
    case level03
    case level04

    var score: Double {
        switch self {
        case .level01:
            20
        case .level02:
            50
        case .level03:
            65.4
        case .level04:
            90
        }
    }

    var title: String {
        switch self {
        case .level01:
            "Level 01 · 20점"
        case .level02:
            "Level 02 · 50점"
        case .level03:
            "Level 03 · 65.4점"
        case .level04:
            "Level 04 · 90점"
        }
    }
}
