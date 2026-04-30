import Foundation

public struct DayKey: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible, Comparable {
    public let rawValue: String

    public init?(rawValue: String) {
        let parts = rawValue.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            return nil
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = DayKey.utcTimeZone

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = DayKey.utcTimeZone
        components.year = year
        components.month = month
        components.day = day

        guard calendar.date(from: components) != nil else {
            return nil
        }

        self.rawValue = DayKey.format(year: year, month: month, day: day)
    }

    public init(year: Int, month: Int, day: Int) {
        self.rawValue = DayKey.format(year: year, month: month, day: day)
    }

    public init(
        date: Date,
        timeZone: TimeZone,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) {
        var scopedCalendar = calendar
        scopedCalendar.timeZone = timeZone

        let components = scopedCalendar.dateComponents([.year, .month, .day], from: date)

        self.init(
            year: components.year ?? 1970,
            month: components.month ?? 1,
            day: components.day ?? 1
        )
    }

    public var description: String {
        rawValue
    }

    public var components: DateComponents {
        let parts = rawValue.split(separator: "-")

        return DateComponents(
            year: Int(parts[0]),
            month: Int(parts[1]),
            day: Int(parts[2])
        )
    }

    public var date: Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = DayKey.utcTimeZone

        return calendar.date(from: components)
    }

    public var weekday: MarkerWeekday? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = DayKey.utcTimeZone

        guard let date = calendar.date(from: components) else {
            return nil
        }

        return MarkerWeekday(foundationWeekday: calendar.component(.weekday, from: date))
    }

    public func addingDays(_ days: Int) -> DayKey? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = DayKey.utcTimeZone

        guard let date,
              let shifted = calendar.date(byAdding: .day, value: days, to: date) else {
            return nil
        }

        return DayKey(date: shifted, timeZone: DayKey.utcTimeZone, calendar: calendar)
    }

    public static func < (lhs: DayKey, rhs: DayKey) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    private static let utcTimeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

    private static func format(year: Int, month: Int, day: Int) -> String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }
}
