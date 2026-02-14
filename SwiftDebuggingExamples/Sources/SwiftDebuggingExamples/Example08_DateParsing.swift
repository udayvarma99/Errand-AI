import Foundation

// MARK: - Example 08: Date parsing bug (locale/time zone)
//
// Broken (common):
// - Parsing fixed-format date strings without fixing locale/time zone.
//
// Debug:
// - Print `Locale.current` and `TimeZone.current`.
// - Write a unit test that sets a known locale/time zone and verifies behavior.
//
// Fix:
// - For fixed-format parsing with DateFormatter, set:
//   locale = en_US_POSIX, timeZone = GMT/UTC, and a fixed dateFormat.
//
// Note:
// - DateFormatter is expensive to create and is not thread-safe to share freely.
//   In production, cache per-thread/actor or use a safe wrapper.

public enum Example08_DateParsing {
    private static let posix = Locale(identifier: "en_US_POSIX")
    private static let utc = TimeZone(secondsFromGMT: 0)!

    /// Parses strings like: "2026-02-14T12:34:56Z"
    public static func parseInternetDateTime(_ text: String) -> Date? {
        let f = DateFormatter()
        f.locale = posix
        f.timeZone = utc
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return f.date(from: text)
    }

    /// Formats a Date into: "yyyy-MM-dd'T'HH:mm:ssZ" (UTC)
    public static func formatInternetDateTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = posix
        f.timeZone = utc
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return f.string(from: date)
    }
}

