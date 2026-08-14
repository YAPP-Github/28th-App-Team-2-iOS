import Foundation

public struct BirthDate: Hashable, Sendable, Comparable, Codable, CustomStringConvertible {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(
        year: Int,
        month: Int,
        day: Int
    ) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init?(yyyyMMdd: String) {
        let components = yyyyMMdd.split(separator: "-").compactMap { Int($0) }
        guard components.count == 3 else { return nil }
        self.init(year: components[0], month: components[1], day: components[2])
    }

    public init(date: Date, calendar: Calendar = .current) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.year = components.year ?? 2000
        self.month = components.month ?? 1
        self.day = components.day ?? 1
    }

    public func toDate(calendar: Calendar = .current) -> Date? {
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: components) else { return nil }
        let resolved = calendar.dateComponents([.year, .month, .day], from: date)
        guard resolved.year == year, resolved.month == month, resolved.day == day else {
            return nil
        }
        return date
    }

    public var description: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    public var formattedDate: String {
        description
    }

    public static func < (lhs: BirthDate, rhs: BirthDate) -> Bool {
        if lhs.year != rhs.year { return lhs.year < rhs.year }
        if lhs.month != rhs.month { return lhs.month < rhs.month }
        return lhs.day < rhs.day
    }
}
