import Foundation

struct EntryResponseDTO: Decodable, Sendable {
    let greeting: String
    let suggestions: [EntrySuggestionDTO]
    let quota: EntryQuotaDTO

    func toDomain() throws -> TodakEntry {
        TodakEntry(
            greeting: greeting,
            suggestions: try suggestions.map { try $0.toDomain() },
            quota: TodakQuota(used: quota.used, limit: quota.limit)
        )
    }
}

struct EntrySuggestionDTO: Decodable, Sendable {
    let emoji: String
    let label: String
    let seedPrompt: String
    let category: String?

    func toDomain() throws -> TodakSuggestion {
        TodakSuggestion(
            emoji: emoji,
            label: label,
            seedPrompt: seedPrompt,
            category: try category.map(mapCategory)
        )
    }
}

struct EntryQuotaDTO: Decodable, Sendable {
    let used: Int
    let limit: Int
}
