import Foundation

enum LuckyActionDateFormatter {
    static func listTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "M월 d일 행운액션"
        return formatter.string(from: date)
    }
}
