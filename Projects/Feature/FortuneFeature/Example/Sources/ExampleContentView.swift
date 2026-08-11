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
    }

    var body: some View {
        FortuneView(store: store)
            .overlay(alignment: .bottomTrailing) {
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
