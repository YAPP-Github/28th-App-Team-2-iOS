import Foundation
import LuckyActionFeatureInterface

public enum LuckyActionFixture {
    public static let today = [
        action(
            identifier: "00000000-0000-0000-0000-000000000001",
            category: .relationship,
            score: 84,
            title: "오랜만에 생각난 사람에게 메시지 보내기"
        ),
        action(
            identifier: "00000000-0000-0000-0000-000000000002",
            category: .love,
            score: 21,
            title: "평소보다 밝은 컬러의 옷 착용하기"
        ),
        action(
            identifier: "00000000-0000-0000-0000-000000000003",
            category: .achievement,
            score: 17,
            title: "미뤄둔 작은 업무 하나 먼저 끝내기"
        ),
        action(
            identifier: "00000000-0000-0000-0000-000000000004",
            category: .health,
            score: 60,
            title: "10분 정도 가볍게 산책하거나 스트레칭하기"
        ),
        action(
            identifier: "00000000-0000-0000-0000-000000000005",
            category: .money,
            score: 93,
            title: "사용하지 않는 구독 서비스나 자동결제 내역 확인하기"
        )
    ]

    public static func action(
        identifier: String = UUID().uuidString,
        category: LuckyActionCategory,
        score: Int,
        title: String = "행운 액션",
        isAchieved: Bool = false
    ) -> LuckyAction {
        LuckyAction(
            id: UUID(uuidString: identifier)!,
            category: category,
            score: score,
            title: title,
            isAchieved: isAchieved
        )
    }
}

public actor LuckyActionMock {
    private var actions: [LuckyAction]
    private let scoreDelta: Int

    public init(
        actions: [LuckyAction] = LuckyActionFixture.today,
        scoreDelta: Int = 5
    ) {
        self.actions = actions
        self.scoreDelta = scoreDelta
    }

    public func fetchToday() -> [LuckyAction] {
        actions
    }

    public func fetchByDate(_: Date) -> [LuckyAction] {
        actions
    }

    public func toggleAchievement(actionID: UUID) -> LuckyAction {
        guard let index = actions.firstIndex(where: { $0.id == actionID }) else {
            preconditionFailure("행운 액션 fixture를 찾을 수 없습니다.")
        }

        let action = actions[index]
        let updatedAction = LuckyAction(
            id: action.id,
            category: action.category,
            score: action.score + (action.isAchieved ? -scoreDelta : scoreDelta),
            title: action.title,
            isAchieved: !action.isAchieved
        )
        actions[index] = updatedAction
        return updatedAction
    }
}

public extension LuckyActionClient {
    static func mock(repository: LuckyActionMock) -> Self {
        Self(
            fetchToday: { await repository.fetchToday() },
            fetchByDate: { date in await repository.fetchByDate(date) },
            toggleAchievement: { actionID in
                await repository.toggleAchievement(actionID: actionID)
            }
        )
    }
}
