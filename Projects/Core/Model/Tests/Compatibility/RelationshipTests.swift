import Testing
@testable import Model

struct RelationshipTests {
    @Test("관계 선택 모델의 항목 순서 검증")
    func testSelectionCases() {
        #expect(Relationship.allCases == [.partner, .friend, .colleague])
    }
}
